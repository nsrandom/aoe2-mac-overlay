# Implementation Plan - AoE2 Build Order Overlay

This document details the step-by-step implementation of the AoE2 Build Order Overlay application based on the finalized requirements from the PRD and user feedback.

---

## 1. Directory Structure

We will create and organize the following files inside the workspace under `AoE Overlay/AoE Overlay/`:
- **`Theme.swift`** (Already exists): Host UI styling and layout configuration constants.
- **`BuildOrder.swift`**: Holds parsed model definitions (`BuildOrder`, `BuildOrderStep`, `Resources`).
- **`AssetManager.swift`**: Downloader and disk caching utility for AoE2 icons.
- **`RichTextView.swift`**: Renders note text with inline parsed image attachments.
- **`ResourceGridView.swift`**: Standard 4-column villager allocation grid.
- **`BuildStepsView.swift`** (Modify): Add paging mechanics to show a subset of steps.
- **`SettingsView.swift`** (Modify): Add settings for "Steps Per Page" (default 5).

---

## 2. Technical Designs & Core Logic

### A. Data Models & JSON Schema (`BuildOrder.swift`)
- Implement `Codable` structs matching the standard RTS Overlay / Build Order Guide JSON schema:
```swift
struct BuildOrder: Codable, Identifiable {
    var id: String { name }
    let name: String
    let civilization: String
    let author: String
    let source: String?
    let description: String?
    let buildOrder: [BuildOrderStep]
    
    enum CodingKeys: String, CodingKey {
        case name, civilization, author, source, description
        case buildOrder = "build_order"
    }
}

struct BuildOrderStep: Codable, Identifiable {
    var id = UUID()
    let villagerCount: Int
    let age: Int
    let resources: Resources
    let notes: [String]
    
    enum CodingKeys: String, CodingKey {
        case villagerCount = "villager_count"
        case age, resources, notes
    }
}

struct Resources: Codable {
    let wood: Int
    let food: Int
    let gold: Int
    let stone: Int
}
```

### B. Sandbox-Safe Build Order Loading & Storage
- To read selected build orders across app restarts without hitting macOS sandbox constraints:
  1. On clicking `doc.text`, open `NSOpenPanel` restricted to `.json` files.
  2. Once chosen, read the JSON data, parse it to ensure it is valid, and save a copy of the JSON file to `Application Support/com.nsrandom.AoE-Overlay/build_orders/` preserving its original filename.
  3. Store the filename in `@AppStorage("lastLoadedBuildOrder")` (defaults to `"fc-lancers.json"`).
  4. On launch, attempt to load the file name stored in `lastLoadedBuildOrder` from the app's sandbox directory. If missing, fall back to the bundled workspace example.
  5. **CRITICAL INDEX SAFEGUARD**: When loading a new build order, **always reset `currentStepIndex` to 0**. This avoids out-of-bounds crashes when switching from a long build order to a shorter one.

### C. Step Paging Logic
- Steps are grouped into pages based on two rules:
  1. **Maximum Page Size**: Default `5` steps per page, customizable in Settings.
  2. **Natural Age Boundaries**: A new page is automatically started if a step's `age` value differs from the previous step's `age` value (e.g. stepping from Dark Age to Feudal Age).
- **Active Page Calculation**:
  - The app will automatically calculate which page the `currentStepIndex` belongs to, and render only the steps of that page in `BuildStepsView`.
  - The UI highlights steps relative to `currentStepIndex` (completed steps are green checkmarks, current step has gold arrow and white text, future steps are faded).

### D. Asset Cache Engine (`AssetManager.swift`)
- Expose a singleton Swift **`actor`** `AssetManager` with methods to:
  - Cache directory: `FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!/assets/`
  - Base dynamic URL prefix: `https://raw.githubusercontent.com/CraftySalamander/RTS_Overlay/master/docs/assets/aoe2/`
  - Asynchronously fetch image assets:
    - If file exists locally on disk, return local file URL.
    - If not, download the file from remote repository and write to disk, then return URL.
- **CONCURRENCY & DIRECTORY SAFEGUARDS**:
  - **Actor-based state isolation**: Prevent concurrent read/write data races inside the active downloads dictionary by declaring `AssetManager` as an `actor`.
  - **Thread-safe download registry**: Deduplicate concurrent downloads of the same path using a `[String: Task<URL, Error>]` dictionary.
  - **Auto-create parent directory**: Before writing any downloaded file, verify and create subfolders (e.g. `assets/resource/`) dynamically to prevent file writer exceptions.
  - **404 Fallback**: Ensure HTTP responses are verified for code `200` before caching to prevent corrupting disk with 404 response pages. If fetch fails, return `nil` and render standard SF Symbol helpers.
  - **Custom Request Timeout**: Configure URLSession with a `timeoutIntervalForRequest` of `5.0` seconds to prevent slow connections from freezing UI loading state.

### E. Rich Text Parser (`RichTextView.swift`)
- Parse note lines (e.g., `"Create 6 @resource/MaleVillDE.jpg@ on @animal/Sheep_aoe2DE.png@"`) by:
  - Splitting string by `@`.
  - Scanning parts: odd-indexed parts represent image assets, even-indexed represent raw text.
  - **SwiftUI Layout Flow**: Since SwiftUI `Text` only supports synchronous image insertion, we must pre-fetch/download the assets in the notes asynchronously. Once the local file URLs are ready, we load the `NSImage` from disk and construct the concatenated `Text` string synchronously:
    ```swift
    Text(segment1) + Text(Image(nsImage: loadedImage1)) + Text(segment2)
    ```

---

## 3. Step-by-Step Implementation Tasks

### Phase 1: Models & Core Managers
- `[ ]` Implement `BuildOrder.swift` with optional coding keys for metadata.
- `[ ]` Implement `AssetManager.swift` as an `actor` with directory checks, thread-safe download caching, and verified 200 HTTP responses.
- `[ ]` Integrate default `fc-lancers.json` as a fallback asset bundle or copy it to Application Support on first run.

### Phase 2: Core Subviews
- `[ ]` Create `ResourceGridView.swift` using a 4-column layout and the CachedImage view.
- `[ ]` Create `RichTextView.swift` with `@` tag splitting logic, asset pre-fetching, and SwiftUI `Text + Text` inline concatenation.
- `[ ]` Add the `CachedImage` view wrapper to render downloaded cache files.

### Phase 3: Paging & Selection
- `[ ]` Add a `maxStepsPerPage` `@AppStorage` variable (default `5`) to `Theme` or settings.
- `[ ]` Implement step pagination grouping helper function in `BuildOrder`.
- `[ ]` Update `BuildStepsView` to segment list into pages and render the active page based on `currentStepIndex`.
- `[ ]` Connect Document button in `HeaderView` to trigger `NSOpenPanel`, copy file to Application Support, reset active index, and reload active build order.

### Phase 4: Verification & Polish
- `[ ]` Run build checks to verify compilation.
- `[ ]` Verify live settings updates (opacity, paging settings).
- `[ ]` Test custom JSON files from BOG / RTS_Overlay websites.
