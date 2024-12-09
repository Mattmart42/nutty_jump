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
        setupIdleUI()
    }
    
    override func willExit(to nextState: GKState) {
        guard let scene, let context else { return }
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
        let text = SKLabelNode(text: "TAP TO START")
        text.name = "startText"
        text.fontColor = .black
        text.fontSize = 20
        text.fontName = "PPNeueMontreal-SemiBolditalic"
        text.position = CGPoint(x: scene.size.width / 2, y: 80)
        text.zPosition = scene.info.titleZPos
        scene.addChild(text)
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
