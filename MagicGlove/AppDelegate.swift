//
//  AppDelegate.swift
//  MagicGlove
//
//  Created by Giovane Possebon on 10/11/18.
//  Copyright © 2018 possebon. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var audioPlayer = AVAudioPlayer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        playSound(file: "welcome", ext: "mp3")

        return true
    }

    func playSound(file: String, ext: String) {
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


