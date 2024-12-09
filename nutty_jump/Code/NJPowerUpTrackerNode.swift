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
    private let info: NJGameInfo

    init(size: CGSize, defaultCollectible: CollectibleType) {
        self.defaultCollectible = defaultCollectible
        self.info = NJGameInfo(screenSize: UIScreen.main.bounds.size)
        
        // Temporary placeholder texture for initialization
        let placeholderTexture = defaultCollectible.texture
        let placeholderSize = defaultCollectible.size(for: self.info)

        // Initialize powerUpNodes without accessing `self.defaultCollectible` directly
        self.powerUpNodes = (0..<3).map { index in
            let node = SKSpriteNode(texture: placeholderTexture, size: placeholderSize)
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
                node.size = collectibleType.size(for: info)
                node.isHidden = false // Ensure the node is visible
            } else {
                // Keep remaining nodes with the default texture and visible
                node.texture = defaultCollectible.texture
                node.size = info.obstacleSize
                node.isHidden = false
            }
        }
    }
    
    func resetDisplay() {
        powerUpNodes.forEach {
            $0.texture = defaultCollectible.texture
            $0.size = defaultCollectible.size(for: info)
            $0.isHidden = false
        }
    }
}
