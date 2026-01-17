import Foundation

struct JapaneseContent {
    static let posts: [Post] = [
        Post(
            category: .vocabulary,
            title: "Word of the Day: Beautiful",
            content: "The word 'utsukushii' is one of the most elegant ways to express beauty in Japanese. It's often used to describe natural scenery, art, and profound aesthetic experiences. Unlike 'kirei' which is more casual, 'utsukushii' carries a deeper, more poetic connotation.",
            japaneseText: "美しい",
            romaji: "utsukushii",
            englishTranslation: "beautiful, lovely",
            timestamp: Date().addingTimeInterval(-3600),
            likes: 142
        ),

        Post(
            category: .grammar,
            title: "The Particle 'wa' vs 'ga'",
            content: "One of the trickiest aspects of Japanese grammar! Use 'wa' (は) to mark the topic of your sentence - what you're talking about. Use 'ga' (が) to mark the subject - who or what performs the action. Think of 'wa' as 'as for...' and 'ga' as emphasizing new or important information.",
            japaneseText: "私は学生です vs 私が学生です",
            romaji: "Watashi wa gakusei desu vs Watashi ga gakusei desu",
            englishTranslation: "I am a student (topic) vs I am the student (emphasis)",
            timestamp: Date().addingTimeInterval(-7200),
            likes: 89
        ),

        Post(
            category: .kanji,
            title: "Kanji Breakdown: 食",
            content: "This kanji means 'eat' or 'food'. It's composed of a roof/cover radical on top (representing shelter) and 良 (good) below, though modified. The idea is that good things are found under a roof - namely, food! You'll see this in words like 食べる (taberu - to eat) and 食事 (shokuji - meal).",
            japaneseText: "食",
            romaji: "shoku / ta(beru)",
            englishTranslation: "eat, food",
            timestamp: Date().addingTimeInterval(-10800),
            likes: 203
        ),

        Post(
            category: .phrase,
            title: "Useful Phrase: Excuse Me",
            content: "This phrase is incredibly versatile! Use it to get someone's attention, apologize for minor inconveniences, say 'excuse me' when passing by, or even when entering/leaving a room. It literally means something like 'I'm being rude' but is much more casual in practice.",
            japaneseText: "すみません",
            romaji: "sumimasen",
            englishTranslation: "excuse me, I'm sorry",
            timestamp: Date().addingTimeInterval(-14400),
            likes: 167
        ),

        Post(
            category: .culture,
            title: "The Art of Bowing",
            content: "Bowing (ojigi) is fundamental to Japanese communication. There are three main types: eshaku (15°) for casual greetings, keirei (30°) for showing respect to superiors, and saikeirei (45°) for deep apology or reverence. The depth and duration convey different levels of respect and emotion.",
            japaneseText: "お辞儀",
            romaji: "ojigi",
            englishTranslation: "bow, bowing",
            timestamp: Date().addingTimeInterval(-18000),
            likes: 234
        ),

        Post(
            category: .tip,
            title: "Learning Hack: Shadowing",
            content: "Shadowing is a powerful technique where you listen to native Japanese audio and repeat it simultaneously, mimicking the pronunciation, rhythm, and intonation. Start with slower content like NHK World Easy Japanese, then progress to anime or dramas. Just 10-15 minutes daily can dramatically improve your speaking!",
            timestamp: Date().addingTimeInterval(-21600),
            likes: 312
        ),

        Post(
            category: .vocabulary,
            title: "Onomatopoeia: Rain Sounds",
            content: "Japanese has incredibly specific onomatopoeia! For rain: 'shito shito' (しとしと) is gentle, quiet rain. 'Para para' (ぱらぱら) is light, scattered drops. 'Zaa zaa' (ざあざあ) is heavy, pouring rain. These are used constantly in daily conversation and literature!",
            japaneseText: "しとしと・ぱらぱら・ざあざあ",
            romaji: "shito shito, para para, zaa zaa",
            englishTranslation: "gentle rain, light rain, heavy rain sounds",
            timestamp: Date().addingTimeInterval(-25200),
            likes: 178
        ),

        Post(
            category: .grammar,
            title: "The て-form: Your Gateway",
            content: "The て-form (te-form) is essential for connecting actions, making requests, and forming many grammatical structures. For る-verbs, drop る and add て. For う-verbs, the ending changes based on the consonant. Master this form and you unlock: requests (~てください), ongoing actions (~ている), and connecting sentences!",
            japaneseText: "食べて、飲んで、行って",
            romaji: "tabete, nonde, itte",
            englishTranslation: "eat (and), drink (and), go (and)",
            timestamp: Date().addingTimeInterval(-28800),
            likes: 256
        ),

        Post(
            category: .kanji,
            title: "Radical Study: Water 氵",
            content: "The water radical (sanzui) appears in hundreds of kanji related to liquids, emotions, and flowing things. Look for it in: 海 (umi - sea), 泳 (oyogu - swim), 涙 (namida - tears), 洗 (arau - wash), and 温 (atatakai - warm). Recognizing radicals accelerates kanji learning!",
            japaneseText: "氵(さんずい)",
            romaji: "sanzui",
            englishTranslation: "water radical",
            timestamp: Date().addingTimeInterval(-32400),
            likes: 145
        ),

        Post(
            category: .phrase,
            title: "Expressing Gratitude Levels",
            content: "Japanese has multiple ways to say thanks! 'Domo' (どうも) is super casual between friends. 'Arigatou' (ありがとう) is standard casual. 'Arigatou gozaimasu' (ありがとうございます) is polite. 'Domo arigatou gozaimasu' (どうもありがとうございます) is very polite. Match the level to the situation!",
            japaneseText: "どうも → ありがとう → ありがとうございます",
            romaji: "domo → arigatou → arigatou gozaimasu",
            englishTranslation: "thanks → thank you → thank you (polite)",
            timestamp: Date().addingTimeInterval(-36000),
            likes: 289
        ),

        Post(
            category: .culture,
            title: "Seasons in Japanese Life",
            content: "Seasons (kisetsu) deeply influence Japanese culture. Spring brings hanami (flower viewing), summer has matsuri (festivals) and fireworks, autumn features momijigari (leaf viewing), and winter brings osechi (New Year foods). Even convenience stores change their offerings seasonally!",
            japaneseText: "季節",
            romaji: "kisetsu",
            englishTranslation: "seasons",
            timestamp: Date().addingTimeInterval(-39600),
            likes: 198
        ),

        Post(
            category: .tip,
            title: "Immersion at Home",
            content: "Create a Japanese bubble without traveling! Change your phone's language to Japanese. Watch Japanese YouTube with Japanese subtitles. Listen to Japanese podcasts during commutes. Label items in your home with sticky notes. Follow Japanese accounts on social media. Small consistent exposure beats occasional intensive study!",
            timestamp: Date().addingTimeInterval(-43200),
            likes: 421
        ),

        Post(
            category: .vocabulary,
            title: "Time Words Made Easy",
            content: "Japanese time words follow patterns! Yesterday/Today/Tomorrow: kinou/kyou/ashita. Last/This/Next week: senshuu/konshuu/raishuu. Last/This/Next month: sengetsu/kongetsu/raigetsu. Last/This/Next year: kyonen/kotoshi/rainen. Notice how 'sen' = last, 'kon/ko' = this, 'rai' = next!",
            japaneseText: "昨日・今日・明日",
            romaji: "kinou, kyou, ashita",
            englishTranslation: "yesterday, today, tomorrow",
            timestamp: Date().addingTimeInterval(-46800),
            likes: 267
        ),

        Post(
            category: .grammar,
            title: "Making Polite Requests",
            content: "To ask someone to do something politely, use the て-form + ください (kudasai). 'Matte kudasai' means 'please wait'. For more casual requests with friends, you can drop ください and just use the て-form with rising intonation: 'Chotto matte?' (Wait a sec?)",
            japaneseText: "待ってください",
            romaji: "matte kudasai",
            englishTranslation: "please wait",
            timestamp: Date().addingTimeInterval(-50400),
            likes: 156
        ),

        Post(
            category: .kanji,
            title: "Numbers in Kanji",
            content: "Basic number kanji are among the simplest to learn! 一 (1), 二 (2), 三 (3) show the concept visually with horizontal lines. Then: 四 (4), 五 (5), 六 (6), 七 (7), 八 (8), 九 (9), 十 (10). Fun fact: 八 (8) is considered lucky because it widens at the bottom, suggesting growing prosperity!",
            japaneseText: "一二三四五六七八九十",
            romaji: "ichi, ni, san, shi/yon, go, roku, shichi/nana, hachi, kyuu/ku, juu",
            englishTranslation: "1, 2, 3, 4, 5, 6, 7, 8, 9, 10",
            timestamp: Date().addingTimeInterval(-54000),
            likes: 334
        ),

        Post(
            category: .phrase,
            title: "Restaurant Essentials",
            content: "Master these for dining out! 'Sumimasen' to call the server. 'Kore wo kudasai' (this please) while pointing. 'Okanjo onegaishimasu' for the check. 'Gochisousama deshita' after eating to thank for the meal. These four phrases will get you through most restaurant situations!",
            japaneseText: "お会計お願いします",
            romaji: "okanjou onegaishimasu",
            englishTranslation: "check please",
            timestamp: Date().addingTimeInterval(-57600),
            likes: 445
        ),

        Post(
            category: .culture,
            title: "The Concept of 'Wa'",
            content: "和 (wa) means harmony and is central to Japanese society. It explains why Japanese people often avoid direct confrontation, value group consensus, and read the atmosphere (kuuki wo yomu). Understanding 'wa' helps explain many aspects of Japanese communication and social behavior.",
            japaneseText: "和",
            romaji: "wa",
            englishTranslation: "harmony, peace, Japanese-style",
            timestamp: Date().addingTimeInterval(-61200),
            likes: 276
        ),

        Post(
            category: .tip,
            title: "Spaced Repetition Systems",
            content: "Use SRS apps like Anki or WaniKani for efficient memorization. The algorithm shows you cards just before you'd forget them, optimizing your study time. For vocabulary, include the word, reading, meaning, and an example sentence. Review daily - even just 10-15 minutes compounds into massive progress over months!",
            timestamp: Date().addingTimeInterval(-64800),
            likes: 367
        ),

        Post(
            category: .vocabulary,
            title: "Common Adjectives Pair",
            content: "Learn adjectives in opposite pairs for better retention! Big/Small: ookii/chiisai (大きい/小さい). Hot/Cold: atsui/samui (暑い/寒い) for weather, or atsui/tsumetai (熱い/冷たい) for objects. New/Old: atarashii/furui (新しい/古い). Good/Bad: ii/warui (いい/悪い).",
            japaneseText: "大きい ↔ 小さい",
            romaji: "ookii ↔ chiisai",
            englishTranslation: "big ↔ small",
            timestamp: Date().addingTimeInterval(-68400),
            likes: 189
        ),

        Post(
            category: .grammar,
            title: "Expressing Desire with たい",
            content: "To say you want to do something, take the verb stem (masu-form minus ます) and add たい. 'Tabemasu' becomes 'tabetai' (want to eat). 'Ikimasu' becomes 'ikitai' (want to go). Note: たい conjugates like an i-adjective, so past tense is 'tabetakatta' (wanted to eat).",
            japaneseText: "日本に行きたい",
            romaji: "nihon ni ikitai",
            englishTranslation: "I want to go to Japan",
            timestamp: Date().addingTimeInterval(-72000),
            likes: 223
        )
    ]
}
