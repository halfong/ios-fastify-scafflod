import SwiftUI

struct DetailView: View {

    let item: ExampleItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title card
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text(item.createdAt)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(UISize.screenXPadding)
                .background(.secondary.opacity(0.08))
                .cornerRadius(UISize.cornerRadius)

                // ID
                VStack(alignment: .leading, spacing: 8) {
                    Label("Identifier", systemImage: "number")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)

                    Text(item.id)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.secondary.opacity(0.08))
                        .cornerRadius(10)
                }

                // Placeholder content section
                VStack(alignment: .leading, spacing: 8) {
                    Label("Details", systemImage: "doc.text")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)

                    Text("Add your detail content here.\nThis view is a scaffold placeholder — replace with your actual model data.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.secondary.opacity(0.08))
                        .cornerRadius(10)
                }

                Spacer(minLength: 40)
            }
            .padding(UISize.screenXPadding)
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DetailView(item: ExampleItem(id: "abc-123", title: "Sample Item", createdAt: "2026-01-01T00:00:00Z"))
    }
}
