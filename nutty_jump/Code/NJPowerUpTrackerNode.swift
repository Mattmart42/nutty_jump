//
//  NJPowerUpTrackerNode.swift
//  nutty_jump
//
//  Created by matt on 11/6/24.
//

import SpriteKit

class NJPowerUpTrackerNode: SKNode {
    private let powerUpNodes: [SKSpriteNode]
    
    init(size: CGSize) {
        powerUpNodes = (0..<3).map { index in
            let node = SKSpriteNode(color: .clear, size: size)
            node.isHidden = true
            node.position = CGPoint(x: CGFloat(index) * (size.width + 10), y: 0)
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
            node.isHidden = index >= count
            node.texture = collectibleType.texture
            node.size = collectibleType.size
        }
    }
    
    func resetDisplay() {
        powerUpNodes.forEach { $0.isHidden = true; $0.color = .clear }
    }
}

extension NJPowerUpTrackerNode {
    enum Constants {
        static let size = CGSize(width: 45, height: 45)
    }
}
