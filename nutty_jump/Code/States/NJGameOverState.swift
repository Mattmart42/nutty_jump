//
//  NJGameOverState.swift
//  nutty_jump
//
//  Created by keckuser on 11/5/24.
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
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        scene?.isPaused = true
//        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.85)
//        Task { @MainActor in
//            scene?.reset()
//        }
        displayGameOver()
        showGameOverOptions()
    }
    
    override func willExit(to nextState: GKState) {
        scene?.isPaused = false
    }
    
    func handleTouch(_ touch: UITouch) {
        guard let scene else { return }
    }
    
    private func displayGameOver() {
        guard let scene = scene else { return }
        print("displaying game over")
        // Add a "Game Over" label
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        scene.addChild(gameOverLabel)
    }
    
    private func showGameOverOptions() {
        guard let scene = scene else { return }

        // Add a "Restart" button
        let restartButton = SKLabelNode(text: "Restart")
        restartButton.name = "RestartButton"
        restartButton.fontSize = 36
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 - 80)
        scene.addChild(restartButton)
    }
    
    
}
