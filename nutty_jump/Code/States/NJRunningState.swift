//
//  NJRunningState.swift
//  nutty_jump
//
//  Created by matt on 10/29/24.
//

import GameplayKit

class NJRunningState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    
    private var isTouchingLeftWall: Bool = false
    private var isTouchingRightWall: Bool = false
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJFallingState.self || stateClass == NJJumpingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("did enter running state")
    }
    
    func handleTouch(_ touch: UITouch) {
        guard let scene else { return }
        
        let currentPlayerPos = scene.player?.position ?? .zero
        scene.togglePlayerLocation(currentPlayerPos: currentPlayerPos)
        print("Handled touch in NJRunningState")
    }
    
    
}
