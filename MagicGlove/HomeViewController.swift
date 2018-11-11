import UIKit
import CoreBluetooth
import CoreLocation
import AVFoundation

class HomeViewController: UIViewController {

    @IBOutlet private weak var buttonMic: UIButton!

    var audioPlayer = AVAudioPlayer()

    let magic = MagicGlove(with: 1, languageIdentifier: "pt_BR")
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButton()
        serial = BluetoothSerial(delegate: self)
        magic.delegate = self
        locationManager.delegate = self

        locationManager.requestAlwaysAuthorization()
    }

    @IBAction func beep(_ sender: Any) {
        serial.sendMessageToDevice("1")
    }

    private func setupButton() {
        buttonMic.layer.cornerRadius = buttonMic.bounds.width / 2
        buttonMic.layer.borderColor = UIColor.white.cgColor
        buttonMic.layer.borderWidth = 3
    }

    @IBAction func didTouchRecord(_ sender: Any) {
        if buttonMic.isSelected {
            return
        }

        buttonMic.isSelected = true
        buttonMic.backgroundColor = .white

        playSound(file: "beep", ext: "mp3")

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

    private func playSound(file: String, ext: String) {
        do {
            let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: file, ofType: ext)!)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
}

extension HomeViewController: BluetoothSerialDelegate {
    func serialDidReceiveString(_ message: String) {
        if message == "Giozinho" {
            serial.sendMessageToDevice("e")
            serial.stopScan()
        }

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
        if !serial.isScanning {
            return
        }

        if let beacon = beacons.first {
            if beacon.proximity == .immediate {
                serial.sendMessageToDevice("1")
            } else {
                serial.sendMessageToDevice("0")
            }
        }
    }

}

extension HomeViewController: MagicGloveDelegate {

    func didFinishCommand(text: String) {
        var message = ""

        if Sentences.Search.stopSearch.contains(text) {
            magic.feedback("De nada!")

            serial.stopScan()

            buttonMic.isSelected = false
            buttonMic.backgroundColor = .clear
            return
        }

        if !serial.isScanning {
            serial.startScan()
        }

        if let item = Item.search(text) {
            message = "Procurando por \(item)"
        } else {
            message = "Não entendi bosta nenhuma seu vacilão"
            serial.stopScan()

        }

        magic.feedback(message)

        buttonMic.isSelected = false
        buttonMic.backgroundColor = .clear
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
