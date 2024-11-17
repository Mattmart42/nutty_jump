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
    
    func runAcross(screenWidth: CGFloat) {
        // Set the target position on the opposite wall
        let targetX = position.x == 0 ? screenWidth : 0
        let targetPosition = CGPoint(x: targetX, y: position.y)
        let moveAction = SKAction.move(to: targetPosition, duration: 3.0) // Adjust speed as needed
        let removeAction = SKAction.removeFromParent()
        self.run(SKAction.sequence([moveAction, removeAction]))
    }
}
