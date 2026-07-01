import SwiftUI

struct SettingsView: View {
    @AppStorage("windowOpacity") private var windowOpacity: Double = 0.5
    @AppStorage("maxStepsPerPage") private var maxStepsPerPage: Int = 5
    
    @AppStorage("buildStepsIconSize") private var buildStepsIconSize: Double = 18.0
    @AppStorage("buildStepsTextSize") private var buildStepsTextSize: Double = 12.0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Overlay Settings")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            // Dynamic window opacity control
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(.gray)
                    Text("Overlay Opacity")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(windowOpacity * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Slider(value: $windowOpacity, in: 0.1...1.0)
                    .tint(Theme.primaryGold)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            
            // Steps configuration and display scaling settings (DRY rows)
            VStack(spacing: 12) {
                SettingRowView(
                    iconName: "list.number",
                    label: "Steps Per Page",
                    value: Binding(
                        get: { Double(maxStepsPerPage) },
                        set: { maxStepsPerPage = Int($0) }
                    ),
                    range: 2...10,
                    unit: ""
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                SettingRowView(
                    iconName: "photo",
                    label: "Icon Size",
                    value: $buildStepsIconSize,
                    range: 12...24,
                    unit: "pt"
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                SettingRowView(
                    iconName: "textformat",
                    label: "Text Size",
                    value: $buildStepsTextSize,
                    range: 9...16,
                    unit: "pt"
                )
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
        .padding(20)
        .frame(width: 300, height: 325)
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}

/// A reusable setting row that displays a label on the left, ELO value on the right, and custom +/- buttons.
private struct SettingRowView: View {
    let iconName: String
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(.gray)
                .frame(width: 18, alignment: .center)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("\(Int(value))\(unit)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.trailing, 6)
            
            // Custom increment and decrement controls
            HStack(spacing: 4) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 18)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 18)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
