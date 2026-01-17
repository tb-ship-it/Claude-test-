import Foundation

struct Post: Identifiable, Hashable {
    let id: UUID
    let category: PostCategory
    let title: String
    let content: String
    let japaneseText: String?
    let romaji: String?
    let englishTranslation: String?
    let timestamp: Date
    var likes: Int
    var isLiked: Bool
    var isBookmarked: Bool

    init(
        id: UUID = UUID(),
        category: PostCategory,
        title: String,
        content: String,
        japaneseText: String? = nil,
        romaji: String? = nil,
        englishTranslation: String? = nil,
        timestamp: Date = Date(),
        likes: Int = 0,
        isLiked: Bool = false,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.content = content
        self.japaneseText = japaneseText
        self.romaji = romaji
        self.englishTranslation = englishTranslation
        self.timestamp = timestamp
        self.likes = likes
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
    }
}

enum PostCategory: String, CaseIterable {
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case culture = "Culture"
    case tip = "Tip"
    case kanji = "Kanji"
    case phrase = "Phrase"

    var icon: String {
        switch self {
        case .vocabulary: return "text.book.closed"
        case .grammar: return "text.alignleft"
        case .culture: return "globe.asia.australia"
        case .tip: return "lightbulb"
        case .kanji: return "character.ja"
        case .phrase: return "quote.bubble"
        }
    }

    var color: String {
        switch self {
        case .vocabulary: return "VocabularyColor"
        case .grammar: return "GrammarColor"
        case .culture: return "CultureColor"
        case .tip: return "TipColor"
        case .kanji: return "KanjiColor"
        case .phrase: return "PhraseColor"
        }
    }
}
