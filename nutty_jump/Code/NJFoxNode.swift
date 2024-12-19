//
//  NJFoxNode.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 11/16/24.
//

import SpriteKit

class NJFoxNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .orange, size: size)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.fox
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
