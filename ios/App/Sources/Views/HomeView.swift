import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var credential: ApiCredential
    @EnvironmentObject private var api: ApiService

    @State private var items: [ExampleItem] = []
    @State private var isLoading = false
    @State private var showLogoutAlert = false
    @State private var selectedItem: ExampleItem?

    private let client = APIClient.shared
    private let errorManager = AppErrorManager.shared

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && items.isEmpty {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if items.isEmpty {
                    emptyStateView
                } else {
                    itemListView
                }
            }
            .navigationTitle("MyApp")
            .toolbar { toolbarContent }
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Sign Out", role: .destructive) { api.logout() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
        .task { await loadItems() }
    }

    // MARK: - Subviews

    private var itemListView: some View {
        List {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
        }
        .listStyle(.plain)
        .refreshable { await loadItems() }
        .navigationDestination(for: ExampleItem.self) { item in
            DetailView(item: item)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(.secondary)

            Text("Nothing here yet")
                .font(.system(size: 20, weight: .semibold))

            Text("Pull down to refresh, or check back later.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await loadItems() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding(UISize.screenXPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showLogoutAlert = true
            } label: {
                if let name = credential.data?.user.name {
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .font(.system(size: 22))
                }
            }
        }
    }

    // MARK: - Data

    private func loadItems() async {
        isLoading = true
        do {
            items = try await client.fetchExamples()
        } catch {
            errorManager.show(AppError(title: "Load Failed", detail: error.localizedDescription))
        }
        isLoading = false
    }
}

// MARK: - Item row

private struct ItemRow: View {
    let item: ExampleItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.system(size: 16, weight: .semibold))
            Text(item.createdAt)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
        .environmentObject(ApiCredential.shared)
        .environmentObject(ApiService.shared)
}
