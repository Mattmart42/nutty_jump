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
    var trackerNode: NJPowerUpTrackerNode!
    
    var powerUpLength = 10.0
    
    let backgroundScrollSpeed: CGFloat = 2.0
    var backgroundNodes: [NJBackgroundNode] = []
    let textureHeight: CGFloat = 2500
    
    let fruitAtlas = SKTextureAtlas(named: "FruitAtlas")
    let backgroundAtlas = SKTextureAtlas(named: "BackgroundAtlas")
    let playerTexture = SKTexture(imageNamed: "player")
    
    let leftWallPlayerPos: CGPoint
    let rightWallPlayerPos: CGPoint
    
    init(context: NJGameContext, size: CGSize) {
        self.leftWallPlayerPos = CGPoint(x: 40 * 1.5, y: size.height / 2.0)
        self.rightWallPlayerPos = CGPoint(x: size.width - 40 * 1.5, y: size.height / 2.0)
        self.context = context
        super.init(size: size)
        
        fruitAtlas.preload {
            print("fruit sprite preloaded")
        }
        backgroundAtlas.preload {
            print("background sprite preloaded")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard let context else { return }
        
        prepareGameContext()
        prepareStartNodes(screenSize: size)
        physicsWorld.contactDelegate = self
        context.stateMachine?.enter(NJRunningState.self)
        
        let spawnAction = SKAction.run { [weak self] in self?.spawnFruitHawk() }
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence))
        
        //dropFruits()
        //dropHawks()
    }
    
    func prepareBackgroundNodes() {
        let backgroundTextures = backgroundAtlas.textureNames.sorted().map { backgroundAtlas.textureNamed($0) }
        
        let fallNode = NJBackgroundNode(texture: backgroundTextures[0])
        let winterNode = NJBackgroundNode(texture: backgroundTextures[1])
        let springNode = NJBackgroundNode(texture: backgroundTextures[2])
        let summerNode = NJBackgroundNode(texture: backgroundTextures[3])
        
        fallNode.position = CGPoint(x: frame.midX, y: textureHeight / 2)
        winterNode.position = CGPoint(x: frame.midX, y: textureHeight * 1.5)
        springNode.position = CGPoint(x: frame.midX, y: textureHeight * 2.5)
        summerNode.position = CGPoint(x: frame.midX, y: textureHeight * 3.5)
        
        self.backgroundNodes.append(fallNode)
        self.backgroundNodes.append(winterNode)
        self.backgroundNodes.append(springNode)
        self.backgroundNodes.append(summerNode)
        
        addChild(fallNode)
        addChild(winterNode)
        addChild(springNode)
        addChild(summerNode)
    }
    
    func scrollScreen() {
        children
            .compactMap { $0 as? NJWallNode }
            .forEach { wallNode in wallNode.position.y -= 10
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        for node in self.backgroundNodes {
            node.position.y -= backgroundScrollSpeed
            if node.position.y <= -2500 {
                node.position.y += 2500 * 4
            }
        }
    }
    
    func prepareStartNodes(screenSize: CGSize) {
        guard let context else { return }
        
        prepareBackgroundNodes()
        
        let scoreNodePos = CGPoint(x: screenSize.width / 2, y: screenSize.height - 59 - 45 / 2)
        scoreNode.setup(screenSize: size, score: context.gameInfo.score, nodePosition: scoreNodePos)
        addChild(scoreNode)
        
        trackerNode = NJPowerUpTrackerNode(size: CGSize(width: 30, height: 30))
        trackerNode.position = CGPoint(x: 70 + trackerNode.frame.width / 2, y: 40 + trackerNode.frame.height / 2)
        addChild(trackerNode)
        
        let wallWidth: CGFloat = (40 / 393) * screenSize.width
        let wallHeight: CGFloat = screenSize.height
        
        let leftWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "leftWall"))
        let leftWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "leftWall"))
        addChild(leftWallTop)
        addChild(leftWallBot)
        
        let rightWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: size.width - wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "rightWall"))
        let rightWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                position: CGPoint(x: size.width - wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "rightWall"))
        addChild(rightWallTop)
        addChild(rightWallBot)
        
        let ground = NJGroundNode(size: CGSize(width: screenSize.width, height: 10), position: CGPoint(x: size.width / 2, y: 0))
        addChild(ground)
        
        let player = NJPlayerNode(size: context.layoutInfo.boxSize, position: rightWallPlayerPos, texture: playerTexture)
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
        guard let context else { return }
        
        scrollScreen()
        context.gameInfo.score += 1
        scoreNode.updateScore(with: context.gameInfo.score)
    }

    func spawnFruitHawk() {
        let isFruit = Bool.random()
        
        let obstacleSize = CGSize(width: 30, height: 30)
        let yPosition = size.height
        let xPosition: CGFloat = Bool.random() ? 60 : size.width - 60

        let obstacle: SKSpriteNode
        let targetPosition: CGPoint
        let dropDuration = 1.2 //TimeInterval.random(in: 1.0...2.0)
        
        if isFruit {
            let fruitTextures = fruitAtlas.textureNames.map { fruitAtlas.textureNamed($0) }
            let randomTexture = fruitTextures.randomElement() ?? fruitTextures[0]
            
            obstacle = NJFruitNode(size: obstacleSize, position: CGPoint(x: xPosition, y: yPosition), texture: randomTexture)
            targetPosition = CGPoint(x: xPosition, y: 0)
            
            let moveAction = SKAction.move(to: targetPosition, duration: dropDuration)
            let removeAction = SKAction.removeFromParent()
            obstacle.run(SKAction.sequence([moveAction, removeAction]))
        } else {
            obstacle = NJHawkNode(size: obstacleSize, position: CGPoint(x: xPosition, y: yPosition), texture: SKTexture(imageNamed: "coconut"))
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
        let isOnRightWall = Int(currentPlayerPos.x) == Int(rightWallPlayerPos.x)
        let targetPos = isOnRightWall ? leftWallPlayerPos : rightWallPlayerPos
        
        let moveAction = SKAction.move(to: targetPos, duration: 0.3)
        moveAction.timingMode = .easeInEaseOut
        let rotationAngle: CGFloat = isOnRightWall ? .pi : -.pi
        let rotationAction = SKAction.rotate(byAngle: rotationAngle, duration: 0.3)
        let combinedAction = SKAction.group([moveAction, rotationAction])
        player?.run(combinedAction)
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
            //stateMachine.enter(NJJumpingState.self)
            
            if let touch = touches.first {
                (stateMachine.currentState as? NJGameOverState)?.handleTouch(touch)
            }
        } else {
            print("Tap ignored, not running or game over")
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let context else { return }
        guard let stateMachine = context.stateMachine else { return }

        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        //player hits wall
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.wall) ||
            (contactA == NJPhysicsCategory.wall && contactB == NJPhysicsCategory.player) {
            print("player hit wall")
            stateMachine.enter(NJRunningState.self)
            return
        }
        
        //player hits ground
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.ground) ||
            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.player) {
            print("player hit ground")
            stateMachine.enter(NJGameOverState.self)
            return
        }
        
        //player hits fruit
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fruit) ||
            (contactA == NJPhysicsCategory.fruit && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !context.gameInfo.playerIsInvincible {
                print("player hit fruit while running")
                player?.toggleGravity()
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit fruit while jumping")
                let fruitNode = (contactA == NJPhysicsCategory.fruit) ? contact.bodyA.node : contact.bodyB.node
                fruitNode?.removeFromParent()
                
                context.gameInfo.hawksCollected = 0
                if context.gameInfo.fruitsCollected == 2 {
                    //TODO: Implement powerup states
                    context.gameInfo.fruitsCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.fruitsCollected, with: CollectibleType.fruit)
                } else if context.gameInfo.fruitsCollected == 1 {
                    context.gameInfo.fruitsCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.fruitsCollected, with: CollectibleType.fruit)
                } else if context.gameInfo.fruitsCollected == 0 {
                    trackerNode.resetDisplay()
                    context.gameInfo.fruitsCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.fruitsCollected, with: CollectibleType.fruit)
                }
            }
        }
        
        //player hits hawk
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.hawk) ||
            (contactA == NJPhysicsCategory.hawk && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !context.gameInfo.playerIsInvincible {
                print("player hit hawk while running")
                player?.toggleGravity()
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit hawk while jumping")
                let hawkNode = (contactA == NJPhysicsCategory.hawk) ? contact.bodyA.node : contact.bodyB.node
                hawkNode?.removeFromParent()
                
                context.gameInfo.fruitsCollected = 0
                if context.gameInfo.hawksCollected == 2 {
                    hawkPowerUp()
                    context.gameInfo.hawksCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
                } else if context.gameInfo.hawksCollected == 1 {
                    context.gameInfo.hawksCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
                } else if context.gameInfo.hawksCollected == 0 {
                    trackerNode.resetDisplay()
                    context.gameInfo.hawksCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
                }
            }
        }
    }
    
    func hawkPowerUp() {
        guard let context else { return }
        
        context.gameInfo.playerIsInvincible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + self.powerUpLength) {
            context.gameInfo.playerIsInvincible = false
            context.gameInfo.hawksCollected = 0
            self.trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
        }
    }
    
    func displayScore() {
        guard let context else { return }
        
        scoreNode.removeFromParent()
        scoreNode.setup(screenSize: size, score: context.gameInfo.score, nodePosition: CGPoint(x: size.width / 2, y: size.height / 2 + 50))
        addChild(scoreNode)
    }
    
    func reset() {
        guard let context else { return }
        
        removeAllChildren()
        removeAllActions()

        context.resetGameContext()
        
        prepareStartNodes(screenSize: size)
        scoreNode.updateScore(with: 0)
        trackerNode.resetDisplay()

        player?.position = rightWallPlayerPos
        player?.physicsBody?.velocity = .zero

        let spawnAction = SKAction.run { [weak self] in self?.spawnFruitHawk() }
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawnObstacles")

        context.stateMachine?.enter(NJRunningState.self)
    }
}
