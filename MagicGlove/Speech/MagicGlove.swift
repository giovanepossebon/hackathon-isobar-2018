import Foundation
import Speech
import AVKit

protocol MagicGloveDelegate: class {
    func didFinishCommand(text: String)
    func recognizedSpeech(text: String)
    func didStartRecording()
    func didEndRecording()
    func didPauseRecording()
}

final class MagicGlove: NSObject {

    var isListening: Bool = false

    weak var delegate: MagicGloveDelegate?
    private var speechInterval: TimeInterval = 2
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var lastRecognizedDate = Date()
    private var speechTimer: Timer!
    let audioSession = AVAudioSession.sharedInstance()
    private var languageIdentifier: String!
    private var candidateText = "" {
        didSet {
            lastRecognizedDate = Date()
        }
    }

    var shouldPause = true

    init(with speechInterval: TimeInterval, languageIdentifier: String) {
        self.speechInterval = speechInterval
        self.languageIdentifier = languageIdentifier
        super.init()

        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }

    private func setupAudioEngine() {
        request = SFSpeechAudioBufferRecognitionRequest()
        audioEngine.inputNode.removeTap(onBus: 0)
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: languageIdentifier))
        speechRecognizer?.delegate = self
    }

    func startRecognition() {
        setupAudioEngine()

        isListening = true
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    break
                default:
                    print(authStatus)
                }
            }
        }
        try? startRecording()
    }

    func stopRecognition() {
        stopRecording()
    }

    func startRecording() throws {
        if !audioEngine.isRunning {
            audioEngine.prepare()
            try audioEngine.start()
        }

        startSpeechTimer()
        delegate?.didStartRecording()
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                let resultText = result.bestTranscription.formattedString.lowercased()
                guard resultText.isEmpty == false else { return }
                self?.delegate?.recognizedSpeech(text: resultText)
                self?.candidateText = resultText
            }
        }
    }

    private func startSpeechTimer() {
        speechTimer = Timer.scheduledTimer(timeInterval: speechInterval, target: self, selector: #selector(stillTalkingCheck), userInfo: nil, repeats: true)
    }

    @objc private func stillTalkingCheck() {
        let currentDate = Date()
        let secondsOfSilence = currentDate.timeIntervalSince(lastRecognizedDate)
        if (secondsOfSilence > TimeInterval(speechInterval) && candidateText != "") {
            var finalSentence = tokenizedSentence(candidateText)
            if finalSentence.isEmpty {
                finalSentence = candidateText
            }

            candidateText = ""
            if shouldPause {
                stopRecording()
                delegate?.didFinishCommand(text: finalSentence)
            }
        }
    }

    private func pauseRecording() {
        request.endAudio()
        speechTimer.invalidate()
        recognitionTask?.cancel()
        delegate?.didPauseRecording()
    }

    private func stopRecording() {
        isListening = false
        audioEngine.stop()
        speechTimer.invalidate()
        request.endAudio()
        recognitionTask?.cancel()
        delegate?.didEndRecording()
    }

    private func tokenizedSentence(_ sentence: String) -> String {
        return sentence
    }

    func feedback(_ text: String, language: String = "pt-BR") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)

        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
}

extension MagicGlove: SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("SpeechRecognizer available: \(available)")
    }

    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionDidDetectSpeech")
    }

    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskFinishedReadingAudio")
    }

    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskWasCancelled")
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("didFinishSuccessfully")
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didRecord audioPCMBuffer: AVAudioPCMBuffer) {
        print("didRecord")
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("didHypothesizeTranscription")
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("didFinishRecognition")
    }
}

