# Plume - App Specifications (Gemini)

## 1. App Overview
**Name:** Plume
**Tagline:** "The calmest way to capture every day"
**Core Concept:** A privacy-first, local-first journaling application that emphasizes daily reflection through gratitudes, memories, and accomplishments. It features a distraction-free Zen writing mode, calendar-centric navigation, and optional AI assistance.
**Target Platforms:** macOS (AppKit/SwiftUI), iPadOS, iOS (SwiftUI).

---

## 2. Features List

### Core Journaling
- **Daily Entry Structure:**
    - **Gratitude:** Multi-line input for things to be grateful for.
    - **Memory:** Single or multi-line input for a specific daily memory.
    - **Accomplishments:** Multi-line input for daily achievements.
    - **Journal:** Long-form text editor for free writing.
- **Rich Text / Markdown:** Support for markdown in the journal field.
- **Zen Mode:** Distraction-free, full-screen writing environment with customizable typography and ambient backgrounds.
- **Auto-Save:** Continuous background saving and save-on-blur.

### Navigation & Organization
- **Calendar View:** Monthly grid layout with visual indicators, "Today" highlighting, and filters.
- **Today View:** Dedicated view for the current day's entry with a motivational quote.
- **Explore View:** Analytics dashboard and search interface.
- **Search:** Global full-text search across all entries with highlighting and context snippets.

### Task Management (Todos)
- **Daily Todos:** Todos associated with specific dates.
- **Quick Add:** Global shortcut to add a todo from anywhere.
- **Todo Management:** Check/uncheck, delete, move to tomorrow, move to today.

### AI Assistance (Optional)
- **Providers:** OpenAI, Claude, Gemini, Grok, Mistral.
- **Features:** Improve Language, Summarize, Highlight Important, Autofill.
- **Privacy:** User-provided API keys.

### Data & Sync
- **Local-First:** SQLite.
- **Sync:** iCloud Drive, CloudKit, or File System (Encrypted XChaCha20-Poly1305).
- **Import/Export:** .plume files.

### Security
- **App Lock:** Passphrase, Touch ID / Face ID.

---

## 3. Design System & Color Scheme

### A. Color Palette
The app uses a semantic color system that adapts to Light and Dark modes.

**Global Colors:**
-   **Primary:** `#3B82F6` (Blue) - Used for active states, primary buttons, and links.
-   **Background (Main):**
    -   Light: `#FFFFFF` (White)
    -   Dark: `#111827` (Gray 900)
-   **Background (Secondary/Sidebar):**
    -   Light: `#F3F4F6` (Gray 100)
    -   Dark: `#1F2937` (Gray 800)
-   **Surface/Cards:**
    -   Light: `#FFFFFF` (White) with subtle shadow.
    -   Dark: `#374151` (Gray 700)
-   **Text (Primary):**
    -   Light: `#111827` (Gray 900)
    -   Dark: `#F9FAFB` (Gray 50)
-   **Text (Secondary/Muted):**
    -   Light: `#6B7280` (Gray 500)
    -   Dark: `#9CA3AF` (Gray 400)
-   **Border/Divider:**
    -   Light: `#E5E7EB` (Gray 200)
    -   Dark: `#374151` (Gray 700)

**Entry Type Accents (Semantic):**
-   **Gratitude:** `#F59E0B` (Amber/Gold) - Represents warmth and thankfulness.
-   **Memory:** `#10B981` (Emerald/Green) - Represents growth and moments.
-   **Accomplishment:** `#EF4444` (Red/Orange) - Represents energy and achievement.
-   **Journal:** `#8B5CF6` (Violet/Purple) - Represents creativity and depth.

### B. Typography
**Font Family:**
-   **UI:** System Font (San Francisco on Apple devices).
-   **Zen Mode (User Selectable):**
    -   *Sans-Serif:* Inter / San Francisco
    -   *Serif:* New York / Literata
    -   *Monospace:* SF Mono
    -   *Handwritten:* Patrick Hand

