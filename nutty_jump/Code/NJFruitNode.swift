//
//  NJFruitNode.swift
//  nutty_jump
//
//  Created by Sarah Benedicto on 10/31/24.
//

import SpriteKit

class NJFruitNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .yellow, size: size)
        self.position = position
        let circularSize = CGSize(width: size.width, height: size.width)
        self.size = circularSize
        let radius = circularSize.width / 2.0
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.fruit
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dropFromTop(screenWidth: CGFloat, screenHeight: CGFloat) {
        self.position.x = CGFloat.random(in: 0...screenWidth)
        self.position.y = screenHeight + self.size.height

        let dropDuration = TimeInterval.random(in: 1.0...3.0)
        let dropAction = SKAction.moveTo(y: -self.size.height, duration: dropDuration)
        
        self.run(dropAction) { [weak self] in
            self?.removeFromParent()
        }
    }
}

class NJFruitShootNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .yellow, size: size)
        self.position = position
        let circularSize = CGSize(width: size.width, height: size.width)
        self.size = circularSize
        let radius = circularSize.width / 2.0
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.shoot
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.fruit | NJPhysicsCategory.hawk | NJPhysicsCategory.fox | NJPhysicsCategory.bomb
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dropFromTop(screenWidth: CGFloat, screenHeight: CGFloat) {
        self.position.x = CGFloat.random(in: 0...screenWidth)
        self.position.y = screenHeight + self.size.height

        let dropDuration = TimeInterval.random(in: 1.0...3.0)
        let dropAction = SKAction.moveTo(y: -self.size.height, duration: dropDuration)
        
        self.run(dropAction) { [weak self] in
            self?.removeFromParent()
        }
    }
}
