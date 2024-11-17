//
//  NJFoxBranchNode.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 11/16/24.
//

import SpriteKit

class NJFoxBranchNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .brown, size: size)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.foxBranch
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.ground
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
