import UIKit
import AVKit
import CoreBluetooth
import CoreLocation

class HomeViewController: UIViewController {

    let magic = MagicGlove(with: 1, languageIdentifier: "pt_BR")
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        serial = BluetoothSerial(delegate: self)
        magic.delegate = self
        locationManager.delegate = self

        locationManager.requestAlwaysAuthorization()
    }

    @IBAction func didTouchRecord(_ sender: Any) {
        magic.startRecognition()
    }

    private func startMonitoring(beacon: Beacon) {
        let beaconRegion = beacon.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }

    private func stopMonitoring(beacon: Beacon) {
        let beaconRegion = beacon.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
}

extension HomeViewController: BluetoothSerialDelegate {
    func serialDidReceiveString(_ message: String) {
        print(message)
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

    func serialDidConnect(_ peripheral: CBPeripheral) {
        print(peripheral)
    }

    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Fail")
    }

    func serialIsReady(_ peripheral: CBPeripheral) {
        startMonitoring(beacon: Beacon(name: "bico", uuid: "86e55c38-7b7a-4b8f-b869-0e5c12cde3a9", major: 0, minor: 0))
    }

}

extension HomeViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)

        if let beacon = beacons.first {
            if beacon.proximity == .immediate {
                serial.sendMessageToDevice("1")
            }
        }
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
        utterance.volume = 1.0

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
