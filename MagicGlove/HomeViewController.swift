import UIKit
import AVKit
import CoreBluetooth

class HomeViewController: UIViewController {

    let magic = MagicGlove(with: 1, languageIdentifier: "pt_BR")

    override func viewDidLoad() {
        super.viewDidLoad()

        serial = BluetoothSerial(delegate: self)
        magic.delegate = self

    }

    @IBAction func didTouchRecord(_ sender: Any) {
        magic.startRecognition()
    }
}

extension HomeViewController: BluetoothSerialDelegate {
    func serialDidReceiveString(_ message: String) {
        print(message)
    }

    func serialDidReceiveData(_ data: Data) {
        print(data)
    }

    func serialDidReceiveBytes(_ bytes: [UInt8]) {
        print("bytes")
    }

    func serialDidChangeState() {
        print(serial.centralManager.state)

        serial.startScan()
    }

    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("\(peripheral) - \(error)")
    }

    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        print("\(peripheral) - \(RSSI)")

        serial.connectToPeripheral(peripheral)
    }

    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Fail")
    }

    func serialIsReady(_ peripheral: CBPeripheral) {
        serial.sendMessageToDevice("1")
    }

}

extension HomeViewController: MagicGloveDelegate {

    func didFinishCommand(text: String) {
        var message = ""

        if let item = Item.search(text) {
            message = "Procurando por \(item)"
        } else {
            message = "Não entendi o seu vacilão"
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
