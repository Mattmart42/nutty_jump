//
//  NJGameScene.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import SpriteKit
import GameplayKit

class NJGameScene: SKScene, SKPhysicsContactDelegate {
    weak var context: NJGameContext?
    
    var player: NJPlayerNode?
    var fruit: NJFruitNode?
    var hawk: NJHawkNode?
    let scoreNode = NJScoreNode()
    var score = 0
    var fruitsCollected: Int = 0
    var hawksCollected: Int = 0
    
    let leftWallPlayerPos: CGPoint
    let rightWallPlayerPos: CGPoint
    
    init(context: NJGameContext, size: CGSize) {
        self.leftWallPlayerPos = CGPoint(x: 40 * 1.5, y: size.height / 2.0)
        self.rightWallPlayerPos = CGPoint(x: size.width - 40 * 1.5, y: size.height / 2.0)
        self.context = context
        super.init(size: size)
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard let context else { return }
        
        physicsWorld.contactDelegate = self
        prepareGameContext()
        prepareStartNodes(screenSize: size)
        
        context.stateMachine?.enter(NJRunningState.self)
        
        let spawnAction = SKAction.run { [weak self] in self?.spawnFruitHawk() }
        let delay = SKAction.wait(forDuration: 2.0) // Adjust interval as needed
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence))
        
        //dropFruits()
        //dropHawks()
    }
    
    func prepareStartNodes(screenSize: CGSize) {
        guard let context else { return }
        
        scoreNode.setup(screenSize: size)
        addChild(scoreNode)
        
        let width: CGFloat = (40 / 393) * screenSize.width
        let height: CGFloat = screenSize.height
        
        let leftWallTop = NJWallNode(size: CGSize(width: width, height: height),
                                     position: CGPoint(x: width / 2, y: 0))
        let leftWallBot = GreenWallNode(size: CGSize(width: width, height: height),
                                position: CGPoint(x: width / 2, y: height))
        addChild(leftWallTop)
        addChild(leftWallBot)
        
        let rightWallTop = NJWallNode(size: CGSize(width: width, height: height),
                                     position: CGPoint(x: size.width - width / 2, y: 0))
        let rightWallBot = GreenWallNode(size: CGSize(width: width, height: height),
                                position: CGPoint(x: size.width - width / 2, y: height))
        addChild(rightWallTop)
        addChild(rightWallBot)
        
        let ground = NJGroundNode(size: CGSize(width: screenSize.width, height: 10), position: CGPoint(x: size.width / 2, y: 0))
        addChild(ground)
        
        let player = NJPlayerNode(size: context.layoutInfo.boxSize, position: rightWallPlayerPos)
        addChild(player)
        self.player = player
    }
    
    func prepareGameContext() {
        guard let context else { return }

        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        children
            .compactMap { $0 as? NJWallNode }
            .forEach { wallNode in wallNode.position.y -= 10
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        children
            .compactMap { $0 as? GreenWallNode }
            .forEach { wallNode in wallNode.position.y -= 10
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        score += 1
        scoreNode.updateScore(with: score)
    }

    func spawnFruitHawk() {
        let isFruit = Bool.random()
        
        let obstacleSize = CGSize(width: 30, height: 30)
        let yPosition = size.height
        let xPosition: CGFloat = Bool.random() ? 60 : size.width - 60

        let obstacle: SKSpriteNode
        let targetPosition: CGPoint
        
        if isFruit {
            obstacle = NJFruitNode(size: obstacleSize, position: CGPoint(x: xPosition, y: yPosition))
            targetPosition = CGPoint(x: xPosition, y: 0)
            let moveAction = SKAction.move(to: targetPosition, duration: 2.0)
            let removeAction = SKAction.removeFromParent()
            obstacle.run(SKAction.sequence([moveAction, removeAction]))
        } else {
            obstacle = NJHawkNode(size: obstacleSize, position: CGPoint(x: xPosition, y: yPosition))
            targetPosition = CGPoint(x: xPosition == 60 ? size.width - 60 : 60, y: player?.position.y ?? 0)
            let moveAction = SKAction.move(to: targetPosition, duration: 1.0)
            let removeAction = SKAction.removeFromParent()
            obstacle.run(SKAction.sequence([moveAction, removeAction]))
        }

        addChild(obstacle)
    }
    
//    func dropFruits() {
//        let spawnAction = SKAction.run { [weak self] in
//            self?.spawnFruit()
//        }
//        let waitAction = SKAction.wait(forDuration: Double.random(in: 1.0...3.0))
//        let sequence = SKAction.sequence([spawnAction, waitAction])
//        let repeatAction = SKAction.repeatForever(sequence)
//        run(repeatAction)
//    }
    
//    func spawnHawk() {
//        guard let context else { return }
//        
//        let hawkPosition = CGPoint(x: size.width / 2.0, y: size.height - 50)
//        let hawk = NJHawkNode(size: context.layoutInfo.boxSize, position: hawkPosition)
//        hawk.dropDiagonally(screenWidth: size.width, screenHeight: size.height)
//        
//        addChild(hawk)
//    }
    
//    func dropHawks() {
//        let spawnAction = SKAction.run { [weak self] in
//            self?.spawnHawk()
//        }
//        let waitAction = SKAction.wait(forDuration: Double.random(in: 1.0...3.0))
//        let sequence = SKAction.sequence([spawnAction, waitAction])
//        let repeatAction = SKAction.repeatForever(sequence)
//        run(repeatAction)
//    }
    
    func togglePlayerLocation(currentPlayerPos: CGPoint) {
        let targetPos = (Int(currentPlayerPos.x) == Int(rightWallPlayerPos.x)) ? leftWallPlayerPos : rightWallPlayerPos
        
        let moveAction = SKAction.move(to: targetPos, duration: 0.3)
        moveAction.timingMode = .easeInEaseOut
        player?.run(moveAction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let stateMachine = context?.stateMachine,
              let currentState = stateMachine.currentState else { return }
        
        if currentState is NJRunningState {
            stateMachine.enter(NJJumpingState.self)
            if let touch = touches.first {
                (stateMachine.currentState as? NJJumpingState)?.handleTouch(touch)
            }
        } else if currentState is NJGameOverState {
            stateMachine.enter(NJJumpingState.self)
            
            if let touch = touches.first {
                (stateMachine.currentState as? NJGameOverState)?.handleTouch(touch)
            }
        } else {
            print("Tap ignored, not running or game over")
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let stateMachine = context?.stateMachine else { return }

        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.wall) ||
            (contactA == NJPhysicsCategory.wall && contactB == NJPhysicsCategory.player) {
            print("player hit wall")
            stateMachine.enter(NJRunningState.self)
            return
        }
        
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.ground) ||
            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.player) {
            print("player hit ground")
            stateMachine.enter(NJGameOverState.self)
            return
        }
        
        if (contactA == NJPhysicsCategory.player && (contactB == NJPhysicsCategory.fruit || contactB == NJPhysicsCategory.hawk)) || ((contactA == NJPhysicsCategory.fruit || contactA == NJPhysicsCategory.hawk) && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState {
                print("player hit obstacle while running")
                player?.toggleGravity()
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit obstacle while jumping")
                let obstacleNode = (contactA == NJPhysicsCategory.fruit || contactA == NJPhysicsCategory.hawk) ? contact.bodyA.node : contact.bodyB.node
                obstacleNode?.removeFromParent()
            }
        }
    }
    
    func reset() {
        guard let context else { return }
        score = 0
        scoreNode.updateScore(with: 0)
        children
            .compactMap { $0 as? NJFruitNode }
            .forEach { $0.removeFromParent() }
        children
            .compactMap { $0 as? NJHawkNode }
            .forEach { $0.removeFromParent() }
        children
            .compactMap { $0 as? NJPlayerNode }
            .forEach { $0.removeFromParent() }
        children
            .compactMap { $0 as? NJWallNode }
            .forEach { $0.removeFromParent() }
        children
            .compactMap { $0 as? GreenWallNode }
            .forEach { $0.removeFromParent() }
        children
            .compactMap { $0 as? NJGroundNode }
            .forEach { $0.removeFromParent() }
        prepareStartNodes(screenSize: size)
        context.stateMachine?.enter(NJRunningState.self)
    }
}
