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

        let sentences = Sentences.Busca.searchSentences.map { $0.replacingOccurrences(of: "%@", with: result.first?.name ?? "").lowercased() }

        let finalResult = sentences.filter { $0.levenshtein(sentence.tokenizedSentence()) < 6 }.first

        if finalResult != nil {
            return result.first?.name
        } else {
            return nil
        }
    }
}

struct Sentences {

    struct Busca {
        static let searchSentences = ["Quero encontrar %@",
                                      "Quero achar %@",
                                      "Quero encontrar %@",
                                      "Me ajuda achar %@",
                                      "Me mostra onde está %@",
                                      "Cadê %@",
                                      "Cadê meu %@",
                                      "Cadê minha %@",
                                      "Onde está %@",
                                      "Onde deixei %@",
                                      "Onde ficou %@",
                                      "Onde é que está %@",
                                      "Não sei onde deixei %@",
                                      "Não lembro onde deixei %@",
                                      "Me diz onde ficou %@",
                                      "A %@ cadê?",
                                      "Não consigo achar %@"]
    }

}

import Speech
extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }

    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }

    func tokenizedSentence() -> String {
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "pt")
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        tagger.string = self
        var expectedWords = ""
        let range = NSMakeRange(0, self.count)
        tagger.enumerateTags(in: range, scheme: .nameTypeOrLexicalClass, options: options) { (tag,tokenRange, _, _) in
            guard let tag = tag else { return }
            let token = (self as NSString).substring(with: tokenRange)
            switch tag {
            case .determiner:
                break
            default: expectedWords += " \(token)"
            }
        }

        return expectedWords
    }
}
