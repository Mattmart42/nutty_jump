//
//  NJPowerUpTrackerNode.swift
//  nutty_jump
//
//  Created by matt on 11/6/24.
//

import SpriteKit

class NJPowerUpTrackerNode: SKNode {
    private let powerUpNodes: [SKSpriteNode]
    private var defaultCollectible: NJCollectibleType
    private let info: NJGameInfo
    private var resultNode: SKSpriteNode
    private var currentDisplayedType: NJCollectibleType?

    init(size: CGSize, defaultCollectible: NJCollectibleType) {
        self.defaultCollectible = defaultCollectible
        let localInfo = NJGameInfo(screenSize: UIScreen.main.bounds.size)
        self.info = localInfo
        
        let placeholderTexture = defaultCollectible.texture
        let placeholderSize = defaultCollectible.size(for: self.info)

        self.powerUpNodes = (0..<3).map { index in
            let node = SKSpriteNode(texture: placeholderTexture, size: placeholderSize)
            node.isHidden = false // Initially visible with default icon
            if index == 0 { node.position = localInfo.node1Pos }
            if index == 1 { node.position = localInfo.node2Pos }
            if index == 2 { node.position = localInfo.node3Pos }
            return node
        }

        self.resultNode = SKSpriteNode(texture: defaultCollectible.texture, size: defaultCollectible.size(for: self.info))
        self.resultNode.position = info.resultPos
        self.resultNode.isHidden = true

        super.init()
        
        powerUpNodes.forEach { addChild($0) }
        addChild(resultNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePowerUpDisplay(for count: Int, with collectibleType: NJCollectibleType) {
        for (index, node) in powerUpNodes.enumerated() {
            if index < count {
                node.texture = collectibleType.texture
                node.size = collectibleType.size(for: info)
                node.isHidden = false
            } else {
                node.texture = defaultCollectible.texture
                node.size = info.defaultSize
                node.isHidden = false
            }
        }
        
        if currentDisplayedType != collectibleType {
            currentDisplayedType = collectibleType
            resultNode.texture = collectibleType.resultTexture
            resultNode.size = collectibleType.resultSize(for: info)
            resultNode.isHidden = false
        }
    }
    
    func resetDisplay() {
        powerUpNodes.forEach {
            $0.texture = defaultCollectible.texture
            $0.size = defaultCollectible.size(for: info)
            $0.isHidden = false
        }

        resultNode.texture = defaultCollectible.texture
        resultNode.size = defaultCollectible.size(for: info)
        resultNode.isHidden = true
        currentDisplayedType = nil
    }
}

class NJEquationNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: .gray, size: size)
        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
