//
//  NJHawkNode.swift
//  nutty_jump
//
//  Created by Sarah Benedicto on 10/31/24.
//

import SpriteKit

class NJHawkNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .brown, size: size)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.hawk
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dropDiagonally(screenWidth: CGFloat, screenHeight: CGFloat) {
        // Start position at a random x position near the top of the screen
        self.position.x = CGFloat.random(in: 0...screenWidth)
        self.position.y = screenHeight + self.size.height

        // Determine a random x destination at the bottom edge
        let endX = CGFloat.random(in: 0...screenWidth)
        let endY = -self.size.height

        // Create a diagonal movement action
        let dropDuration = TimeInterval.random(in: 1.0...3.0)
        let dropAction = SKAction.move(to: CGPoint(x: endX, y: endY), duration: dropDuration)
        
        // Run the action and remove node after it exits the screen
        self.run(dropAction) { [weak self] in
            self?.removeFromParent()
        }
    }
}
