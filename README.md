# Aura — Your AI Storytelling Studio ✨
> *"Where every story finds its soul."*

A full-stack, production-ready AI storytelling and story-editing sanctuary designed for authors, creative dreamers, and literary worldbuilders. Aura combines a royal pastel design aesthetic with an advanced conversational AI writing studio, multi-chapter manuscript management, password protection, and age-verified content safety.

---

## 🎨 Visual Identity & Typography Guidelines

Aura adheres strictly to an enchanted royal pastel aesthetic:
- **Palette**: Baby Blue (`#D6E6FF`), Baby Pink (`#FFD6E8`), Baby Purple (`#E8D7FF`), Champagne Gold (`#D4AF37`), and Pearlescent Whites.
- **Main Landing Title**: `Playfair Display`
- **Main Landing Subtitle**: `Abril Fatface`
  ```text
  stories written under fading skies
  lost somewhere between dreams and reality
  creating worlds that feels like memories
  ```
- **Aura Title Placement**: The Aura title appears **only at the beginning of the application** (the grand novel-opening landing page and browser tab). It is *not* repeated at the top of every chapter, inside the chat interface, or throughout the dashboard.
- **Headings across the app**: `DM Serif Display` / `DM Serif Text`
- **Notes, manuscript editor, & body prose**: `Cormorant Garamond`
- **Buttons, badges, & UI controls**: `Inter`

---

## 🚀 Key Features

1. **AI Storytelling Studio (9 Creative Modes)**:
   - *Create a Story*: Original scenes, vivid prose, dialogue generation.
   - *Continue My Story*: Picks up right from the manuscript's current cursor/ending.
   - *Edit My Story*: Polishes pacing, emotional subtext, and narrative flow.
   - *Find Errors*: Identifies grammar, repetition, plot inconsistencies, and passive voice.
   - *Improve Writing*: Elevates ordinary prose into sensory, lyrical descriptions.
   - *Create Characters*: Develops complex archetypes, fears, and distinct dialogue voices.
   - *Build a World*: Kingdoms, magic systems, ancient lore, and cultural superstitions.
   - *Brainstorm Ideas*: Unexpected plot twists, dilemmas, and moral forks.
   - *Summarize Chapter*: Key story beats and character development takeaways.
2. **Output Styles & Diff Inspector**:
   - Switch between **Corrections**, **Suggestions**, and **Rewritten** versions.
   - Visual Diff Inspector with 1-click **"✨ Insert into Story"** button.
3. **Multi-Chapter Notebooks & Story Canvas**:
   - Organize books into unlimited chapters with "+ Add Another Chapter".
   - Drag & reorder chapters, live word count, and reading speed calculator.
   - Real-time debounced autosave with visual status indicator (`Saved ✨`).
   - Export to **Plain Text (.txt)**, **Markdown (.md)**, or **Printable PDF**.
   - Text file import (.txt, .md).
4. **Dramatis Personae (Character Management)**:
   - Comprehensive character dossiers: Name, Age, Pronouns, Personality, Appearance, Background, Goals, Fears, Strengths, Weaknesses, and Relationships.
   - One-click "Mention in AI" to ask Aura how specific characters react.
5. **Royal Security & Age Verification**:
   - Cryptographic SHA-256 password hashing for optional notebook protection.
   - Date of Birth collection during registration with automated age verification.
   - Content safety guard flags explicit mature themes for minors (<18).
6. **Ambient Royal Soundscape**:
   - Built-in Web Audio API royal chimes & library ambience for zero-distraction writing.

---

## 🗄️ Supabase Database Setup

Aura works **out of the box** in offline/local storage mode, and seamlessly connects to your Supabase project for international cloud persistence.

### 1. Execute SQL Migration
1. Go to your [Supabase Dashboard](https://supabase.com/dashboard).
2. Open the **SQL Editor**.
3. Copy the entire contents of [`supabase_schema.sql`](./supabase_schema.sql) and click **Run**.
4. This creates the `profiles`, `notebooks`, `chapters`, `messages`, and `characters` tables along with Row Level Security (RLS) policies.

### 2. Connect in the Application
1. Click the **⚙️ Settings** button in Aura's top navigation bar.
2. Paste your **Supabase Project URL** and **Anon Public Key**.
3. *(Optional)* Enter your Google Gemini API Key for direct Gemini 1.5 Flash generation.
4. Click **Save Settings** — your local manuscripts will sync automatically!

---

## 🌐 Worldwide Public Deployment (Free)

Aura is a client-first, serverless-ready web application built with vanilla HTML5, CSS3, and ES6 modules. It can be deployed in under 2 minutes to any global CDN:

### Option A: Vercel
```bash
# Install Vercel CLI or deploy via GitHub
npx vercel deploy --prod
```

### Option B: Netlify
1. Drag and drop the `AURA` project folder into [Netlify Drop](https://app.netlify.com/drop).
2. Your public HTTPS URL is live instantly!

### Option C: GitHub Pages
1. Push the repository to GitHub.
2. In **Settings** > **Pages**, set branch to `main` and folder to `/ (root)`.
3. Your app is accessible worldwide at `https://<username>.github.io/<repo>/`.

---

## 📄 License
Crafted with elegance for authors everywhere. ✨