**Type Scale:**
-   **Large Title:** 34pt (Bold) - Date Headers.
-   **Title 2:** 22pt (Bold) - Section Headers.
-   **Headline:** 17pt (Semibold) - Card Titles.
-   **Body:** 17pt (Regular) - Main text input.
-   **Callout:** 16pt (Regular) - Quotes.
-   **Caption:** 12pt (Medium) - Metadata, timestamps.

### C. UI Components
-   **Buttons:** Rounded corners (8px-12px). Primary buttons have solid background. Secondary buttons have outline or transparent background.
-   **Inputs:** Minimalist. No borders by default in "Today View", only subtle underline or background on focus.
-   **Cards:** Rounded corners (16px). Subtle drop shadow in Light mode, lighter background in Dark mode.
-   **Icons:** SF Symbols (Apple) or Lucide Icons. Stroke width: Medium.

---

## 4. Screens & Actions (Detailed)

### A. Calendar View (Home)
**Layout:**
-   **Desktop:** Split view. Left pane (75%) is the Calendar Grid. Right pane (25%) is the Sidebar (Entry/Todo details).
-   **Mobile:** Single column. Calendar Grid takes full screen. Tapping a day navigates to Entry View.

**1. Header Area:**
-   **Left:** `<` and `>` icon buttons for month navigation.
-   **Center:** "Month Year" (e.g., "November 2024") centered, bold text.
-   **Right:** Filter Segmented Control or Toggle Group: `[All | Memory | Gratitude | Accomp]`.
    -   *Active:* Filled with Primary Color (or Accent Color if specific filter selected).
    -   *Inactive:* Transparent/Gray background.

**2. Calendar Grid:**
-   **Columns:** 7 columns (Mon-Sun or Sun-Sat based on settings).
-   **Headers:** Day names (MON, TUE...) in Caption font, muted color.
-   **Cells:**
    -   **Shape:** Square.
    -   **Date Number:** Top-left corner.
    -   **Indicators:** Small colored dots (4px) centered at the bottom of the cell, representing entry types present (Gold for Gratitude, Green for Memory, etc.).
    -   **States:**
        -   *Empty:* Plain background.
        -   *Today:* Circle highlight behind the date number (Primary Color, 15% opacity).
        -   *Selected:* Thick Primary Color border around the cell.
        -   *Hover:* Subtle gray background change.

**3. Sidebar (Desktop Only):**
-   **Header:** Selected Date (e.g., "Monday, Nov 24") in Large Title.
-   **Content:**
    -   If empty: "No entry for this day" illustration + "Create Entry" button.
    -   If populated: Scrollable list of entry sections (Gratitude, Memory, etc.) in read-only or quick-edit mode.
    -   **Todo Section:** List of todos for that date at the bottom.

**Actions:**
-   `Click Day`: Selects date, updates Sidebar.
-   `Double Click Day`: Navigates to **Entry Edit View**.
-   `Arrow Keys`: Move selection focus.

### B. Today View / Entry Edit View
**Layout:** Single column, centered content, max-width ~800px.

**1. Header:**
-   **Quote:** (Today View only) Italicized motivational quote, muted text, centered.
-   **Date:** (Edit View) "Monday, November 24" displayed prominently.

**2. Entry Fields (Vertical Stack):**
-   **Gratitude Section:**
    -   **Icon:** 🙏 (or SF Symbol `sun.max`). Color: Gold.
    -   **Label:** "I am grateful for..." (Small Caps, Bold).
    -   **Input:** Multi-line text area. Bullet points auto-inserted on new lines (optional).
-   **Memory Section:**
    -   **Icon:** 💫 (or SF Symbol `sparkles`). Color: Green.
    -   **Label:** "Daily Memory"
    -   **Input:** Text area.
-   **Accomplishment Section:**
    -   **Icon:** 🏆 (or SF Symbol `rosette`). Color: Red.
    -   **Label:** "Accomplishments"
    -   **Input:** Multi-line text area.
