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
    var trackerNode: NJPowerUpTrackerNode!
    var backgroundNodes: [NJBackgroundNode] = []
    
    let fruitAtlas = SKTextureAtlas(named: "FruitAtlas")
    let backgroundAtlas = SKTextureAtlas(named: "BackgroundAtlas")
    let playerTexture = SKTexture(imageNamed: "player")
    
    let leftWallPlayerPos: CGPoint
    let rightWallPlayerPos: CGPoint
    
    init(context: NJGameContext, size: CGSize) {
        self.leftWallPlayerPos = CGPoint(x: NJGameInfo.obstacleXPos, y: size.height / 2.0)
        self.rightWallPlayerPos = CGPoint(x: size.width - NJGameInfo.obstacleXPos, y: size.height / 2.0)
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
        
        let spawnAction = SKAction.run { [weak self] in self?.spawnRandomObstacle() }
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    func prepareBackgroundNodes() {
        let backgroundTextures = backgroundAtlas.textureNames.sorted().map { backgroundAtlas.textureNamed($0) }
        
        let fallNode = NJBackgroundNode(texture: backgroundTextures[0])
        let winterNode = NJBackgroundNode(texture: backgroundTextures[1])
        let springNode = NJBackgroundNode(texture: backgroundTextures[2])
        let summerNode = NJBackgroundNode(texture: backgroundTextures[3])
        
        fallNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight / 2)
        winterNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight * 1.5)
        springNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight * 2.5)
        summerNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight * 3.5)
        
        self.backgroundNodes.append(fallNode)
        self.backgroundNodes.append(winterNode)
        self.backgroundNodes.append(springNode)
        self.backgroundNodes.append(summerNode)
        
        fallNode.zPosition = NJGameInfo.bgZPos
        winterNode.zPosition = NJGameInfo.bgZPos
        springNode.zPosition = NJGameInfo.bgZPos
        summerNode.zPosition = NJGameInfo.bgZPos
        
        addChild(fallNode)
        addChild(winterNode)
        addChild(springNode)
        addChild(summerNode)
    }
    
    func scrollScreen() {
        children
            .compactMap { $0 as? NJWallNode }
            .forEach { wallNode in wallNode.position.y -= NJGameInfo.scrollSpeed
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        for node in self.backgroundNodes {
            node.position.y -= NJGameInfo.backgroundScrollSpeed
            if node.position.y <= -NJGameInfo.backgroundHeight {
                node.position.y += NJGameInfo.backgroundHeight * 4
            }
        }
    }
    
    func prepareStartNodes(screenSize: CGSize) {
        guard let context else { return }
        
        prepareBackgroundNodes()
        
        let scoreNodePos = CGPoint(x: screenSize.width / 2, y: screenSize.height - 59 - 45 / 2)
        scoreNode.setup(screenSize: size, score: context.gameInfo.score, nodePosition: scoreNodePos)
        scoreNode.zPosition = NJGameInfo.hudZPos
        addChild(scoreNode)
        
        trackerNode = NJPowerUpTrackerNode(size: NJGameInfo.trackerSize)
        trackerNode.position = CGPoint(x: 70 + trackerNode.frame.width / 2, y: 40 + trackerNode.frame.height / 2)
        trackerNode.zPosition = NJGameInfo.hudZPos
        addChild(trackerNode)
        
        let wallWidth: CGFloat = NJGameInfo.wallWidth
        let wallHeight: CGFloat = screenSize.height
        
        let leftWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "leftWall"))
        let leftWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "leftWall"))
        leftWallTop.zPosition = NJGameInfo.wallZPos
        leftWallBot.zPosition = NJGameInfo.wallZPos
        addChild(leftWallTop)
        addChild(leftWallBot)
        
        let rightWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: size.width - wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "rightWall"))
        let rightWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                position: CGPoint(x: size.width - wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "rightWall"))
        rightWallTop.zPosition = NJGameInfo.wallZPos
        rightWallBot.zPosition = NJGameInfo.wallZPos
        addChild(rightWallTop)
        addChild(rightWallBot)
        
        let ground = NJGroundNode(size: CGSize(width: screenSize.width, height: NJGameInfo.groundHeight), position: CGPoint(x: size.width / 2, y: 0))
        ground.zPosition = NJGameInfo.branchZPos
        addChild(ground)
        
        let player = NJPlayerNode(size: context.layoutInfo.boxSize, position: rightWallPlayerPos, texture: playerTexture)
        player.zPosition = NJGameInfo.playerZPos
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

    // MARK: - Spawners
    
    func spawnRandomObstacle() {
        let obstacleSize = NJGameInfo.obstacleSize
        let obstacleYPos = size.height
        
        let functions: [() -> Void] = [
            { self.spawnFruit(obstacleSize: obstacleSize, yPos: obstacleYPos) },
            { self.spawnHawk(obstacleSize: NJGameInfo.hawkSize, yPos: obstacleYPos) },
            { self.spawnFox(obstacleSize: NJGameInfo.foxSize, yPos: obstacleYPos) },
            { self.spawnNut(obstacleSize: obstacleSize, yPos: obstacleYPos) }
        ]
            
        let randomIndex = Int.random(in: 0..<functions.count)
        functions[randomIndex]()
    }
    
    func spawnFruit(obstacleSize: CGSize, yPos: CGFloat) {
        let xPos: CGFloat = Bool.random() ? NJGameInfo.obstacleXPos : size.width - NJGameInfo.obstacleXPos
        let dropDuration = 1.2
        
        let fruitTextures = fruitAtlas.textureNames.map { fruitAtlas.textureNamed($0) }
        let randomTexture = fruitTextures.randomElement() ?? fruitTextures[0]
        
        let obstacle = NJFruitNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: randomTexture)
        let targetPos = CGPoint(x: xPos, y: 0)
        
        let moveAction = SKAction.move(to: targetPos, duration: dropDuration)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
        
        obstacle.zPosition = NJGameInfo.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnHawk(obstacleSize: CGSize, yPos: CGFloat) {
        let xPos: CGFloat = Bool.random() ? NJGameInfo.obstacleXPos : size.width - NJGameInfo.obstacleXPos
        let targetPos = CGPoint(x: xPos == NJGameInfo.obstacleXPos ? size.width - NJGameInfo.obstacleXPos : NJGameInfo.obstacleXPos, y: player?.position.y ?? 0)
        let obstacle = xPos == NJGameInfo.obstacleXPos ? NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "hawkLeft")) : NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "hawkRight"))
        
        let moveAction = SKAction.move(to: targetPos, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
        obstacle.zPosition = NJGameInfo.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnFox(obstacleSize: CGSize, yPos: CGFloat) {
        guard let player else { return }
        
        spawnFoxBranch(obstacleSize: obstacleSize, yPos: yPos)
        
        let xPos: CGFloat = Bool.random() ? NJGameInfo.obstacleXPos : size.width - NJGameInfo.obstacleXPos
        let targetPos = CGPoint(x: xPos == NJGameInfo.obstacleXPos ? size.width - NJGameInfo.obstacleXPos : NJGameInfo.obstacleXPos, y: player.position.y - 10.0)
        let obstacle = NJFoxNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos + NJGameInfo.branchHeight), texture: SKTexture(imageNamed: "fox1"))
        
        let foxTextures = [
                SKTexture(imageNamed: "fox1"),
                SKTexture(imageNamed: "fox2"),
                SKTexture(imageNamed: "fox3")
            ]
        let animateAction = SKAction.animate(with: foxTextures, timePerFrame: 0.1, resize: false, restore: true)
        let repeatAnimation = SKAction.repeatForever(animateAction)
        obstacle.run(repeatAnimation)
        
        let moveAction = SKAction.move(to: targetPos, duration: size.width / NJGameInfo.foxSpeed)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        obstacle.run(sequence)
        
        obstacle.zPosition = NJGameInfo.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnFoxBranch(obstacleSize: CGSize, yPos: CGFloat) {
        let branch = NJFoxBranchNode(size: CGSize(width: size.width, height: NJGameInfo.branchHeight), position: CGPoint(x: size.width / 2, y: yPos), texture: SKTexture(imageNamed: "foxBranch"))
        let branchTargetPos = CGPoint(x: size.width / 2, y: 0)
        let branchDistance = yPos - branchTargetPos.y
        let branchDuration = branchDistance / (NJGameInfo.scrollSpeed * NJGameInfo.fps)
        
        let moveActionBranch = SKAction.move(to: branchTargetPos, duration: branchDuration)
        let removeActionBranch = SKAction.removeFromParent()
        branch.run(SKAction.sequence([moveActionBranch, removeActionBranch]))
        
        branch.zPosition = NJGameInfo.branchZPos
        addChild(branch)
    }
    
    func spawnNut(obstacleSize: CGSize, yPos: CGFloat) {
        let xPos: CGFloat = CGFloat.random(in: NJGameInfo.obstacleXPos...(size.width - NJGameInfo.obstacleXPos))
        
        let obstacle = NJNutNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "nut"))
        let targetPos = CGPoint(x: xPos, y: 0)
        
        let moveAction = SKAction.move(to: targetPos, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
        
        obstacle.zPosition = NJGameInfo.obstacleZPos
        addChild(obstacle)
    }
    
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
    
    // MARK: - User Input
    
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
    
    // MARK: - Physics Contacts
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let context else { return }
        guard let stateMachine = context.stateMachine else { return }

        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        //player hits wall
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.wall) ||
            (contactA == NJPhysicsCategory.wall && contactB == NJPhysicsCategory.player) {
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
                if context.gameInfo.playerIsProtected {
                    context.gameInfo.playerIsProtected = false
                    player?.texture = SKTexture(imageNamed: "player")
                    return
                }
                print("player hit fruit while running")
                player?.toggleGravity()
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit fruit while jumping")
                let fruitNode = (contactA == NJPhysicsCategory.fruit) ? contact.bodyA.node : contact.bodyB.node
                fruitNode?.removeFromParent()
                
                context.gameInfo.hawksCollected = 0
                context.gameInfo.foxesCollected = 0
                if context.gameInfo.fruitsCollected == 2 {
                    fruitPowerUp()
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
                if context.gameInfo.playerIsProtected {
                    context.gameInfo.playerIsProtected = false
                    player?.texture = SKTexture(imageNamed: "player")
                    return
                }
                print("player hit hawk while running")
                player?.toggleGravity()
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit hawk while jumping")
                let hawkNode = (contactA == NJPhysicsCategory.hawk) ? contact.bodyA.node : contact.bodyB.node
                hawkNode?.removeFromParent()
                
                context.gameInfo.fruitsCollected = 0
                context.gameInfo.foxesCollected = 0
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
        
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fox) ||
            (contactA == NJPhysicsCategory.fox && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !context.gameInfo.playerIsInvincible {
                if context.gameInfo.playerIsProtected {
                    context.gameInfo.playerIsProtected = false
                    player?.texture = SKTexture(imageNamed: "player")
                    return
                }
                print("player hit fox while running")
                player?.toggleGravity()
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit fox while jumping")
                let foxNode = (contactA == NJPhysicsCategory.fox) ? contact.bodyA.node : contact.bodyB.node
                foxNode?.removeFromParent()
                
                context.gameInfo.fruitsCollected = 0
                context.gameInfo.hawksCollected = 0
                if context.gameInfo.foxesCollected == 2 {
                    foxPowerUp()
                    context.gameInfo.foxesCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.foxesCollected, with: CollectibleType.fox)
                } else if context.gameInfo.foxesCollected == 1 {
                    context.gameInfo.foxesCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.foxesCollected, with: CollectibleType.fox)
                } else if context.gameInfo.foxesCollected == 0 {
                    trackerNode.resetDisplay()
                    context.gameInfo.foxesCollected += 1
                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.foxesCollected, with: CollectibleType.fox)
                }
            }
        }
        
        //player hits nut
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.nut) ||
            (contactA == NJPhysicsCategory.nut && contactB == NJPhysicsCategory.player) {
            print("player hit nut")
            let nutNode = (contactA == NJPhysicsCategory.nut) ? contact.bodyA.node : contact.bodyB.node
            nutNode?.removeFromParent()
            context.gameInfo.nutsCollected += 1
            context.gameInfo.playerIsProtected = true
            player?.texture = SKTexture(imageNamed: "protectedPlayer")
            return
        }
        
        //branch hits ground
        if (contactA == NJPhysicsCategory.foxBranch && contactB == NJPhysicsCategory.ground) ||
            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.foxBranch) {
            print("branch hit ground")
            let foxBranchNode = (contactA == NJPhysicsCategory.foxBranch) ? contact.bodyA.node : contact.bodyB.node
            foxBranchNode?.removeFromParent()
            return
        }
    }
    
    // MARK: - Powerup Functions
    
    func fruitPowerUp() {
        guard let context else { return }
    }
    
    func hawkPowerUp() {
        guard let context else { return }
        
        context.gameInfo.playerIsInvincible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + context.gameInfo.hawkPULength) {
            context.gameInfo.playerIsInvincible = false
            context.gameInfo.hawksCollected = 0
            self.trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
        }
    }
    
    func foxPowerUp() {
        guard let context else { return }
    }
    
    // MARK: - Other
    
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

        let spawnAction = SKAction.run { [weak self] in self?.spawnRandomObstacle() }
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawnObstacles")

        context.stateMachine?.enter(NJRunningState.self)
    }
}
