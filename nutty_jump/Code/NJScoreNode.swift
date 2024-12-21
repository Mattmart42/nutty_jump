//
//  NJScoreNode.swift
//  nutty_jump
//
//  Created by matt on 10/31/24.
//

import SpriteKit

class NJScoreNode: SKNode {

    private let textNode = SKLabelNode()
    private let info: NJGameInfo
    
    override init() {
        self.info = NJGameInfo(screenSize: UIScreen.main.bounds.size)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(screenSize: CGSize, score: Int, nodePosition: CGPoint) {
        position = nodePosition

        let backgroundNode = SKSpriteNode(texture: SKTexture(imageNamed: "nj_score"))
        backgroundNode.size = info.scoreNodeSize
        addChild(backgroundNode)
        updateScore(with: score)
        textNode.verticalAlignmentMode = .center
        addChild(textNode)
    }

    func adjustPosition(cameraNode: SKNode, screenSize: CGSize) {
        let cameraPosition = cameraNode.position
        position = CGPoint(x: 50, y: cameraPosition.y + screenSize.height / 2 - 70)
    }

    func updateScore(with score: Int) {
        textNode.attributedText = NSAttributedString(
            string: "\(score)",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 26, weight: .bold)
            ]
        )
    }
}