-   **Journal Section:**
    -   **Icon:** 📝 (or SF Symbol `book`). Color: Purple.
    -   **Label:** "Journal"
    -   **Input:** Long-form rich text/markdown editor.
    -   **Toolbar (Floating or Fixed):** Bold, Italic, List, **AI Tools** (Sparkle icon).

**3. Footer / Sticky Controls:**
-   **Zen Mode Button:** Floating action button or top-right header button. Icon: `arrow.up.left.and.arrow.down.right`.
-   **Save Status:** "Saved" indicator (fades out).

**Actions:**
-   `Focus Field`: Highlights the active section (subtle border or opacity change on others).
-   `Cmd+S`: Force save.
-   `Cmd+Shift+Z`: Toggle Zen Mode.

### C. Zen Mode Overlay
**Layout:** Full screen, covering all other UI.
**Appearance:**
-   **Background:** User configurable (Solid muted color, or subtle gradient).
-   **Content:** Centered text column (max-width 700px).

**UI Elements:**
-   **Text Area:** Title (optional) + Body. Caret color matches Primary.
-   **Hidden Controls (Reveal on Mouse Move):**
    -   **Top Bar:**
        -   `Exit` (X) button.
        -   `Font Family` dropdown.
        -   `Font Size` slider.
        -   `Theme` toggle (Light/Dark/Sepia).
    -   **Bottom Bar:**
        -   `Word Count` / `Character Count`.
        -   `Time` display.

**Actions:**
-   `Type`: Auto-scrolls to keep caret centered vertically (Typewriter scrolling).
-   `Esc`: Exit Zen Mode.

### D. Explore View
**Layout:** Dashboard style grid.

**1. Statistics Cards (Top Row):**
-   **Cards:** "Total Entries", "Current Streak", "Words Written".
-   **Visuals:** Big bold numbers, sparkline charts in background.

**2. Charts Section:**
-   **Activity Heatmap:** GitHub-style grid of squares showing entry frequency over the year. Darker color = more words.
-   **Mood/Category Breakdown:** Pie chart or Bar chart showing distribution of Gratitude vs Memory vs Accomplishment usage.

**3. Search Interface:**
-   **Search Bar:** Large, centered. Placeholder: "Search your memories..."
-   **Filters:** Date Range Picker, Tag filter.
-   **Results List:**
    -   Items show: Date, Type Badge (Colored), Text Snippet with **highlighted** search terms.
    -   Clicking an item opens the **Entry Modal**.

### E. Search Modal (Command Palette)
**Layout:** Centered modal overlay, similar to Spotlight or Raycast.
**Dimensions:** Width ~600px, Max Height ~400px.

**UI Elements:**
-   **Input:** Large text field, no border, auto-focus.
-   **List:** Scrollable list of results.
    -   **Selection:** Active item highlighted with Primary Color (light opacity).
    -   **Shortcuts:** `Enter` to open, `Cmd+Enter` to edit.
-   **Footer:** "Type to search... Press Tab to switch to Todo creation."

### F. Todo List (Sidebar Component)
**Layout:** Vertical list.

**UI Elements:**
-   **Item:**
    -   **Checkbox:** Round (iOS style). Click to animate checkmark.
    -   **Text:** Strikethrough when checked. Muted color when checked.
    -   **Actions (Hover):** Trash icon, "Move to Tomorrow" icon.
-   **Input:** "Add a task..." field at the bottom or top.

### G. Settings Modal
**Layout:**
-   **Sidebar:** Vertical tabs (General, Sync, Appearance, AI, Data).
-   **Content:** Form elements.

**UI Elements:**
-   **Toggles:** iOS-style switches (Green when active).
-   **Dropdowns:** Native system pickers.
-   **API Key Input:** Obscured text field (`••••••••`) with "Show" toggle.

---

## 5. User Stories

