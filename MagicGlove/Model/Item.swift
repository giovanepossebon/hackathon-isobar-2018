struct Item {
    let name: String
    let uuid: String

    static let cachedItems: [Item] = [Item(name: "pote de arroz", uuid: ""),
                                      Item(name: "pote de feijão", uuid: ""),
                                      Item(name: "garrafa", uuid: "")]

    static func search(_ sentence: String) -> String? {
        var result = [Item]()

        self.cachedItems.forEach {
            if sentence.contains($0.name) {
                result.append($0)
            }
        }

        let sentences = Sentences.Search.searchSentences.map { $0.replacingOccurrences(of: "%@", with: result.first?.name ?? "").lowercased() }

        let finalResult = sentences.filter { $0.levenshtein(sentence.tokenizedSentence()) < 6 }.first

        if finalResult != nil {
            return result.first?.name
        } else {
            return nil
        }
    }
}
