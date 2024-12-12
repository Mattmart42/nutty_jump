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
    private var resultNode: SKSpriteNode
    private var currentDisplayedType: CollectibleType?

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
            if index == 0 { node.position = CGPoint(x: 70, y: 0) }
            if index == 1 { node.position = CGPoint(x: 145, y: 0) }
            if index == 2 { node.position = CGPoint(x: 215, y: 0) }
            return node
        }

        // Initialize resultNode
        self.resultNode = SKSpriteNode(texture: defaultCollectible.texture, size: defaultCollectible.size(for: self.info))
        self.resultNode.position = info.resultPos
        self.resultNode.isHidden = true // Hidden by default

        super.init()
        
        // Add nodes to the scene
        powerUpNodes.forEach { addChild($0) }
        addChild(resultNode)
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
        
        // Update resultNode if collectible type changes
        if currentDisplayedType != collectibleType {
            currentDisplayedType = collectibleType
            resultNode.texture = collectibleType.resultTexture
            resultNode.size = collectibleType.size(for: info)
            resultNode.isHidden = false
        }
    }
    
    func resetDisplay() {
        // Reset powerUpNodes
        powerUpNodes.forEach {
            $0.texture = defaultCollectible.texture
            $0.size = defaultCollectible.size(for: info)
            $0.isHidden = false
        }

        // Reset resultNode
        resultNode.texture = defaultCollectible.texture
        resultNode.size = defaultCollectible.size(for: info)
        resultNode.isHidden = true
        currentDisplayedType = nil
    }
}


//let resultNode = SKSpriteNode()
//resultNode.texture = collectibleType.resultTexture
//resultNode.size = collectibleType.size(for: info)
//resultNode.position = info.resultPos

class NJEquationNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .gray, size: size)
        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
