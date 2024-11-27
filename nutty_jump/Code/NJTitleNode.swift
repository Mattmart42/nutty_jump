//
//  NJTitleNode.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 11/26/24.
//

import SpriteKit

class NJTitleNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .blue, size: size)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
