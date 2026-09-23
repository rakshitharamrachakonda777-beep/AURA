-- ============================================================================
-- AURA — YOUR AI STORYTELLING STUDIO
-- SUPABASE POSTGRESQL PRODUCTION DATABASE SCHEMA & ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE (Extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  email TEXT NOT NULL,
  date_of_birth DATE NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. NOTEBOOKS TABLE
CREATE TABLE IF NOT EXISTS public.notebooks (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  notebook_name TEXT NOT NULL,
  genre TEXT NOT NULL DEFAULT 'Fantasy',
  sub_genre TEXT DEFAULT '',
  is_protected BOOLEAN DEFAULT FALSE NOT NULL,
  password_hash TEXT,
  is_favorite BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. CHAPTERS TABLE
CREATE TABLE IF NOT EXISTS public.chapters (
  id TEXT PRIMARY KEY,
  notebook_id TEXT NOT NULL REFERENCES public.notebooks(id) ON DELETE CASCADE,
  chapter_name TEXT NOT NULL,
  chapter_order INTEGER NOT NULL DEFAULT 1,
  content TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. MESSAGES TABLE (AI Storytelling Conversations per Chapter)
CREATE TABLE IF NOT EXISTS public.messages (
  id TEXT PRIMARY KEY,
  chapter_id TEXT NOT NULL REFERENCES public.chapters(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  mode TEXT DEFAULT 'create',
  output_choice TEXT DEFAULT 'rewritten',
  diff JSONB,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 5. CHARACTERS TABLE (Dramatis Personae per Notebook)
CREATE TABLE IF NOT EXISTS public.characters (
  id TEXT PRIMARY KEY,
  notebook_id TEXT NOT NULL REFERENCES public.notebooks(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  age TEXT,
  pronouns TEXT,
  personality TEXT,
  appearance TEXT,
  background TEXT,
  goals TEXT,
  fears TEXT,
  strengths TEXT,
  weaknesses TEXT,
  relationships TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ============================================================================
-- PERFORMANCE INDEXES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_notebooks_user_id ON public.notebooks(user_id);
CREATE INDEX IF NOT EXISTS idx_notebooks_updated_at ON public.notebooks(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_chapters_notebook_id ON public.chapters(notebook_id);
CREATE INDEX IF NOT EXISTS idx_chapters_order ON public.chapters(notebook_id, chapter_order);
CREATE INDEX IF NOT EXISTS idx_messages_chapter_id ON public.messages(chapter_id);
CREATE INDEX IF NOT EXISTS idx_characters_notebook_id ON public.characters(notebook_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Ensures each user can only read and write their own stories
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notebooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.characters ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Notebooks Policies
CREATE POLICY "Users can view their own notebooks"
  ON public.notebooks FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert their own notebooks"
  ON public.notebooks FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own notebooks"
  ON public.notebooks FOR UPDATE
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete their own notebooks"
  ON public.notebooks FOR DELETE
  USING (auth.uid() = user_id OR user_id IS NULL);

-- Chapters Policies
CREATE POLICY "Users can view chapters of accessible notebooks"
  ON public.chapters FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.notebooks
    WHERE notebooks.id = chapters.notebook_id
    AND (notebooks.user_id = auth.uid() OR notebooks.user_id IS NULL)
  ));

CREATE POLICY "Users can insert chapters into accessible notebooks"
  ON public.chapters FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.notebooks
    WHERE notebooks.id = chapters.notebook_id
    AND (notebooks.user_id = auth.uid() OR notebooks.user_id IS NULL)
  ));

CREATE POLICY "Users can update chapters of accessible notebooks"
  ON public.chapters FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM public.notebooks
    WHERE notebooks.id = chapters.notebook_id
    AND (notebooks.user_id = auth.uid() OR notebooks.user_id IS NULL)
  ));

CREATE POLICY "Users can delete chapters of accessible notebooks"
  ON public.chapters FOR DELETE
  USING (EXISTS (
    SELECT 1 FROM public.notebooks
    WHERE notebooks.id = chapters.notebook_id
    AND (notebooks.user_id = auth.uid() OR notebooks.user_id IS NULL)
  ));

-- Messages Policies
CREATE POLICY "Users can manage messages for their chapters"
  ON public.messages FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.chapters
    JOIN public.notebooks ON notebooks.id = chapters.notebook_id
    WHERE chapters.id = messages.chapter_id
    AND (notebooks.user_id = auth.uid() OR notebooks.user_id IS NULL)
  ));

-- Characters Policies
CREATE POLICY "Users can manage characters for their notebooks"
  ON public.characters FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.notebooks
    WHERE notebooks.id = characters.notebook_id
    AND (notebooks.user_id = auth.uid() OR notebooks.user_id IS NULL)
  ));

-- Trigger to automatically synchronize new Supabase auth users to public.profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, email, date_of_birth)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'date_of_birth')::date, '2000-01-01'::date)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
