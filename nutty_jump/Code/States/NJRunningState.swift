//
//  NJRunningState.swift
//  nutty_jump
//
//  Created by matt on 10/29/24.
//

import GameplayKit
import AVFoundation

class NJRunningState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    private var audioPlayer: AVAudioPlayer?
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJFallingState.self || stateClass == NJJumpingState.self || stateClass == NJPauseState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let scene else { return }
        print("did enter running state")
        
        scene.animatePlayerBasedOnState()
        playRunningSound()
    }
    
    private func playRunningSound() {
        guard let runningSoundURL = Bundle.main.url(forResource: "Running", withExtension: "mp3") else {
            print("Failed to find Running.mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: runningSoundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely if the sound should continue
            audioPlayer?.play()
        } catch {
            print("Failed to play running sound: \(error)")
        }
    }
    
    override func willExit(to nextState: GKState) {
        audioPlayer?.stop() // Stop the running sound when exiting the state
    }
}
