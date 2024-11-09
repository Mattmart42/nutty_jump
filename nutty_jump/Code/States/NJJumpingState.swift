//
//  NJJumpingState.swift
//  nutty_jump
//
//  Created by matt on 10/29/24.
//

import GameplayKit

class NJJumpingState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJFallingState.self || stateClass == NJRunningState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("did enter jumping state")
    }
    
    func handleTouch(_ touch: UITouch) {
        guard let scene else { return }
        
        let currentPlayerPos = scene.player?.position ?? .zero
        scene.togglePlayerLocation(currentPlayerPos: currentPlayerPos)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let scene, let context else { return }

        let currentPlayerPos = scene.player?.position
        let targetPos = scene.player?.position == scene.rightWallPlayerPos
            ? scene.leftWallPlayerPos
            : scene.rightWallPlayerPos
        
        if currentPlayerPos == targetPos {
            context.stateMachine?.enter(NJRunningState.self)
        }
    }
}
