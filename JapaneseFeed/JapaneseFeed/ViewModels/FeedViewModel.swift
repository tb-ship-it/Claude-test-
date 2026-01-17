import Foundation
import SwiftUI

@Observable
class FeedViewModel {
    var posts: [Post] = []
    var selectedCategory: PostCategory? = nil
    var isRefreshing = false

    init() {
        loadPosts()
    }

    func loadPosts() {
        posts = JapaneseContent.posts
    }

    var filteredPosts: [Post] {
        if let category = selectedCategory {
            return posts.filter { $0.category == category }
        }
        return posts
    }

    func toggleLike(for post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isLiked.toggle()
            posts[index].likes += posts[index].isLiked ? 1 : -1
        }
    }

    func toggleBookmark(for post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isBookmarked.toggle()
        }
    }

    func refresh() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loadPosts()
        isRefreshing = false
    }

    func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
