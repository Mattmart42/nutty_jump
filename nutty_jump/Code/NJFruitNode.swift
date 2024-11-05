//
//  NJFruitNode.swift
//  nutty_jump
//
//  Created by Sarah Benedicto on 10/31/24.
//

import SpriteKit

class NJFruitNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint) {
        super.init(texture: nil, color: .yellow, size: size)
        self.position = position
        let circularSize = CGSize(width: size.width, height: size.width)
        // Use width for height to maintain a circle
        self.size = circularSize
        let radius = circularSize.width / 2.0
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.player
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.wall
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dropFromTop(screenWidth: CGFloat, screenHeight: CGFloat) {
        self.position.x = CGFloat.random(in: 0...screenWidth)
        self.position.y = screenHeight + self.size.height

        // Create the downward movement action
        let dropDuration = TimeInterval.random(in: 1.0...3.0)
        let dropAction = SKAction.moveTo(y: -self.size.height, duration: dropDuration)
        
        // Run the action and remove node after it exits screen
        self.run(dropAction) { [weak self] in
            self?.removeFromParent()
        }
    }
}
