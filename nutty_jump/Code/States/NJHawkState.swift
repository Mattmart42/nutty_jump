//
//  NJHawkState.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 11/30/24.
//

import GameplayKit
import AVFoundation

class NJHawkState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    private var audioPlayer: AVAudioPlayer?
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJRunningState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let scene, let player = scene.player else { return }
        print("did enter hawk state")
        scene.info.playerIsInvincible = true
        scene.animatePlayerBasedOnState()
        playHawkPowerup()
    }
    
    private func playHawkPowerup() {
        guard let hawkPowerupSoundURL = Bundle.main.url(forResource: "HawkPowerup", withExtension: "m4a") else {
            print("Failed to find HawkPowerup.m4a")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: hawkPowerupSoundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play hawk powerup sound: \(error)")
        }
    }
}
