//
//  NJGroundNode.swift
//  nutty_jump
//
//  Created by keckuser on 11/5/24.
//

import SpriteKit

class NJGroundNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint) {
        super.init(texture: nil, color: .red, size: size)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.ground
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}