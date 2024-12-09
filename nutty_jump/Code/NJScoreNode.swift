//
//  NJScoreNode.swift
//  nutty_jump
//
//  Created by matt on 10/31/24.
//

import SpriteKit

class NJScoreNode: SKNode {

    private let textNode = SKLabelNode()

    func setup(screenSize: CGSize, score: Int, nodePosition: CGPoint) {
        position = nodePosition

        let backgroundNode = SKShapeNode(
            rect: CGRect(
                origin: CGPoint(x: -(Constants.size.width / 2), y: -(Constants.size.height / 2)),
                size: Constants.size
            ),
            cornerRadius: Constants.size.height / 2
        )
        backgroundNode.fillColor = .white
        backgroundNode.strokeColor = UIColor(named: "1672c4") ?? .clear
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

extension NJScoreNode {
    enum Constants {
        static let size = CGSize(width: 140, height: 45)
    }
}
