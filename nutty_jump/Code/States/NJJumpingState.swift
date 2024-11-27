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
        guard let scene, let player = scene.player else { return }
        
        player.size = NJGameInfo.playerFlightSize
        
        if Int(player.position.x) == Int(scene.rightWallPlayerPos.x) {
            print("player about to jump to left side and got fly left")
            player.texture = SKTexture(imageNamed: "squirrelFlyLeft")
            
        } else if Int(player.position.x) == Int(scene.leftWallPlayerPos.x) {
            print("player about to jump to right side and got fly right")
            player.texture = SKTexture(imageNamed: "squirrelFlyRight")
        }
    }
    
//    func handleTouch(_ touch: UITouch) {
//        guard let scene, let context, let player = scene.player else { return }
//        
//        let currentPlayerPos = player.position
//        scene.togglePlayerLocation(currentPlayerPos: currentPlayerPos)
//        context.stateMachine?.enter(NJRunningState.self)
//    }
    
    override func update(deltaTime seconds: TimeInterval) {
//        guard let scene, let context else { return }
//
//        let currentPlayerPos = scene.player?.position
//        let targetPos = scene.player?.position == scene.rightWallPlayerPos
//            ? scene.leftWallPlayerPos
//            : scene.rightWallPlayerPos
//        
//        if currentPlayerPos == targetPos {
//            context.stateMachine?.enter(NJRunningState.self)
//        }
    }
}
