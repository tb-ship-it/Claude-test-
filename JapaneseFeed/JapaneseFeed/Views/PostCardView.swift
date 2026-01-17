import SwiftUI

struct PostCardView: View {
    let post: Post
    @Bindable var viewModel: FeedViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            contentSection
            if post.japaneseText != nil {
                japaneseSection
            }
            actionBar
        }
        .padding(16)
        .background(Color(.systemBackground))
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            categoryIcon

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(post.category.rawValue)
                        .font(.system(size: 15, weight: .semibold))

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.blue)
                }

                Text(viewModel.formatTimestamp(post.timestamp))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Menu {
                Button {
                    viewModel.toggleBookmark(for: post)
                } label: {
                    Label(
                        post.isBookmarked ? "Remove Bookmark" : "Bookmark",
                        systemImage: post.isBookmarked ? "bookmark.slash" : "bookmark"
                    )
                }

                Button {
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
        }
    }

    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(categoryColor.opacity(0.15))
                .frame(width: 44, height: 44)

            Image(systemName: post.category.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(categoryColor)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)

            Text(post.content)
                .font(.system(size: 15))
                .foregroundStyle(.primary.opacity(0.85))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
        }
    }

    @ViewBuilder
    private var japaneseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if let japanese = post.japaneseText {
                    Text(japanese)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(categoryColor)
                }

                Spacer()
            }

            if let romaji = post.romaji {
                Text(romaji)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            if let english = post.englishTranslation {
                Text(english)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(categoryColor.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(categoryColor.opacity(0.15), lineWidth: 1)
        )
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            actionButton(
                icon: post.isLiked ? "heart.fill" : "heart",
                count: post.likes,
                color: post.isLiked ? .red : .secondary
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleLike(for: post)
                }
            }

            Spacer()

            actionButton(
                icon: "bubble.right",
                count: nil,
                color: .secondary
            ) {
            }

            Spacer()

            actionButton(
                icon: "arrow.2.squarepath",
                count: nil,
                color: .secondary
            ) {
            }

            Spacer()

            actionButton(
                icon: post.isBookmarked ? "bookmark.fill" : "bookmark",
                count: nil,
                color: post.isBookmarked ? .orange : .secondary
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleBookmark(for: post)
                }
            }
        }
        .padding(.top, 4)
    }

    private func actionButton(icon: String, count: Int?, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))

                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 13, weight: .medium))
                }
            }
            .foregroundStyle(color)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
    }

    private var categoryColor: Color {
        switch post.category {
        case .vocabulary: return .blue
        case .grammar: return .purple
        case .culture: return .green
        case .tip: return .yellow
        case .kanji: return .red
        case .phrase: return .cyan
        }
    }
}

#Preview {
    PostCardView(post: JapaneseContent.posts[0], viewModel: FeedViewModel())
}
