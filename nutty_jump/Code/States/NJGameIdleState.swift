//
//  NJGameIdleState.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import GameplayKit

class TTGameIdleState: GKState {
    weak var scene: TTGameScene?
    weak var context: TTGameContext?
    
    init(scene: TTGameScene, context: TTGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        print("did enter idle state")
    }
}
