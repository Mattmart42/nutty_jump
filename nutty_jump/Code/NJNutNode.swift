//
//  NJNutNode.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 11/15/24.
//

import SpriteKit

class NJNutNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .brown, size: size)
        self.position = position
        let circularSize = CGSize(width: size.width, height: size.width)
        self.size = circularSize
        let radius = circularSize.width / 2.0
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.nut
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
