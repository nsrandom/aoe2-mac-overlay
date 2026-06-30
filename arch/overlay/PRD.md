# Product Requirements Document (PRD) - AoE2 Build Order Overlay

## 1. Goal
The objective of this app is to display Age of Empires II (AoE2) build orders in a non-intrusive, custom-opacity, borderless overlay window on macOS, similar to the community-standard **RTS Overlay** application. The overlay will load build orders formatted as JSON (compatible with `buildorderguide.com` and `RTS_Overlay` exports), displaying villager distribution, age indicator, and rich description notes featuring inline game assets.

---

## 2. Core Features & Specifications

### A. Build Order Data Structure & Parsing
- Load build order JSON files (e.g., `fc-lancers.json`).
- Parse metadata:
  - Name, Civilization, Author, Source URL, Description.
- Parse build steps array, where each step contains:
  - `villager_count`: Current target villager count.
  - `age`: Current age (1 = Dark Age, 2 = Feudal Age, 3 = Castle Age, 4 = Imperial Age).
  - `resources`: Villager assignments for `wood`, `food`, `gold`, and `stone`.
  - `notes`: String array describing the steps. Note strings contain inline asset tags formatted as `@category/filename.ext@` (e.g., `@resource/MaleVillDE.jpg@` or `@animal/Sheep_aoe2DE.png@`).

### B. Interface Layout & Navigation
- **Header Bar**:
  - File/Document selector button (`doc.text` icon) to switch between multiple loaded build orders.
  - Settings button (`gearshape` icon) to adjust window opacity and other config parameters.
  - Navigation controls (`backward.end.fill`, `chevron.left`, `chevron.right`) to step through the build sequence.
- **Header Metadata**:
  - Show the title of the active build order and target civilization.
- **Match Information**:
  - Show players/Elo information (collapsible or movable to settings).
- **Active Step Viewer**:
  - Multi-step scrolling list.
  - The **Current Step** is highlighted in full opacity/white text, showing resource allocations and rich parsed notes.
  - **Completed Steps** are marked with green checkmarks or faded to guide focus.
  - **Future Steps** are dimmed.

### C. Resource Grid Display
- Each step should show the villager resource allocation grid (Wood, Food, Gold, Stone) with corresponding icons:
  - Wood: `Aoe2de_wood.png`
  - Food: `Aoe2de_food.png`
  - Gold: `Aoe2de_gold.png`
  - Stone: `Aoe2de_stone.png`
- Display should only show non-zero values or highlight changes from the previous step.

### D. Rich Text Note Parsing (Inline Icons)
- Scanner/Parser that searches step notes for bracketed image tags like `@resource/Aoe2de_gold.png@`.
- Renders text inline with graphics/icons.
- In SwiftUI, this can be done by parsing note strings into segments and using SwiftUI's `Text` concatenation with inline `Image` views (e.g. `Text(segment) + Text(Image(systemName: ...))`).

### E. Window Behavior & Opacity
- Draggable, transparent, borderless floating overlay window.
- Opacity slider in SettingsView allows live adjustment of window alpha between `0.1` and `1.0`.

---

## 3. Finalized Design Decisions

### A. Asset Hosting & Loading
- **Decision**: **Remote/Cached**. Assets will be loaded dynamically over the network from the GitHub raw URL prefix (`https://raw.githubusercontent.com/CraftySalamander/RTS_Overlay/master/docs/assets/aoe2/`) and cached locally in the Application Support directory (`~/Library/Application Support/com.nsrandom.AoE-Overlay/assets/`) for offline usability and faster subsequent loads.

### B. Multiple Build Orders & Selection
- **Decision**: **File Picker**. Users will select and load build order JSON files from their local filesystem using a standard macOS file picker/selector dialog (`NSOpenPanel`), triggered by clicking the document icon button in the header.

### C. Step Resource Change Visuals
- **Decision**: **Static Counts Grid**. The UI will display a static grid showing all four resource counts (Wood, Food, Gold, Stone) at all times for each step, maintaining visual consistency across the step checklist.

### D. Window Interaction & Navigation
- **Decision**: **Standard Window Controls**. The overlay will remain as a standard interactive window controlled via mouse clicks on the screen buttons. Global hotkeys and click-through mode are not required.

---

## 4. Technical Implementation Outline
1. **Asset Cache Engine**: Build a local file cache system (`AssetManager`) that downloads and stores AoE2 assets dynamically.
2. **JSON Parser**: Implement a robust JSON decoder for the standard RTS Overlay / Build Order Guide schema.
3. **Rich Text Parser**: Create a SwiftUI parser/view that parses `@` image tags inside note texts and renders them inline with text using SwiftUI layout features.
4. **Header File Selection**: Connect the document button to `NSOpenPanel` to allow loading new JSON build orders.
5. **Opacities and Settings**: Retain the settings window containing the live opacity control slider.

