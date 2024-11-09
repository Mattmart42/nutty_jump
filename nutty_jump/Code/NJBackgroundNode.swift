//
//  NJBackgroundNode.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 11/8/24.
//

import SpriteKit

class NJBackgroundNode: SKSpriteNode {
    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
}
