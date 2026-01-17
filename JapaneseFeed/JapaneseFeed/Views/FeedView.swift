import SwiftUI

struct FeedView: View {
    @State private var viewModel = FeedViewModel()
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    categoryFilterBar

                    ForEach(viewModel.filteredPosts) { post in
                        NavigationLink(value: post) {
                            PostCardView(post: post, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .navigationTitle("日本語 Feed")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post, viewModel: viewModel)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: viewModel.selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(viewModel.selectedCategory != nil ? .orange : .primary)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                filterSheet
            }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedCategory == nil,
                    color: .orange
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.selectedCategory = nil
                    }
                }

                ForEach(PostCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category,
                        color: categoryColor(category)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    Button {
                        viewModel.selectedCategory = nil
                        showingFilters = false
                    } label: {
                        HStack {
                            Image(systemName: "square.grid.2x2")
                                .foregroundStyle(.orange)
                            Text("All Posts")
                            Spacer()
                            if viewModel.selectedCategory == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .foregroundStyle(.primary)

                    ForEach(PostCategory.allCases, id: \.self) { category in
                        Button {
                            viewModel.selectedCategory = category
                            showingFilters = false
                        } label: {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundStyle(categoryColor(category))
                                Text(category.rawValue)
                                Spacer()
                                if viewModel.selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func categoryColor(_ category: PostCategory) -> Color {
        switch category {
        case .vocabulary: return .blue
        case .grammar: return .purple
        case .culture: return .green
        case .tip: return .yellow
        case .kanji: return .red
        case .phrase: return .cyan
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.15) : Color(.systemGray6))
            )
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1.5)
            )
            .foregroundStyle(isSelected ? color : .secondary)
        }
    }
}

#Preview {
    FeedView()
}
