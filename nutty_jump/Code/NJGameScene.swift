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
    let scoreNode = NJScoreNode()
    var score = 0
    
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
        guard let context else {
            return
        }
        physicsWorld.contactDelegate = self
        scoreNode.setup(screenSize: size)
        addChild(scoreNode)
        
        prepareWallNodes(screenSize: size)
        
        prepareGameContext()
        prepareStartNodes()
        
        context.stateMachine?.enter(NJRunningState.self)
    }
    
    func prepareWallNodes(screenSize: CGSize) {
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
    }
    
    func prepareGameContext() {
        guard let context else {
            return
        }

        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func prepareStartNodes() {
        guard let context else {
            return
        }
        let rightWallPlayerPos = CGPoint(x: size.width - 40,
                             y: size.height / 2.0)
        
        let leftWallPlayerPos = CGPoint(x: 40,
                             y: size.height / 2.0)
        let player = NJPlayerNode(size: context.layoutInfo.boxSize, position: rightWallPlayerPos)
        addChild(player)
        self.player = player
    }
    
    override func update(_ currentTime: TimeInterval) {
        print(size.height, size.width)
        //let's check for
        children
            .compactMap { $0 as? NJWallNode }
            .forEach { wallNode in
                
                wallNode.position.y -= 10
                
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        children
            .compactMap { $0 as? GreenWallNode }
            .forEach { wallNode in
                
                wallNode.position.y -= 10
                
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        score += 1
        scoreNode.updateScore(with: score)
        
            

    }
    
    func togglePlayerLocation(currentPlayerPos: CGPoint) {
        let rightWallPlayerPos = CGPoint(x: size.width - 40 * 1.5,
                             y: size.height / 2.0)
        let leftWallPlayerPos = CGPoint(x: 40 * 1.5,
                             y: size.height / 2.0)
        
        let targetPos: CGPoint
        if Int(currentPlayerPos.x) == Int(rightWallPlayerPos.x) {
            targetPos = leftWallPlayerPos
        } else if Int(currentPlayerPos.x) == Int(leftWallPlayerPos.x) {
            targetPos = rightWallPlayerPos
        } else {
            return
        }
        
        let moveAction = SKAction.move(to: targetPos, duration: 0.3) // Adjust duration for speed
            moveAction.timingMode = .easeInEaseOut // Smooth start and stop for the animation
            player?.run(moveAction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let stateMachine = context?.stateMachine,
              stateMachine.currentState is NJRunningState else {
            return // Ignore touch if not in running state
        }
        print("Tapped while in NJRunningState")
        // Get the first touch (since we're only handling single taps)
        stateMachine.enter(NJJumpingState.self)
        if let touch = touches.first {
            (stateMachine.currentState as? NJJumpingState)?.handleTouch(touch)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let stateMachine = context?.stateMachine else { return }

        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask

        // Check if the player hit a wall
        print("hit a wall")
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.wall) ||
            (contactA == NJPhysicsCategory.wall && contactB == NJPhysicsCategory.player) {
            // Enter the running state
            stateMachine.enter(NJRunningState.self)
        }
    }

}
