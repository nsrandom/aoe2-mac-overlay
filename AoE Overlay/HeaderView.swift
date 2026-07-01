import SwiftUI
import UniformTypeIdentifiers

struct HeaderView: View {
    @Environment(\.openWindow) private var openWindow
    
    let buildOrder: BuildOrder?
    @Binding var currentStepIndex: Int
    @Binding var showMatchup: Bool
    let onLoadBuildOrder: (BuildOrder) -> Void
    
    @AppStorage("maxStepsPerPage") private var maxStepsPerPage: Int = 5
    
    private var pages: [[BuildOrderStep]] {
        guard let buildOrder = buildOrder else { return [] }
        return buildOrder.computePages(maxPerPage: maxStepsPerPage)
    }
    
    private var activePageIndex: Int {
        guard let buildOrder = buildOrder, currentStepIndex < buildOrder.buildOrder.count else { return 0 }
        let activeStep = buildOrder.buildOrder[currentStepIndex]
        for (index, page) in pages.enumerated() {
            if page.contains(where: { $0.id == activeStep.id }) {
                return index
            }
        }
        return 0
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Button(action: {
                    selectBuildOrderFile()
                }) {
                    Image(systemName: "doc.text")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    openWindow(id: "settings")
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    showMatchup.toggle()
                }) {
                    Image(systemName: showMatchup ? "person.2.slash" : "person.2")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // Build Order Step Navigation (First / Prev / Next Buttons)
            HStack(spacing: 4) {
                // First Step Button
                Button(action: {
                    currentStepIndex = 0
                }) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(buildOrder == nil || activePageIndex == 0)
                .opacity((buildOrder == nil || activePageIndex == 0) ? 0.35 : 1.0)
                
                // Previous Step Button (Moves to previous page)
                Button(action: {
                    let index = activePageIndex
                    if index > 0, let targetStep = pages[index - 1].first {
                        if let targetIndex = buildOrder?.buildOrder.firstIndex(where: { $0.id == targetStep.id }) {
                            currentStepIndex = targetIndex
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(buildOrder == nil || activePageIndex == 0)
                .opacity((buildOrder == nil || activePageIndex == 0) ? 0.35 : 1.0)
                
                // Next Step Button (Moves to next page)
                Button(action: {
                    let index = activePageIndex
                    if index < pages.count - 1, let targetStep = pages[index + 1].first {
                        if let targetIndex = buildOrder?.buildOrder.firstIndex(where: { $0.id == targetStep.id }) {
                            currentStepIndex = targetIndex
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(buildOrder == nil || pages.isEmpty || activePageIndex >= pages.count - 1)
                .opacity((buildOrder == nil || pages.isEmpty || activePageIndex >= pages.count - 1) ? 0.35 : 1.0)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func selectBuildOrderFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.json]
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(BuildOrder.self, from: data)
                
                // 1. Guard check for empty build order steps
                guard !decoded.buildOrder.isEmpty else {
                    let alert = NSAlert()
                    alert.messageText = "Import Failed"
                    alert.informativeText = "The build order contains no steps."
                    alert.alertStyle = .warning
                    alert.runModal()
                    return
                }
                
                // 2. Prepare Sandbox folder
                let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                let appSupport = paths.first!.appendingPathComponent("com.nsrandom.AoE-Overlay")
                let folder = appSupport.appendingPathComponent("build_orders")
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                
                // 3. Resolve destination file name conflict dynamically (SHA/Incremental suffix)
                var destinationURL = folder.appendingPathComponent(url.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    let existingData = try? Data(contentsOf: destinationURL)
                    if existingData != data {
                        // Data hash is different, let's append a suffix
                        let baseName = url.deletingPathExtension().lastPathComponent
                        let ext = url.pathExtension
                        var counter = 1
                        while true {
                            let candidateName = "\(baseName) (\(counter)).\(ext)"
                            let candidateURL = folder.appendingPathComponent(candidateName)
                            if !FileManager.default.fileExists(atPath: candidateURL.path) {
                                destinationURL = candidateURL
                                break
                            }
                            counter += 1
                        }
                    }
                }
                
                // 4. Copy file to Sandbox
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.copyItem(at: url, to: destinationURL)
                
                // 5. Store in AppStorage (UserDefaults)
                UserDefaults.standard.set(destinationURL.lastPathComponent, forKey: "lastLoadedBuildOrder")
                
                // 6. Reset step index and load
                currentStepIndex = 0
                onLoadBuildOrder(decoded)
                
            } catch {
                print("Failed to import build order: \(error)")
                let alert = NSAlert()
                alert.messageText = "Import Failed"
                alert.informativeText = "The selected file is not a valid Build Order JSON. \(error.localizedDescription)"
                alert.alertStyle = .warning
                alert.runModal()
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            buildOrder: BuildOrder.mockBuildOrder,
            currentStepIndex: .constant(0),
            showMatchup: .constant(true),
            onLoadBuildOrder: { _ in }
        )
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
