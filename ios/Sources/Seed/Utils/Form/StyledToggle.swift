import SwiftUI

// MARK: - Styled Toggle
struct StyledToggle: View {
    let label: String
    let info: String?
    @Binding var isOn: Bool
    
    init(label: String, info: String? = nil, isOn: Binding<Bool>) {
        self.label = label
        self.info = info
        self._isOn = isOn
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .lato(.t4, weight: .bold)
                        .foregroundColor(.text0)
                    
                    if let info = info {
                        Text(info)
                            .lato(.t6, weight: .regular)
                            .foregroundColor(.text1.opacity(0.2))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: .accent))
                    .scaleEffect(0.9)
            }
        }
    }
}
