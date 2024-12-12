//
//  NJGameIdleState.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import GameplayKit

class NJGameIdleState: GKState {
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
        print("did enter idle state")
        guard let scene else { return }
        scene.physicsWorld.contactDelegate = nil
        
        scene.player?.isHidden = true
        scene.scoreNode.isHidden = true
        scene.trackerNode.isHidden = true
        scene.equationNode.isHidden = true
        setupIdleUI()
    }
    
    override func willExit(to nextState: GKState) {
        guard let scene, let context, let player = scene.player else { return }
        scene.player?.isHidden = false
        scene.addTrailToPlayer(player: player)
        scene.scoreNode.isHidden = false
        scene.trackerNode.isHidden = false
        scene.equationNode.isHidden = false
        removeIdleUI()
        scene.physicsWorld.contactDelegate = context.gameScene
        let delayAction = SKAction.wait(forDuration: 2.0) // Delay of 5 seconds
        let runObstaclesAction = SKAction.run { [weak scene] in
            scene?.runObstacles() // Run obstacles after the delay
        }
        
        // Combine the delay and the action to run
        let sequence = SKAction.sequence([delayAction, runObstaclesAction])
        
        // Run the combined action on the scene
        scene.run(sequence)
    }
    
    func setupIdleUI() {
        guard let scene else { return }
        
        let titleNode = NJTitleNode(size: CGSize(width: 393, height: 617), position: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2), texture: SKTexture(imageNamed: "titleScreen"))
        titleNode.name = "titleNode"
        titleNode.zPosition = scene.info.titleZPos
        scene.addChild(titleNode)
        let text = SKLabelNode(text: "tap to start")
        text.name = "startText"
        text.fontColor = .white
        text.fontSize = 20
        text.fontName = "PPNeueMontreal-SemiBolditalic"
        text.position = CGPoint(x: scene.size.width / 2, y: 80)
        text.zPosition = scene.info.titleZPos
        scene.addChild(text)
        
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let flashing = SKAction.sequence([fadeOut, fadeIn])
        text.run(SKAction.repeatForever(flashing))
    }

    func removeIdleUI() {
        guard let scene else { return }
        
        scene.childNode(withName: "titleNode")?.removeFromParent()
        scene.childNode(withName: "startText")?.removeFromParent()
    }
    
//    func handleTouch(_ touch: UITouch) {
//        guard let scene, let context else { return }
//        print("touched \(touch)")
//        scene.childNode(withName: "TitleLabel")?.removeFromParent()
//        scene.childNode(withName: "PlayButton")?.removeFromParent()
//        //context.stateMachine?.enter(NJRunningState.self)
//    }
}
