//
//  NJJumpingState.swift
//  nutty_jump
//
//  Created by matt on 10/29/24.
//

import GameplayKit
import CoreHaptics
import AVFoundation

class NJJumpingState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    private var audioPlayer: AVAudioPlayer?
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJFallingState.self || stateClass == NJRunningState.self || stateClass == NJHawkState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let scene else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
        //print("did enter jumping state")
        
        scene.animatePlayerBasedOnState()
        playJumpingSound()
    }
    
    private func playJumpingSound() {
        guard let scene else { return }
        scene.run(SKAction.playSoundFileNamed("NJSword.m4a", waitForCompletion: false))
    }
}
