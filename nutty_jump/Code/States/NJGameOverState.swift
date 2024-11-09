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
        return stateClass == NJRunningState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        //scene?.displayScore()
        scene?.isPaused = true
        displayGameOver()
        showGameOverOptions()
    }
    
    override func willExit(to nextState: GKState) {
        scene?.childNode(withName: "GameOverLabel")?.removeFromParent()
        scene?.childNode(withName: "RestartButton")?.removeFromParent()
    }
    
    func handleTouch(_ touch: UITouch) {
        guard let scene else { return }
        let location = touch.location(in: scene)
        if let node = scene.atPoint(location) as? SKLabelNode, node.name == "RestartButton" {
            scene.reset()
        }
    }
    
    private func displayGameOver() {
        guard let scene = scene else { return }
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        scene.addChild(gameOverLabel)
    }
    
    private func showGameOverOptions() {
        guard let scene = scene else { return }

        let restartButton = SKLabelNode(text: "Restart")
        restartButton.name = "RestartButton"
        restartButton.fontSize = 36
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 - 80)
        scene.addChild(restartButton)
    }
}
