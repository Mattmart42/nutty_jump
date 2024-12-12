//
//  NJGameOverState.swift
//  nutty_jump
//
//  Created by matt on 11/5/24.
//

import GameplayKit

class NJGameOverState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJGameIdleState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("did enter game over state")
        guard let scene else { return }
        scene.physicsWorld.contactDelegate = nil
        setupGameOverUI()
        scene.isPaused = true
    }
    
//    override func willExit(to nextState: GKState) {
//        guard let scene else { return }
//        scene.removeAllChildren()
//        scene.removeAllActions()
//    }
    
    func setupGameOverUI() {
        guard let scene else { return }
        let titleNode = NJTitleNode(size: scene.info.gameOverSize, position: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 100), texture: SKTexture(imageNamed: "gameOver"))
        titleNode.name = "gameOver"
        scene.addChild(titleNode)

        let scoreText = SKLabelNode(text: "SCORE:")
        scoreText.name = "scoreText"
        scoreText.fontName = "PPNeueMontreal-Italic"
        scoreText.fontSize = 50
        scoreText.fontColor = .black
        scoreText.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        scene.addChild(scoreText)
        
        let scoreValue = SKLabelNode(text: "\(scene.info.score)")
        scoreValue.name = "scoreValue"
        scoreValue.fontName = "PPNeueMontreal-SemiBolditalic"
        scoreValue.fontSize = 50
        scoreValue.fontColor = .black
        scoreValue.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 - 50)
        scene.addChild(scoreValue)
        
        let continueButton = SKLabelNode(text: "Continue")
        continueButton.name = "ContinueButton"
        continueButton.fontName = "PPNeueMontreal-Bold"
        continueButton.fontSize = 36
        continueButton.fontColor = .black
        continueButton.position = CGPoint(x: scene.size.width / 2, y: 200)
        scene.addChild(continueButton)
    }
    
    
}
