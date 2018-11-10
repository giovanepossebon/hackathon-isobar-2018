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
