//
//  NJPowerUpTrackerNode.swift
//  nutty_jump
//
//  Created by matt on 11/6/24.
//

import SpriteKit

class NJPowerUpTrackerNode: SKNode {
    private let powerUpNodes: [SKSpriteNode]
    private var defaultCollectible: CollectibleType
    
    init(size: CGSize, defaultCollectible: CollectibleType) {
        self.defaultCollectible = defaultCollectible
        powerUpNodes = (0..<3).map { index in
            let node = SKSpriteNode(texture: defaultCollectible.texture, size: defaultCollectible.size)
            node.isHidden = false // Initially visible with default icon
            node.position = CGPoint(x: CGFloat(index) * (size.width + 40), y: 0)
            return node
        }

        super.init()

        powerUpNodes.forEach { addChild($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePowerUpDisplay(for count: Int, with collectibleType: CollectibleType) {
        for (index, node) in powerUpNodes.enumerated() {
            if index < count {
                // Replace the node's texture with the power-up's texture
                node.texture = collectibleType.texture
                node.size = collectibleType.size
                node.isHidden = false // Ensure the node is visible
            } else {
                // Keep remaining nodes with the default texture and visible
                node.texture = defaultCollectible.texture
                node.size = defaultCollectible.size
                node.isHidden = false
            }
        }
    }
    
    func resetDisplay() {
        powerUpNodes.forEach {
            $0.texture = defaultCollectible.texture
            $0.size = defaultCollectible.size
            $0.isHidden = false
        }
    }
}
