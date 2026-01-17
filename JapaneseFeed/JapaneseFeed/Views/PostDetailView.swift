import SwiftUI

struct PostDetailView: View {
    let post: Post
    @Bindable var viewModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                if let japanese = post.japaneseText {
                    japaneseHighlight(japanese)
                }

                contentSection

                if post.romaji != nil || post.englishTranslation != nil {
                    translationSection
                }

                actionBar

                relatedSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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

                    Button {
                    } label: {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: post.category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(post.category.rawValue)
                        .font(.system(size: 17, weight: .semibold))

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                }

                Text(formattedDate)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }

    private func japaneseHighlight(_ text: String) -> some View {
        VStack(spacing: 12) {
            Text(text)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(categoryColor)
                .multilineTextAlignment(.center)

            if let romaji = post.romaji {
                Text(romaji)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [categoryColor.opacity(0.1), categoryColor.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(categoryColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.title)
                .font(.system(size: 22, weight: .bold))

            Text(post.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary.opacity(0.85))
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }

    @ViewBuilder
    private var translationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Translation & Reading", systemImage: "character.book.closed")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            if let romaji = post.romaji {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Romaji")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(romaji)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
            }

            if let english = post.englishTranslation {
                VStack(alignment: .leading, spacing: 4) {
                    Text("English")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(english)
                        .font(.system(size: 16))
                        .italic()
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            actionButton(
                icon: post.isLiked ? "heart.fill" : "heart",
                label: "\(post.likes)",
                color: post.isLiked ? .red : .secondary
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleLike(for: post)
                }
            }

            actionButton(
                icon: "bubble.right",
                label: "Comment",
                color: .secondary
            ) {
            }

            actionButton(
                icon: post.isBookmarked ? "bookmark.fill" : "bookmark",
                label: "Save",
                color: post.isBookmarked ? .orange : .secondary
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleBookmark(for: post)
                }
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(color)
        }
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More \(post.category.rawValue)")
                .font(.system(size: 17, weight: .semibold))

            let relatedPosts = viewModel.posts.filter { $0.category == post.category && $0.id != post.id }.prefix(3)

            ForEach(Array(relatedPosts)) { relatedPost in
                NavigationLink(value: relatedPost) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.opacity(0.1))
                                .frame(width: 36, height: 36)

                            Image(systemName: relatedPost.category.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(categoryColor)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(relatedPost.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            if let japanese = relatedPost.japaneseText {
                                Text(japanese)
                                    .font(.system(size: 13))
                                    .foregroundStyle(categoryColor)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
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

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: post.timestamp)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: JapaneseContent.posts[0], viewModel: FeedViewModel())
    }
}
