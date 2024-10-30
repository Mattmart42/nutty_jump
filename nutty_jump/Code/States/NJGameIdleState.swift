//
//  NJGameIdleState.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import GameplayKit

class NJGameIdleState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    
    init(scene: NJGameScene, context: NJGameContext) {
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
    
    func handleTouch(_ touch: UITouch) {
        guard let scene, let context else { return }
        print("touched \(touch)")
        let touchLocation = touch.location(in: scene)
        let newBoxPos = CGPoint(x: touchLocation.x - context.layoutInfo.boxSize.width / 2.0,
                                y: touchLocation.y - context.layoutInfo.boxSize.height / 2.0)
        //scene.box?.position = newBoxPos
    }
    
    func handleTouchMoved(_ touch: UITouch) {
        guard let scene, let context else { return }
        let touchLocation = touch.location(in: scene)
        let newBoxPos = CGPoint(x: touchLocation.x - context.layoutInfo.boxSize.width / 2.0,
                                y: touchLocation.y - context.layoutInfo.boxSize.height / 2.0)
        //scene.box?.position = newBoxPos
    }
    //....
}
