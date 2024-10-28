//
//  NJGameScene.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import SpriteKit
import GameplayKit

class NJGameScene: SKScene {
    weak var context: NJGameContext?
    
    var box: NJBoxNode?
    
    init(context: NJGameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard let context else {
            return
        }
        
        prepareGameContext()
        prepareStartNodes()
        
        context.stateMachine?.enter(NJGameIdleState.self)
    }
    
    func prepareGameContext() {
        guard let context else {
            return
        }

        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func prepareStartNodes() {
        guard let context else {
            return
        }
        let center = CGPoint(x: size.width / 2.0 - context.layoutInfo.boxSize.width / 2.0,
                             y: size.height / 2.0)
        let box = NJBoxNode()
        box.setup(screenSize: size, layoutInfo: context.layoutInfo)
        box.position = center
        addChild(box)
        self.box = box
    }
      //........
}
