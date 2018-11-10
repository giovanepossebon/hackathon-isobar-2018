import UIKit
import AVKit

class HomeViewController: UIViewController {

    let magic = MagicGlove(with: 1, languageIdentifier: "pt_BR")

    override func viewDidLoad() {
        super.viewDidLoad()

        magic.delegate = self
    }

    @IBAction func didTouchRecord(_ sender: Any) {
        magic.startRecognition()
    }
}

extension HomeViewController: MagicGloveDelegate {

    func didFinishCommand(text: String) {
        var message = ""

        if let item = Item.search(text) {
            message = "Procurando por \(item)"
        } else {
            message = "Não entendi ô vacilão"
        }

        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")

        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }

    func recognizedSpeech(text: String) {
        print("recognizedSppech: \(text)")
    }

    func didStartRecording() {
         print("didStartRecording")
    }

    func didEndRecording() {
        print("didEndRecording")
    }

    func didPauseRecording() {
        print("didPauseRecording")
    }
}
