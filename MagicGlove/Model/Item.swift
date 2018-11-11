struct Item {
    let name: String
    let id: Int

    static let cachedItems: [Item] = [Item(name: "pote de arroz", id: 0),
                                      Item(name: "pote de feijão", id: 1),
                                      Item(name: "garrafa", id: 2),
                                      Item(name: "pote de farinha", id: 3)]

    static func search(_ sentence: String) -> Item? {
        var result = [Item]()

        self.cachedItems.forEach {
            if sentence.contains($0.name) {
                result.append($0)
            }
        }

        let sentences = Sentences.Search.searchSentences.map { $0.replacingOccurrences(of: "%@", with: result.first?.name ?? "").lowercased() }

        let finalResult = sentences.filter { $0.levenshtein(sentence.tokenizedSentence()) < 10 }.first

        if finalResult != nil {
            return result.first
        } else {
            return nil
        }
    }
}