### Core Journaling
1.  **As a user**, I want to quickly log what I'm grateful for so that I can maintain a positive mindset.
2.  **As a user**, I want to record a specific memory from the day so I can look back on it later.
3.  **As a user**, I want to list my daily accomplishments to track my progress and feel productive.
4.  **As a user**, I want a free-form journal section where I can write my thoughts without structure.
5.  **As a user**, I want to enter "Zen Mode" to write without any UI distractions or notifications.
6.  **As a user**, I want my entries to save automatically as I type so I never lose my work.
7.  **As a user**, I want to be able to hide the "Accomplishments" field if I don't want to use it.

### Navigation & Review
8.  **As a user**, I want to see a calendar view of my journaling history to visualize my consistency.
9.  **As a user**, I want to see visual indicators on the calendar for days where I recorded a gratitude or memory.
10. **As a user**, I want to filter the calendar to show only days where I had a "Memory" recorded.
11. **As a user**, I want to easily jump to "Today" from any past month in the calendar.
12. **As a user**, I want to search for a specific keyword across all my past entries to find a specific event.
13. **As a user**, I want to see my current streak to stay motivated.

### Task Management
14. **As a user**, I want to create a todo list for today so I can plan my day within my journal.
15. **As a user**, I want to quickly add a task that pops into my head without leaving my current writing flow.
16. **As a user**, I want to move unfinished tasks to tomorrow so I don't forget them.
17. **As a user**, I want to see a list of all my incomplete tasks from the past so I can clean them up.

### AI Assistance
18. **As a user**, I want the AI to fix my grammar and spelling in my journal entry.
19. **As a user**, I want the AI to summarize my long rambling entry into a concise summary.
20. **As a user**, I want to write a brain dump in the journal section and have the AI automatically extract and fill the Gratitude and Accomplishment fields.
21. **As a user**, I want to use my own OpenAI/Claude API key so I control my data privacy and costs.

### Sync & Data Privacy
22. **As a user**, I want my data to sync between my Mac and iPhone so I can journal on the go.
23. **As a user**, I want my synced data to be end-to-end encrypted so that no one (including the cloud provider) can read it.
24. **As a user**, I want to be able to export my entire journal to a file for backup.
25. **As a user**, I want to lock the app with FaceID/TouchID to keep my private thoughts secure.

### Customization
26. **As a user**, I want to change the app theme to Dark Mode to reduce eye strain at night.
27. **As a user**, I want to choose a specific font for Zen Mode that makes me feel creative.
28. **As a user**, I want to customize keyboard shortcuts to match my personal workflow.
29. **As a user**, I want to choose between playful emoji icons or minimal monochrome icons for the UI.

### Mobile Specific
30. **As a mobile user**, I want to swipe left/right to navigate between days or months.
31. **As a mobile user**, I want haptic feedback when I complete a task or save an entry.
32. **As an iPad user**, I want to see the calendar and my entry side-by-side in landscape mode.

---

## 6. UI / Layout Drafts (ASCII Art)

### A. Desktop Layout (Calendar + Sidebar)
```
+-----------------------------------------------------------------------+
|  PLUME    [Calendar]  [Today]  [Explore]            [Search] [Settings]|
+-------------------------------------------------------+---------------+
|  <  November 2024  >       (Filters: All/Mem/Grat)    |  Mon, Nov 24  |
|                                                       |               |
|  Mon   Tue   Wed   Thu   Fri   Sat   Sun            |  [ Gratitude ]|
|  +---+ +---+ +---+ +---+ +---+ +---+ +---+            |  - Family     |
|  | 1 | | 2 | | 3 | | 4 | | 5 | | 6 | | 7 |            |  - Coffee     |
|  | . | |   | | . | |   | | . | |   | |   |            |               |
|  +---+ +---+ +---+ +---+ +---+ +---+ +---+            |  [ Memory ]   |
|                                                       |  Walk in park |
|  +---+ +---+ +---+ +---+ +---+ +---+ +---+            |               |
|  | 8 | | 9 | |10 | |11 | |12 | |13 | |14 |            |  [ Accomp. ]  |
|  | . | | . | |   | |   | | . | |   | |   |            |  - Fixed bug  |
|  +---+ +---+ +---+ +---+ +---+ +---+ +---+            |               |
|                                                       |  [ Journal ]  |
|  ...                                                  |  Today was a  |
|                                                       |  good day...  |
|                                                       |               |
|                                                       |  [ Todos ]    |
|                                                       |  [x] Email    |
|                                                       |  [ ] Call Mom |
+-------------------------------------------------------+---------------+
```

