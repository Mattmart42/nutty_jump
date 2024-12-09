//
//  NJHawkState.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 11/30/24.
//

import GameplayKit

class NJHawkState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    
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
        player.texture = scene.info.playerIsProtected ? SKTexture(imageNamed: "hawkMode") : SKTexture(imageNamed: "hawkMode")
        player.size = scene.info.hawkModeSize
    }
}
