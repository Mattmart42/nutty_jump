//
//  NJGroundNode.swift
//  nutty_jump
//
//  Created by matt on 11/5/24.
//

import SpriteKit

class NJGroundNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint) {
        super.init(texture: nil, color: .clear, size: size)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.ground
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.player | NJPhysicsCategory.foxBranch
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
