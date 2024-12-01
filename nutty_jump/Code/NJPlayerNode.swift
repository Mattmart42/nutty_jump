//
//  NJPlayerNode.swift
//  nutty_jump
//
//  Created by matt on 10/29/24.
//

import SpriteKit

class NJPlayerNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .red, size: size)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = NJPhysicsCategory.player
        self.physicsBody?.contactTestBitMask = NJPhysicsCategory.ground | NJPhysicsCategory.hawk | NJPhysicsCategory.fruit | NJPhysicsCategory.fox | NJPhysicsCategory.nut | NJPhysicsCategory.bomb | NJPhysicsCategory.branch
        self.physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition() -> CGPoint {
        return self.position
    }
    
    func toggleGravity() {
        let current = self.physicsBody?.affectedByGravity
        self.physicsBody?.affectedByGravity = !current!
    }
}