### B. Today View (Focused)
```
+-------------------------------------------------------+
|                                                       |
|           "The journey of a thousand miles..."        |
|                                                       |
|  +-------------------------------------------------+  |
|  |  GRATITUDE                                      |  |
|  |  1. Sunshine                                    |  |
|  |  2. Good health                                 |  |
|  +-------------------------------------------------+  |
|                                                       |
|  +-------------------------------------------------+  |
|  |  MEMORY                                         |  |
|  |  Saw a double rainbow today.                    |  |
|  +-------------------------------------------------+  |
|                                                       |
|  +-------------------------------------------------+  |
|  |  ACCOMPLISHMENTS                                |  |
|  |  - Finished report                              |  |
|  +-------------------------------------------------+  |
|                                                       |
|  +-------------------------------------------------+  |
|  |  JOURNAL                                        |  |
|  |  I'm feeling really productive today. The       |  |
|  |  weather is nice and...                         |  |
|  |                                                 |  |
|  |  [Zen Mode] [AI Tools]                          |  |
|  +-------------------------------------------------+  |
|                                                       |
+-------------------------------------------------------+
```

### C. Zen Mode Overlay
```
+-------------------------------------------------------+
|  [Exit]      [Font: Inter]  [Size: 16]      [Save]    |
+-------------------------------------------------------+
|                                                       |
|                                                       |
|       The quick brown fox jumps over the lazy         |
|       dog. This is a distraction-free zone.           |
|                                                       |
|       Everything else is hidden. Just you and         |
|       your thoughts.                                  |
|                                                       |
|                                                       |
|                                                       |
|                                                       |
|                                                       |
|                                                       |
|                                                       |
|                                     [Word Count: 42]  |
+-------------------------------------------------------+
```

### D. Mobile Layout (Calendar & Entry)
```
   [ Calendar ]             [ Entry ]
+----------------+      +----------------+
| <  Nov 2024  > |      | < Back   Save  |
| M  T  W  T  F  |      |                |
| 1  2  3  4  5  |      | Mon, Nov 24    |
| .     .     .  |      |                |
| 6  7  8  9  10 |      | [ Gratitude ]  |
| .  .           |      | ______________ |
|                |      |                |
| [List View...] |      | [ Memory ]     |
| 24: Great day  |      | ______________ |
| 23: Sad day    |      |                |
|                |      | [ Journal ]    |
| [Home] [Todo]  |      | ______________ |
+----------------+      +----------------+
```

### E. Search Modal
```
+-------------------------------------------------------+
|  Search: [ rainbow                                  ] |
+-------------------------------------------------------+
|                                                       |
|  Nov 24, 2024  (Memory)                               |
|  ...Saw a double *rainbow* today...                   |
|                                                       |
|  Oct 10, 2024  (Journal)                              |
|  ...colors like a *rainbow* in the sky...             |
|                                                       |
|  [Create Todo: "rainbow"]                             |
|                                                       |
+-------------------------------------------------------+
```

### F. Settings Modal
```
+-------------------------------------------------------+
| Settings                                         [x]  |
+-------------+-----------------------------------------+
| [General  ] |  Theme: [Dark v]                        |
| [Sync     ] |  Primary Color: [ Blue v]               |
| [Shortcuts] |                                         |
| [AI       ] |  Field Visibility:                      |
| [Database ] |  [x] Gratitude                          |
| [License  ] |  [x] Memory                             |
|             |  [x] Accomplishments                    |
|             |                                         |
|             |  Start Week on: [Monday v]              |
+-------------+-----------------------------------------+
```
