//
//  NJOwlNode.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 12/20/24.
//

import SpriteKit

class NJOwlNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .brown, size: size)
        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
