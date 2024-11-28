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
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJFallingState.self || stateClass == NJJumpingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let scene, let player = scene.player else { return }
        print("did enter running state")
        
        player.size = scene.info.playerSize
        
        if Int(player.position.x) == Int(scene.rightWallPlayerPos.x) {
            player.texture = SKTexture(imageNamed: "squirrelRunRight")
            
        } else if Int(player.position.x) == Int(scene.leftWallPlayerPos.x) {
            player.texture = SKTexture(imageNamed: "squirrelRunLeft")
        }
    }
}
