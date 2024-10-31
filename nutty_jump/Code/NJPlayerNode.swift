//
//  NJPlayerNode.swift
//  nutty_jump
//
//  Created by keckuser on 10/29/24.
//

import SpriteKit

class NJPlayerNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint) {
        super.init(texture: nil, color: .red, size: size)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.player
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.wall
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition() -> CGPoint {
        return self.position
    }
}
