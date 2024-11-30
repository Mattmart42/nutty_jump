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
    var info: NJGameInfo
    
    var player: NJPlayerNode?
    let scoreNode = NJScoreNode()
    var trackerNode: NJPowerUpTrackerNode!
    var backgroundNodes: [NJBackgroundNode] = []
    
    let fruitAtlas = SKTextureAtlas(named: "FruitAtlas")
    let backgroundAtlas = SKTextureAtlas(named: "BackgroundAtlas")
    let playerAtlas = SKTextureAtlas(named: "PlayerAtlas")
    
    let leftWallPlayerPos: CGPoint
    let rightWallPlayerPos: CGPoint
    
    init(context: NJGameContext, size: CGSize, info: NJGameInfo) {
        self.leftWallPlayerPos = CGPoint(x: info.obstacleXPos, y: size.height / 2.0)
        self.rightWallPlayerPos = CGPoint(x: size.width - info.obstacleXPos, y: size.height / 2.0)
        self.context = context
        self.info = info
        super.init(size: size)
        
        fruitAtlas.preload {
            print("fruit sprites preloaded")
        }
        backgroundAtlas.preload {
            print("background sprites preloaded")
        }
        playerAtlas.preload {
            print("player sprites preloaded")
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
        context.stateMachine?.enter(NJGameIdleState.self)
    }
    
    func prepareBackgroundNodes() {
        let backgroundTextures = backgroundAtlas.textureNames.sorted().map { backgroundAtlas.textureNamed($0) }
        
        let fallNode = NJBackgroundNode(texture: backgroundTextures[0])
        let winterNode = NJBackgroundNode(texture: backgroundTextures[1])
        let springNode = NJBackgroundNode(texture: backgroundTextures[2])
        let summerNode = NJBackgroundNode(texture: backgroundTextures[3])
        
        fallNode.position = CGPoint(x: frame.midX, y: info.backgroundHeight / 2)
        winterNode.position = CGPoint(x: frame.midX, y: info.backgroundHeight * 1.5)
        springNode.position = CGPoint(x: frame.midX, y: info.backgroundHeight * 2.5)
        summerNode.position = CGPoint(x: frame.midX, y: info.backgroundHeight * 3.5)
        
        self.backgroundNodes.append(fallNode)
        self.backgroundNodes.append(winterNode)
        self.backgroundNodes.append(springNode)
        self.backgroundNodes.append(summerNode)
        
        fallNode.zPosition = info.bgZPos
        winterNode.zPosition = info.bgZPos
        springNode.zPosition = info.bgZPos
        summerNode.zPosition = info.bgZPos
        
        addChild(fallNode)
        addChild(winterNode)
        addChild(springNode)
        addChild(summerNode)
    }
    
    func scrollScreen() {
        children
            .compactMap { $0 as? NJWallNode }
            .forEach { wallNode in wallNode.position.y -= info.scrollSpeed
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        for node in self.backgroundNodes {
            node.position.y -= info.backgroundScrollSpeed
            if node.position.y <= -info.backgroundHeight {
                node.position.y += info.backgroundHeight * 4
            }
        }
    }
    
    func prepareStartNodes(screenSize: CGSize) {
        prepareBackgroundNodes()
        
        let scoreNodePos = CGPoint(x: screenSize.width / 2, y: screenSize.height - 59 - 45 / 2)
        scoreNode.setup(screenSize: size, score: info.score, nodePosition: scoreNodePos)
        scoreNode.zPosition = info.hudZPos
        addChild(scoreNode)
        
        trackerNode = NJPowerUpTrackerNode(size: info.trackerSize, defaultCollectible: CollectibleType.empty)
        trackerNode.position = CGPoint(x: 70 + trackerNode.frame.width / 2, y: 40 + trackerNode.frame.height / 2)
        trackerNode.zPosition = info.hudZPos
        addChild(trackerNode)
        
        let wallWidth: CGFloat = info.wallWidth
        let wallHeight: CGFloat = screenSize.height
        
        let leftWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "leftWall"))
        let leftWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "leftWall"))
        leftWallTop.zPosition = info.wallZPos
        leftWallBot.zPosition = info.wallZPos
        addChild(leftWallTop)
        addChild(leftWallBot)
        
        let rightWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: size.width - wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "rightWall"))
        let rightWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                position: CGPoint(x: size.width - wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "rightWall"))
        rightWallTop.zPosition = info.wallZPos
        rightWallBot.zPosition = info.wallZPos
        addChild(rightWallTop)
        addChild(rightWallBot)
        
        let ground = NJGroundNode(size: CGSize(width: screenSize.width, height: info.groundHeight), position: CGPoint(x: size.width / 2, y: 0))
        ground.zPosition = info.branchZPos
        addChild(ground)
        
        let player = NJPlayerNode(size: info.playerSize, position: rightWallPlayerPos, texture: SKTexture(imageNamed: "squirrelRunRight"))
        player.zPosition = info.playerZPos
        addChild(player)
        self.player = player
    }
    
    func prepareGameContext() {
        guard let context else { return }

        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func setupIdleUI() {
        let titleNode = NJTitleNode(size: CGSize(width: size.width - (info.obstacleXPos * 2), height: 122), position: CGPoint(x: size.width / 2, y: size.height / 2 + 100), texture: SKTexture(imageNamed: "title"))
        titleNode.name = "titleNode"
        addChild(titleNode)

        let playButton = SKLabelNode(text: "Play")
        playButton.name = "playButton"
        playButton.fontSize = 30
        playButton.fontColor = .white
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playButton)
    }

    func removeIdleUI() {
        childNode(withName: "titleNode")?.removeFromParent()
        childNode(withName: "playButton")?.removeFromParent()
    }
    
    func updateGameSpeed() {
        // Adjust spawn frequency
        removeAction(forKey: "spawnObstacles")

        let spawnAction = SKAction.run { [weak self] in
            self?.spawnRandomObstacle()
        }
        let delay = SKAction.wait(forDuration: 2.0 / info.gameSpeed) // Spawn faster as gameSpeed increases
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawnObstacles")

        // Adjust existing obstacles
        enumerateChildNodes(withName: "obstacle") { node, _ in
            if let obstacle = node as? SKSpriteNode {
                obstacle.speed = self.info.gameSpeed // Apply speed scaling to obstacles
            }
        }

        // Optionally adjust other elements, e.g., player behavior
    }
    
    func runObstacles() {
        let speedIncreaseAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    guard let self else { return }
                    info.gameSpeed += 0.01
                    //self.updateGameSpeed()
                },
                SKAction.wait(forDuration: 10.0) // Adjust the interval as needed
            ])
        )
        run(speedIncreaseAction)
        
        let spawnAction = SKAction.run { [weak self] in self?.spawnRandomObstacle() }
        let delay = SKAction.wait(forDuration: info.obstacleSpawnRate)
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let context else { return }
        
        if !(context.stateMachine?.currentState is NJGameIdleState) && !(context.stateMachine?.currentState is NJFallingState) {
            scrollScreen()
            info.score += 1
            scoreNode.updateScore(with: info.score)
            
            
        }
    }

    // MARK: - Spawners
    
    func spawnRandomObstacle() {
        let obstacleSize = NJGameInfo.obstacleSize
        let obstacleYPos = size.height
        
        let functions: [() -> Void] = [
            { self.spawnFruit(obstacleSize: NJGameInfo.fruitSize, yPos: obstacleYPos) },
            { self.spawnHawk(obstacleSize: NJGameInfo.hawkSize, yPos: obstacleYPos) },
            { self.spawnFox(obstacleSize: NJGameInfo.foxSize, yPos: obstacleYPos) },
            { self.spawnNut(obstacleSize: obstacleSize, yPos: obstacleYPos) },
            { self.spawnBomb(obstacleSize: obstacleSize, yPos: obstacleYPos) },
            { self.spawnBranch(obstacleSize: self.info.branchSize, yPos: obstacleYPos) }
        ]
            
        let randomIndex = Int.random(in: 0..<functions.count)
        functions[randomIndex]()
    }
    
    func spawnFruit(obstacleSize: CGSize, yPos: CGFloat) {
        let xPos: CGFloat = Bool.random() ? info.obstacleXPos : size.width - info.obstacleXPos
        
        let fruitTextures = fruitAtlas.textureNames.map { fruitAtlas.textureNamed($0) }
        let randomTexture = fruitTextures.randomElement() ?? fruitTextures[0]
        
        let texture = SKTexture(imageNamed: "pinecone")
        
        let obstacle = NJFruitNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: texture)
        let targetPos = CGPoint(x: xPos, y: 0)
        
        let moveAction = SKAction.move(to: targetPos, duration: size.height / info.fruitSpeed)
        let removeAction = SKAction.removeFromParent()
        let rotateAction = SKAction.rotate(byAngle: 90.0, duration: 20.0)
        
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
        obstacle.run(SKAction.sequence([rotateAction]))
        
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnHawk(obstacleSize: CGSize, yPos: CGFloat) {
        guard let player else { return }
        let xPos: CGFloat = Bool.random() ? info.obstacleXPos : size.width - info.obstacleXPos
        let targetPos = CGPoint(x: xPos == info.obstacleXPos ? size.width - info.obstacleXPos : info.obstacleXPos, y: player.position.y)
        let moveAction = SKAction.move(to: targetPos, duration: size.width / info.hawkSpeed)
        
        let isMovingLeftToRight = xPos == info.obstacleXPos
        // Define the center of the invisible circle
        let circleCenter = CGPoint(x: size.width / 2, y: player.position.y)
        let radius = abs(size.width / 2 - info.obstacleXPos)
        // Create the semi-circle path
        let circularPath = CGMutablePath()
        let startAngle: CGFloat = isMovingLeftToRight ? 0 : .pi  // Start from left or right
        let endAngle: CGFloat = isMovingLeftToRight ? .pi : 0   // Move to the opposite side
        circularPath.addArc(center: circleCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: isMovingLeftToRight)
        let circularMotion = SKAction.follow(circularPath, asOffset: false, orientToPath: false, duration: 2.0)
        
        let removeAction = SKAction.removeFromParent()
        
        
        let obstacle = xPos == info.obstacleXPos ? NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "hawkLeft")) : NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "hawkRight"))
        
        
        obstacle.run(SKAction.sequence([moveAction, circularMotion, removeAction]))
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnFox(obstacleSize: CGSize, yPos: CGFloat) {
        guard let player else { return }
        
        spawnFoxBranch(obstacleSize: obstacleSize, yPos: yPos)
        
        let xPos: CGFloat = Bool.random() ? info.obstacleXPos : size.width - info.obstacleXPos
        let targetPos = CGPoint(x: xPos == info.obstacleXPos ? size.width - info.obstacleXPos : info.obstacleXPos, y: player.position.y - 10.0)
        let obstacle = NJFoxNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos + info.branchHeight), texture: SKTexture(imageNamed: "foxRight1"))
        
        let foxTextures = xPos == info.obstacleXPos ? [
            SKTexture(imageNamed: "foxLeft1"),
            SKTexture(imageNamed: "foxLeft2"),
            SKTexture(imageNamed: "foxLeft3")
        ] : [
            SKTexture(imageNamed: "foxRight1"),
            SKTexture(imageNamed: "foxRight2"),
            SKTexture(imageNamed: "foxRight3")
        ]
        
        let animateAction = SKAction.animate(with: foxTextures, timePerFrame: 0.1, resize: false, restore: true)
        let repeatAnimation = SKAction.repeatForever(animateAction)
        obstacle.run(repeatAnimation)
        
        let moveAction = SKAction.move(to: targetPos, duration: size.width / info.foxSpeed)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        obstacle.run(sequence)
        
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnFoxBranch(obstacleSize: CGSize, yPos: CGFloat) {
        let branch = NJFoxBranchNode(size: CGSize(width: size.width, height: info.branchHeight), position: CGPoint(x: size.width / 2, y: yPos), texture: SKTexture(imageNamed: "foxBranch"))
        let branchTargetPos = CGPoint(x: size.width / 2, y: 0)
        let branchDistance = yPos - branchTargetPos.y
        let branchDuration = branchDistance / (info.scrollSpeed * info.fps)
        
        let moveActionBranch = SKAction.move(to: branchTargetPos, duration: branchDuration)
        let removeActionBranch = SKAction.removeFromParent()
        branch.run(SKAction.sequence([moveActionBranch, removeActionBranch]))
        
        branch.zPosition = info.branchZPos
        addChild(branch)
    }
    
    func spawnBranch(obstacleSize: CGSize, yPos: CGFloat) {
        let xPos: CGFloat = Bool.random() ? info.obstacleXPos : size.width - info.obstacleXPos
        let texture: SKTexture = Bool.random() ? SKTexture(imageNamed: "branchRight") : SKTexture(imageNamed: "branchLeft")
        
        let branch = NJBranchNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: texture)
        let branchTargetPos = CGPoint(x: xPos, y: 0)
        let branchDistance = yPos - branchTargetPos.y
        let branchDuration = branchDistance / (info.scrollSpeed * info.fps)
        
        let moveActionBranch = SKAction.move(to: branchTargetPos, duration: branchDuration)
        let removeActionBranch = SKAction.removeFromParent()
        let moveSequence = SKAction.sequence([moveActionBranch, removeActionBranch])
        
        branch.run(moveSequence, withKey: "moveBranch") // Assign a key to stop the action later
        branch.zPosition = info.branchZPos
        addChild(branch)
    }

    
    func spawnNut(obstacleSize: CGSize, yPos: CGFloat) {
        let xPos: CGFloat = CGFloat.random(in: info.obstacleXPos...(size.width - info.obstacleXPos))
        
        let obstacle = NJNutNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "nut"))
        let targetPos = CGPoint(x: xPos, y: 0)
        
        let moveAction = SKAction.move(to: targetPos, duration: size.height / info.nutSpeed)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
        
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnBomb(obstacleSize: CGSize, yPos: CGFloat) {
        let xPos: CGFloat = CGFloat.random(in: info.obstacleXPos...(size.width - info.obstacleXPos))
        
        let obstacle = NJBombNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "bomb"))
        let targetPos = CGPoint(x: xPos, y: 0)
        
        let moveAction = SKAction.move(to: targetPos, duration: size.height / info.bombSpeed)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
        
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
    }
    
    func togglePlayerLocation(currentPlayerPos: CGPoint) {
        let isOnRightWall = Int(currentPlayerPos.x) == Int(rightWallPlayerPos.x)
        let targetPos = isOnRightWall ? leftWallPlayerPos : rightWallPlayerPos
        
        let moveAction = SKAction.move(to: targetPos, duration: 0.3)
        moveAction.timingMode = .easeInEaseOut
//        let rotationAngle: CGFloat = isOnRightWall ? .pi : -.pi
//        let rotationAction = SKAction.rotate(byAngle: rotationAngle, duration: 0.3)
//        let combinedAction = SKAction.group([moveAction, rotationAction])
        player?.run(moveAction)
    }
    
    func getPlayerTextureAndSize() {
        guard let stateMachine = context?.stateMachine,
              let currentState = stateMachine.currentState,
              let player else { return }
        
        // Determine the player's texture and size based on state and conditions
        switch (info.playerIsProtected, info.playerIsDisguised, currentState) {
        case (true, true, is NJRunningState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.runRProtDisg
                : info.runLProtDisg
            player.size = info.playerProtSize

        case (true, true, is NJJumpingState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.flyLProtDisg
                : info.flyRProtDisg
            player.size = info.playerProtFlightSize

        case (true, false, is NJRunningState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.runRProt
                : info.runLProt
            player.size = info.playerProtSize

        case (true, false, is NJJumpingState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.flyLProt
                : info.flyRProt
            player.size = info.playerProtFlightSize

        case (false, true, is NJRunningState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.runRDisg
                : info.runLDisg
            player.size = info.playerSize

        case (false, true, is NJJumpingState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.flyLDisg
                : info.flyRDisg
            player.size = info.playerFlightSize

        case (false, false, is NJRunningState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.runR
                : info.runL
            player.size = info.playerSize

        case (false, false, is NJJumpingState):
            player.texture = player.position.x == rightWallPlayerPos.x
                ? info.flyL
                : info.flyR
            player.size = info.playerFlightSize

        default:
            player.texture = info.runR
            player.size = info.playerSize
        }
    }
    
    // MARK: - User Input
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let stateMachine = context?.stateMachine,
              let currentState = stateMachine.currentState, let player else { return }
        
        if currentState is NJGameIdleState {
            stateMachine.enter(NJRunningState.self)
            
        } else if currentState is NJRunningState {
            stateMachine.enter(NJJumpingState.self)
            togglePlayerLocation(currentPlayerPos: player.position)
            
            let delayAction = SKAction.wait(forDuration: 0.3)
            let switchStateAction = SKAction.run { stateMachine.enter(NJRunningState.self) }
            let sequence = SKAction.sequence([delayAction, switchStateAction])
            run(sequence)
            
        } else if currentState is NJJumpingState {
            print("cannot tap you're jumping")
            
        } else if currentState is NJFallingState {
            print("cannot tap you're falling")
            
        } else if currentState is NJGameOverState {
            print("game over tap placeholder")
        } else {
            print("unknown state")
        }
    }
    
    // MARK: - Physics Contacts
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let context else { return }
        guard let stateMachine = context.stateMachine else { return }
        
        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        //player hits wall
        //        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.wall) ||
        //            (contactA == NJPhysicsCategory.wall && contactB == NJPhysicsCategory.player) {
        //            stateMachine.enter(NJRunningState.self)
        //            return
        //        }
        
        //player hits ground
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.ground) ||
            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.player) {
            print("player hit ground")
            let playerNode = (contactA == NJPhysicsCategory.player) ? contact.bodyA.node : contact.bodyB.node
            playerNode?.removeFromParent()
            stateMachine.enter(NJGameOverState.self)
            return
        }
        
        //player hits branch
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.branch) ||
            (contactA == NJPhysicsCategory.branch && contactB == NJPhysicsCategory.player) {
            print("player hit branch")
            let branchNode = (contactA == NJPhysicsCategory.branch) ? contact.bodyA.node : contact.bodyB.node
            branchNode?.removeAction(forKey: "moveBranch")
            stateMachine.enter(NJFallingState.self)
        }
        
        //player hits fruit
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fruit) ||
            (contactA == NJPhysicsCategory.fruit && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !info.playerIsInvincible {
                if info.playerIsProtected {
                    info.playerIsProtected = false
                    getPlayerTextureAndSize()
                    return
                }
                print("player hit fruit while running")
                stateMachine.enter(NJFallingState.self)
                
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit fruit while jumping")
                let fruitNode = (contactA == NJPhysicsCategory.fruit) ? contact.bodyA.node : contact.bodyB.node
                fruitNode?.removeFromParent()
                
                info.hawksCollected = 0
                info.foxesCollected = 0
                
                if info.fruitsCollected == 2 {
                    fruitPowerUp()
                    info.fruitsCollected += 1
                    
                } else if info.fruitsCollected == 1 {
                    info.fruitsCollected += 1
                    
                } else if info.fruitsCollected == 0 {
                    trackerNode.resetDisplay()
                    info.fruitsCollected += 1
                    
                }
                trackerNode.updatePowerUpDisplay(for: info.fruitsCollected, with: CollectibleType.fruit)
            }
        }
        
        //player hits hawk
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.hawk) ||
            (contactA == NJPhysicsCategory.hawk && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !info.playerIsInvincible {
                if info.playerIsProtected {
                    info.playerIsProtected = false
                    getPlayerTextureAndSize()
                    return
                }
                print("player hit hawk while running")
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit hawk while jumping")
                let hawkNode = (contactA == NJPhysicsCategory.hawk) ? contact.bodyA.node : contact.bodyB.node
                hawkNode?.removeFromParent()
                
                info.fruitsCollected = 0
                info.foxesCollected = 0
                
                if info.hawksCollected == 2 {
                    hawkPowerUp()
                    info.hawksCollected += 1
                    
                } else if info.hawksCollected == 1 {
                    info.hawksCollected += 1
                    
                } else if info.hawksCollected == 0 {
                    trackerNode.resetDisplay()
                    info.hawksCollected += 1
                    
                }
                trackerNode.updatePowerUpDisplay(for: info.hawksCollected, with: CollectibleType.hawk)
            }
        }
        
        //player hits fox
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fox) ||
            (contactA == NJPhysicsCategory.fox && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !info.playerIsDisguised {
                if info.playerIsProtected {
                    info.playerIsProtected = false
                    getPlayerTextureAndSize()
                    return
                }
                print("player hit fox while running")
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit fox while jumping")
                let foxNode = (contactA == NJPhysicsCategory.fox) ? contact.bodyA.node : contact.bodyB.node
                foxNode?.removeFromParent()
                
                info.fruitsCollected = 0
                info.hawksCollected = 0
                
                if info.foxesCollected == 2 {
                    foxPowerUp()
                    info.foxesCollected += 1
                    
                } else if info.foxesCollected == 1 {
                    info.foxesCollected += 1
                    
                } else if info.foxesCollected == 0 {
                    trackerNode.resetDisplay()
                    info.foxesCollected += 1
                    
                }
                trackerNode.updatePowerUpDisplay(for: info.foxesCollected, with: CollectibleType.fox)
            }
        }
        
        //player hits nut
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.nut) ||
            (contactA == NJPhysicsCategory.nut && contactB == NJPhysicsCategory.player) {
            print("player hit nut")
            let nutNode = (contactA == NJPhysicsCategory.nut) ? contact.bodyA.node : contact.bodyB.node
            nutNode?.removeFromParent()
            info.nutsCollected += 1
            info.playerIsProtected = true
            getPlayerTextureAndSize()
            return
        }
        
        //player hits bomb
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.bomb) ||
            (contactA == NJPhysicsCategory.bomb && contactB == NJPhysicsCategory.player) {
            if !info.playerIsInvincible {
                if info.playerIsProtected {
                    info.playerIsProtected = false
                    getPlayerTextureAndSize()
                    return
                }
                print("player hit bomb")
                let bombNode = (contactA == NJPhysicsCategory.bomb) ? contact.bodyA.node : contact.bodyB.node
                stateMachine.enter(NJFallingState.self)
                return
            }
        }
        
        //branch hits ground
        if (contactA == NJPhysicsCategory.foxBranch && contactB == NJPhysicsCategory.ground) ||
            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.foxBranch) {
            print("branch hit ground")
            let foxBranchNode = (contactA == NJPhysicsCategory.foxBranch) ? contact.bodyA.node : contact.bodyB.node
            foxBranchNode?.removeFromParent()
            return
        }
        
        //fruit shoot
        if contactA == NJPhysicsCategory.shoot {
            guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
            handleContactBetween(shoot: nodeA, target: nodeB)
        } else if contactB == NJPhysicsCategory.shoot {
            guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
            handleContactBetween(shoot: nodeB, target: nodeA)
        }
    }
    
    func handleContactBetween(shoot: SKNode, target: SKNode) {
        // Check the category of the target and handle accordingly
        if target.physicsBody?.categoryBitMask == NJPhysicsCategory.fruit ||
           target.physicsBody?.categoryBitMask == NJPhysicsCategory.hawk ||
           target.physicsBody?.categoryBitMask == NJPhysicsCategory.fox ||
           target.physicsBody?.categoryBitMask == NJPhysicsCategory.bomb {
            
            // Remove the target node
            target.removeFromParent()
            print("\(target.name ?? "Unknown") was hit and removed!")
            
            // Optionally remove the shoot node as well (if it disappears on contact)
            shoot.removeFromParent()
        }
    }
    
    // MARK: - Powerup Functions
    
    func fruitPowerUp() {
        print("Power-up activated: Shooting fruits!")

        let shootAction = SKAction.run { [weak self] in
            self?.shootFruit()
        }

        let waitAction = SKAction.wait(forDuration: info.fruitShootInterval)
        let shootingSequence = SKAction.sequence([shootAction, waitAction])

        // Run the shooting sequence repeatedly for 5 seconds
        let repeatShooting = SKAction.repeatForever(shootingSequence)
        let stopAction = SKAction.run { [weak self] in
            self?.removeAction(forKey: "fruitShooting")
            print("Power-up ended.")
        }

        let powerUpDuration = SKAction.sequence([SKAction.wait(forDuration: info.fruitShootDuration), stopAction])

        // Start the repeating shooting action and schedule it to stop after 5 seconds
        run(repeatShooting, withKey: "fruitShooting")
        run(powerUpDuration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + info.fruitShootDuration) {
            self.info.fruitsCollected = 0
            self.trackerNode.updatePowerUpDisplay(for: self.info.fruitsCollected, with: CollectibleType.fruit)
        }
    }
    
    func shootFruit() {
        guard let player else { return }
        
        let fruitTextures = fruitAtlas.textureNames.map { fruitAtlas.textureNamed($0) }
        let randomTexture = fruitTextures.randomElement() ?? fruitTextures[0]
        
        let texture = SKTexture(imageNamed: "pinecone")
        
        let fruit = NJFruitShootNode(size: NJGameInfo.obstacleSize, position: CGPoint(x: player.position.x, y: player.position.y + NJGameInfo.obstacleSize.height), texture: texture)
        let targetPos = CGPoint(x: player.position.x, y: size.height + NJGameInfo.obstacleSize.height)
        
        let moveAction = SKAction.move(to: targetPos, duration: 1.0)//size.height / NJGameInfo.fruitShootSpeed)
        let removeAction = SKAction.removeFromParent()
        fruit.run(SKAction.sequence([moveAction, removeAction]))
        
        fruit.zPosition = info.obstacleZPos
        addChild(fruit)
    }
    
    func hawkPowerUp() {
        info.playerIsInvincible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + info.hawkPULength) {
            self.info.playerIsInvincible = false
            self.info.hawksCollected = 0
            self.trackerNode.updatePowerUpDisplay(for: self.info.hawksCollected, with: CollectibleType.hawk)
        }
    }
    
    func foxPowerUp() {
        info.playerIsDisguised = true
        DispatchQueue.main.asyncAfter(deadline: .now() + info.foxDisguiseDuration) {
            self.info.playerIsDisguised = false
            self.info.foxesCollected = 0
            self.trackerNode.updatePowerUpDisplay(for: self.info.fruitsCollected, with: CollectibleType.fruit)
            self.getPlayerTextureAndSize()
        }
    }
    
    // MARK: - Other
    
    func displayScore() {
        scoreNode.removeFromParent()
        scoreNode.setup(screenSize: size, score: info.score, nodePosition: CGPoint(x: size.width / 2, y: size.height / 2 + 50))
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

//
//  NJGameScene.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//
//
//import SpriteKit
//import GameplayKit
//
//class NJGameScene: SKScene, SKPhysicsContactDelegate {
//    weak var context: NJGameContext?
//    
//    var player: NJPlayerNode?
//    let scoreNode = NJScoreNode()
//    var trackerNode: NJPowerUpTrackerNode!
//    var backgroundNodes: [NJBackgroundNode] = []
//    
//    let fruitAtlas = SKTextureAtlas(named: "FruitAtlas")
//    let backgroundAtlas = SKTextureAtlas(named: "BackgroundAtlas")
//    let playerTexture = SKTexture(imageNamed: "squirrelRunRight")
//    
//    let leftWallPlayerPos: CGPoint
//    let rightWallPlayerPos: CGPoint
//    
//    init(context: NJGameContext, size: CGSize) {
//        self.leftWallPlayerPos = CGPoint(x: NJGameInfo.obstacleXPos, y: size.height / 2.0)
//        self.rightWallPlayerPos = CGPoint(x: size.width - NJGameInfo.obstacleXPos, y: size.height / 2.0)
//        self.context = context
//        super.init(size: size)
//        
//        fruitAtlas.preload {
//            print("fruit sprite preloaded")
//        }
//        backgroundAtlas.preload {
//            print("background sprite preloaded")
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func didMove(to view: SKView) {
//        guard let context else { return }
//        
//        prepareGameContext()
//        prepareStartNodes(screenSize: size)
//        physicsWorld.contactDelegate = self
//        context.stateMachine?.enter(NJGameIdleState.self)
//    }
//    
//    func prepareBackgroundNodes() {
//        let backgroundTextures = backgroundAtlas.textureNames.sorted().map { backgroundAtlas.textureNamed($0) }
//        
//        let fallNode = NJBackgroundNode(texture: backgroundTextures[0])
//        let winterNode = NJBackgroundNode(texture: backgroundTextures[1])
//        let springNode = NJBackgroundNode(texture: backgroundTextures[2])
//        let summerNode = NJBackgroundNode(texture: backgroundTextures[3])
//        
//        fallNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight / 2)
//        winterNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight * 1.5)
//        springNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight * 2.5)
//        summerNode.position = CGPoint(x: frame.midX, y: NJGameInfo.backgroundHeight * 3.5)
//        
//        self.backgroundNodes.append(fallNode)
//        self.backgroundNodes.append(winterNode)
//        self.backgroundNodes.append(springNode)
//        self.backgroundNodes.append(summerNode)
//        
//        fallNode.zPosition = NJGameInfo.bgZPos
//        winterNode.zPosition = NJGameInfo.bgZPos
//        springNode.zPosition = NJGameInfo.bgZPos
//        summerNode.zPosition = NJGameInfo.bgZPos
//        
//        addChild(fallNode)
//        addChild(winterNode)
//        addChild(springNode)
//        addChild(summerNode)
//    }
//    
//    func scrollScreen() {
//        children
//            .compactMap { $0 as? NJWallNode }
//            .forEach { wallNode in wallNode.position.y -= NJGameInfo.scrollSpeed
//                if wallNode.position.y <= -wallNode.size.height / 2 {
//                    wallNode.position.y += wallNode.size.height * 2
//                }
//            }
//        
//        for node in self.backgroundNodes {
//            node.position.y -= NJGameInfo.backgroundScrollSpeed
//            if node.position.y <= -NJGameInfo.backgroundHeight {
//                node.position.y += NJGameInfo.backgroundHeight * 4
//            }
//        }
//    }
//    
//    func prepareStartNodes(screenSize: CGSize) {
//        guard let context else { return }
//        
//        prepareBackgroundNodes()
//        
//        let scoreNodePos = CGPoint(x: screenSize.width / 2, y: screenSize.height - 59 - 45 / 2)
//        scoreNode.setup(screenSize: size, score: context.gameInfo.score, nodePosition: scoreNodePos)
//        scoreNode.zPosition = NJGameInfo.hudZPos
//        addChild(scoreNode)
//        
//        trackerNode = NJPowerUpTrackerNode(size: NJGameInfo.trackerSize)
//        trackerNode.position = CGPoint(x: 70 + trackerNode.frame.width / 2, y: 40 + trackerNode.frame.height / 2)
//        trackerNode.zPosition = NJGameInfo.hudZPos
//        addChild(trackerNode)
//        
//        let wallWidth: CGFloat = NJGameInfo.wallWidth
//        let wallHeight: CGFloat = screenSize.height
//        
//        let leftWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
//                                     position: CGPoint(x: wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "leftWall"))
//        let leftWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
//                                     position: CGPoint(x: wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "leftWall"))
//        leftWallTop.zPosition = NJGameInfo.wallZPos
//        leftWallBot.zPosition = NJGameInfo.wallZPos
//        addChild(leftWallTop)
//        addChild(leftWallBot)
//        
//        let rightWallTop = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
//                                     position: CGPoint(x: size.width - wallWidth / 2, y: 0), texture: SKTexture(imageNamed: "rightWall"))
//        let rightWallBot = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
//                                position: CGPoint(x: size.width - wallWidth / 2, y: wallHeight), texture: SKTexture(imageNamed: "rightWall"))
//        rightWallTop.zPosition = NJGameInfo.wallZPos
//        rightWallBot.zPosition = NJGameInfo.wallZPos
//        addChild(rightWallTop)
//        addChild(rightWallBot)
//        
//        let ground = NJGroundNode(size: CGSize(width: screenSize.width, height: NJGameInfo.groundHeight), position: CGPoint(x: size.width / 2, y: 0))
//        ground.zPosition = NJGameInfo.branchZPos
//        addChild(ground)
//        
//        let player = NJPlayerNode(size: NJGameInfo.playerSize, position: rightWallPlayerPos, texture: playerTexture)
//        player.zPosition = NJGameInfo.playerZPos
//        addChild(player)
//        self.player = player
//    }
//    
//    func prepareGameContext() {
//        guard let context else { return }
//
//        context.scene = self
//        context.updateLayoutInfo(withScreenSize: size)
//        context.configureStates()
//    }
//    
//    func setupIdleUI() {
//        let titleNode = NJTitleNode(size: CGSize(width: size.width, height: 122), position: CGPoint(x: size.width / 2, y: size.height / 2 + 100), texture: SKTexture(imageNamed: "title"))
//        titleNode.name = "titleNode"
//        addChild(titleNode)
//
//        let playButton = SKLabelNode(text: "Play")
//        playButton.name = "playButton"
//        playButton.fontSize = 30
//        playButton.fontColor = .white
//        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        addChild(playButton)
//    }
//
//    func removeIdleUI() {
//        childNode(withName: "titleNode")?.removeFromParent()
//        childNode(withName: "playButton")?.removeFromParent()
//    }
//    
//    func updateGameSpeed() {
//        // Adjust spawn frequency
//        removeAction(forKey: "spawnObstacles")
//
//        let spawnAction = SKAction.run { [weak self] in
//            self?.spawnRandomObstacle()
//        }
//        let delay = SKAction.wait(forDuration: 2.0 / NJGameInfo.gameSpeed) // Spawn faster as gameSpeed increases
//        let spawnSequence = SKAction.sequence([spawnAction, delay])
//        run(SKAction.repeatForever(spawnSequence), withKey: "spawnObstacles")
//
//        // Adjust existing obstacles
//        enumerateChildNodes(withName: "obstacle") { node, _ in
//            if let obstacle = node as? SKSpriteNode {
//                obstacle.speed = NJGameInfo.gameSpeed // Apply speed scaling to obstacles
//            }
//        }
//
//        // Optionally adjust other elements, e.g., player behavior
//    }
//    
//    func runObstacles() {
//        let speedIncreaseAction = SKAction.repeatForever(
//            SKAction.sequence([
//                SKAction.run { [weak self] in
//                    guard let self else { return }
//                    NJGameInfo.gameSpeed += 0.05
//                    //self.updateGameSpeed()
//                },
//                SKAction.wait(forDuration: 10.0) // Adjust the interval as needed
//            ])
//        )
//        run(speedIncreaseAction)
//        
//        let spawnAction = SKAction.run { [weak self] in self?.spawnRandomObstacle() }
//        let delay = SKAction.wait(forDuration: NJGameInfo.obstacleSpawnRate)
//        let spawnSequence = SKAction.sequence([spawnAction, delay])
//        run(SKAction.repeatForever(spawnSequence))
//    }
//    
//    override func update(_ currentTime: TimeInterval) {
//        guard let context else { return }
//        
//        if !(context.stateMachine?.currentState is NJGameIdleState) {
//            scrollScreen()
//            context.gameInfo.score += 1
//            scoreNode.updateScore(with: context.gameInfo.score)
//            
//            let currentPlayerPos = player?.position
//            let targetPos = player?.position == rightWallPlayerPos
//                ? leftWallPlayerPos
//                : rightWallPlayerPos
//            
//            if currentPlayerPos?.x == targetPos.x {
//                context.stateMachine?.enter(NJRunningState.self)
//            }
//        }
//    }
//
//    // MARK: - Spawners
//    
//    func spawnRandomObstacle() {
//        let obstacleSize = NJGameInfo.obstacleSize
//        let obstacleYPos = size.height
//        
//        let functions: [() -> Void] = [
//            { self.spawnFruit(obstacleSize: obstacleSize, yPos: obstacleYPos) },
//            { self.spawnHawk(obstacleSize: NJGameInfo.hawkSize, yPos: obstacleYPos) },
//            { self.spawnFox(obstacleSize: NJGameInfo.foxSize, yPos: obstacleYPos) },
//            { self.spawnNut(obstacleSize: obstacleSize, yPos: obstacleYPos) },
//            { self.spawnBomb(obstacleSize: obstacleSize, yPos: obstacleYPos) }
//        ]
//            
//        let randomIndex = Int.random(in: 0..<functions.count)
//        functions[randomIndex]()
//    }
//    
//    func spawnFruit(obstacleSize: CGSize, yPos: CGFloat) {
//        let xPos: CGFloat = Bool.random() ? NJGameInfo.obstacleXPos : size.width - NJGameInfo.obstacleXPos
//        
//        let fruitTextures = fruitAtlas.textureNames.map { fruitAtlas.textureNamed($0) }
//        let randomTexture = fruitTextures.randomElement() ?? fruitTextures[0]
//        
//        let obstacle = NJFruitNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: randomTexture)
//        let targetPos = CGPoint(x: xPos, y: 0)
//        
//        let moveAction = SKAction.move(to: targetPos, duration: size.height / NJGameInfo.fruitSpeed)
//        let removeAction = SKAction.removeFromParent()
//        obstacle.run(SKAction.sequence([moveAction, removeAction]))
//        
//        obstacle.zPosition = NJGameInfo.obstacleZPos
//        addChild(obstacle)
//    }
//    
//    func spawnHawk(obstacleSize: CGSize, yPos: CGFloat) {
//        let xPos: CGFloat = Bool.random() ? NJGameInfo.obstacleXPos : size.width - NJGameInfo.obstacleXPos
//        let targetPos = CGPoint(x: xPos == NJGameInfo.obstacleXPos ? size.width - NJGameInfo.obstacleXPos : NJGameInfo.obstacleXPos, y: player?.position.y ?? 0)
//        let obstacle = xPos == NJGameInfo.obstacleXPos ? NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "hawkLeft")) : NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "hawkRight"))
//        
//        let moveAction = SKAction.move(to: targetPos, duration: size.width / NJGameInfo.hawkSpeed)
//        let removeAction = SKAction.removeFromParent()
//        obstacle.run(SKAction.sequence([moveAction, removeAction]))
//        obstacle.zPosition = NJGameInfo.obstacleZPos
//        addChild(obstacle)
//    }
//    
//    func spawnFox(obstacleSize: CGSize, yPos: CGFloat) {
//        guard let player else { return }
//        
//        spawnFoxBranch(obstacleSize: obstacleSize, yPos: yPos)
//        
//        let xPos: CGFloat = Bool.random() ? NJGameInfo.obstacleXPos : size.width - NJGameInfo.obstacleXPos
//        let targetPos = CGPoint(x: xPos == NJGameInfo.obstacleXPos ? size.width - NJGameInfo.obstacleXPos : NJGameInfo.obstacleXPos, y: player.position.y - 10.0)
//        let obstacle = NJFoxNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos + NJGameInfo.branchHeight), texture: SKTexture(imageNamed: "fox1"))
//        
//        let foxTextures = [
//                SKTexture(imageNamed: "fox1"),
//                SKTexture(imageNamed: "fox2"),
//                SKTexture(imageNamed: "fox3")
//            ]
//        let animateAction = SKAction.animate(with: foxTextures, timePerFrame: 0.1, resize: false, restore: true)
//        let repeatAnimation = SKAction.repeatForever(animateAction)
//        obstacle.run(repeatAnimation)
//        
//        let moveAction = SKAction.move(to: targetPos, duration: size.width / NJGameInfo.foxSpeed)
//        let removeAction = SKAction.removeFromParent()
//        let sequence = SKAction.sequence([moveAction, removeAction])
//        obstacle.run(sequence)
//        
//        obstacle.zPosition = NJGameInfo.obstacleZPos
//        addChild(obstacle)
//    }
//    
//    func spawnFoxBranch(obstacleSize: CGSize, yPos: CGFloat) {
//        let branch = NJFoxBranchNode(size: CGSize(width: size.width, height: NJGameInfo.branchHeight), position: CGPoint(x: size.width / 2, y: yPos), texture: SKTexture(imageNamed: "foxBranch"))
//        let branchTargetPos = CGPoint(x: size.width / 2, y: 0)
//        let branchDistance = yPos - branchTargetPos.y
//        let branchDuration = branchDistance / (NJGameInfo.scrollSpeed * NJGameInfo.fps)
//        
//        let moveActionBranch = SKAction.move(to: branchTargetPos, duration: branchDuration)
//        let removeActionBranch = SKAction.removeFromParent()
//        branch.run(SKAction.sequence([moveActionBranch, removeActionBranch]))
//        
//        branch.zPosition = NJGameInfo.branchZPos
//        addChild(branch)
//    }
//    
//    func spawnNut(obstacleSize: CGSize, yPos: CGFloat) {
//        let xPos: CGFloat = CGFloat.random(in: NJGameInfo.obstacleXPos...(size.width - NJGameInfo.obstacleXPos))
//        
//        let obstacle = NJNutNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "nut"))
//        let targetPos = CGPoint(x: xPos, y: 0)
//        
//        let moveAction = SKAction.move(to: targetPos, duration: size.height / NJGameInfo.nutSpeed)
//        let removeAction = SKAction.removeFromParent()
//        obstacle.run(SKAction.sequence([moveAction, removeAction]))
//        
//        obstacle.zPosition = NJGameInfo.obstacleZPos
//        addChild(obstacle)
//    }
//    
//    func spawnBomb(obstacleSize: CGSize, yPos: CGFloat) {
//        let xPos: CGFloat = CGFloat.random(in: NJGameInfo.obstacleXPos...(size.width - NJGameInfo.obstacleXPos))
//        
//        let obstacle = NJBombNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "bomb"))
//        let targetPos = CGPoint(x: xPos, y: 0)
//        
//        let moveAction = SKAction.move(to: targetPos, duration: size.height / NJGameInfo.bombSpeed)
//        let removeAction = SKAction.removeFromParent()
//        obstacle.run(SKAction.sequence([moveAction, removeAction]))
//        
//        obstacle.zPosition = NJGameInfo.obstacleZPos
//        addChild(obstacle)
//    }
//    
//    func togglePlayerLocation(currentPlayerPos: CGPoint) {
//        let isOnRightWall = Int(currentPlayerPos.x) == Int(rightWallPlayerPos.x)
//        let targetPos = isOnRightWall ? leftWallPlayerPos : rightWallPlayerPos
//        
//        let moveAction = SKAction.move(to: targetPos, duration: 0.3)
//        moveAction.timingMode = .easeInEaseOut
//        let rotationAngle: CGFloat = isOnRightWall ? .pi : -.pi
//        let rotationAction = SKAction.rotate(byAngle: rotationAngle, duration: 0.3)
//        let combinedAction = SKAction.group([moveAction, rotationAction])
//        player?.run(combinedAction)
//    }
//    
//    // MARK: - User Input
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let stateMachine = context?.stateMachine,
//              let currentState = stateMachine.currentState else { return }
//        if currentState is NJGameIdleState {
//            stateMachine.enter(NJRunningState.self)
//            
//        } else if currentState is NJRunningState {
//            stateMachine.enter(NJJumpingState.self)
//            
//            if let touch = touches.first {
//                (stateMachine.currentState as? NJJumpingState)?.handleTouch(touch)
//            }
//        } else if currentState is NJGameOverState {
//            if let touch = touches.first {
//                (stateMachine.currentState as? NJGameOverState)?.handleTouch(touch)
//            }
//        } else {
//            print("Tap ignored")
//        }
//    }
//    
//    // MARK: - Physics Contacts
//    
//    func didBegin(_ contact: SKPhysicsContact) {
//        guard let context else { return }
//        guard let stateMachine = context.stateMachine else { return }
//
//        let contactA = contact.bodyA.categoryBitMask
//        let contactB = contact.bodyB.categoryBitMask
//        
//        //player hits wall
////        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.wall) ||
////            (contactA == NJPhysicsCategory.wall && contactB == NJPhysicsCategory.player) {
////            stateMachine.enter(NJRunningState.self)
////            return
////        }
//        
//        //player hits ground
//        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.ground) ||
//            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.player) {
//            print("player hit ground")
//            stateMachine.enter(NJGameOverState.self)
//            return
//        }
//        
//        //player hits fruit
//        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fruit) ||
//            (contactA == NJPhysicsCategory.fruit && contactB == NJPhysicsCategory.player) {
//            if stateMachine.currentState is NJRunningState && !context.gameInfo.playerIsInvincible {
//                if context.gameInfo.playerIsProtected {
//                    context.gameInfo.playerIsProtected = false
//                    player?.texture = SKTexture(imageNamed: "player")
//                    return
//                }
//                print("player hit fruit while running")
//                player?.toggleGravity()
//                stateMachine.enter(NJFallingState.self)
//            } else if stateMachine.currentState is NJJumpingState {
//                print("player hit fruit while jumping")
//                let fruitNode = (contactA == NJPhysicsCategory.fruit) ? contact.bodyA.node : contact.bodyB.node
//                fruitNode?.removeFromParent()
//                
//                context.gameInfo.hawksCollected = 0
//                context.gameInfo.foxesCollected = 0
//                if context.gameInfo.fruitsCollected == 2 {
//                    fruitPowerUp()
//                    context.gameInfo.fruitsCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.fruitsCollected, with: CollectibleType.fruit)
//                } else if context.gameInfo.fruitsCollected == 1 {
//                    context.gameInfo.fruitsCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.fruitsCollected, with: CollectibleType.fruit)
//                } else if context.gameInfo.fruitsCollected == 0 {
//                    trackerNode.resetDisplay()
//                    context.gameInfo.fruitsCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.fruitsCollected, with: CollectibleType.fruit)
//                }
//            }
//        }
//        
//        //player hits hawk
//        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.hawk) ||
//            (contactA == NJPhysicsCategory.hawk && contactB == NJPhysicsCategory.player) {
//            if stateMachine.currentState is NJRunningState && !context.gameInfo.playerIsInvincible {
//                if context.gameInfo.playerIsProtected {
//                    context.gameInfo.playerIsProtected = false
//                    player?.texture = SKTexture(imageNamed: "player")
//                    return
//                }
//                print("player hit hawk while running")
//                player?.toggleGravity()
//                stateMachine.enter(NJFallingState.self)
//            } else if stateMachine.currentState is NJJumpingState {
//                print("player hit hawk while jumping")
//                let hawkNode = (contactA == NJPhysicsCategory.hawk) ? contact.bodyA.node : contact.bodyB.node
//                hawkNode?.removeFromParent()
//                
//                context.gameInfo.fruitsCollected = 0
//                context.gameInfo.foxesCollected = 0
//                if context.gameInfo.hawksCollected == 2 {
//                    hawkPowerUp()
//                    context.gameInfo.hawksCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
//                } else if context.gameInfo.hawksCollected == 1 {
//                    context.gameInfo.hawksCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
//                } else if context.gameInfo.hawksCollected == 0 {
//                    trackerNode.resetDisplay()
//                    context.gameInfo.hawksCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
//                }
//            }
//        }
//        
//        //player hits fox
//        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fox) ||
//            (contactA == NJPhysicsCategory.fox && contactB == NJPhysicsCategory.player) {
//            if stateMachine.currentState is NJRunningState && !context.gameInfo.playerIsInvincible {
//                if context.gameInfo.playerIsProtected {
//                    context.gameInfo.playerIsProtected = false
//                    player?.texture = SKTexture(imageNamed: "player")
//                    return
//                }
//                print("player hit fox while running")
//                player?.toggleGravity()
//                stateMachine.enter(NJFallingState.self)
//            } else if stateMachine.currentState is NJJumpingState {
//                print("player hit fox while jumping")
//                let foxNode = (contactA == NJPhysicsCategory.fox) ? contact.bodyA.node : contact.bodyB.node
//                foxNode?.removeFromParent()
//                
//                context.gameInfo.fruitsCollected = 0
//                context.gameInfo.hawksCollected = 0
//                if context.gameInfo.foxesCollected == 2 {
//                    foxPowerUp()
//                    context.gameInfo.foxesCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.foxesCollected, with: CollectibleType.fox)
//                } else if context.gameInfo.foxesCollected == 1 {
//                    context.gameInfo.foxesCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.foxesCollected, with: CollectibleType.fox)
//                } else if context.gameInfo.foxesCollected == 0 {
//                    trackerNode.resetDisplay()
//                    context.gameInfo.foxesCollected += 1
//                    trackerNode.updatePowerUpDisplay(for: context.gameInfo.foxesCollected, with: CollectibleType.fox)
//                }
//            }
//        }
//        
//        //player hits nut
//        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.nut) ||
//            (contactA == NJPhysicsCategory.nut && contactB == NJPhysicsCategory.player) {
//            print("player hit nut")
//            let nutNode = (contactA == NJPhysicsCategory.nut) ? contact.bodyA.node : contact.bodyB.node
//            nutNode?.removeFromParent()
//            context.gameInfo.nutsCollected += 1
//            context.gameInfo.playerIsProtected = true
//            player?.texture = SKTexture(imageNamed: "protectedPlayer")
//            return
//        }
//        
//        //player hits bomb
//        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.bomb) ||
//            (contactA == NJPhysicsCategory.bomb && contactB == NJPhysicsCategory.player) {
//            if !context.gameInfo.playerIsInvincible {
//                if context.gameInfo.playerIsProtected {
//                    context.gameInfo.playerIsProtected = false
//                    player?.texture = SKTexture(imageNamed: "player")
//                    return
//                }
//                print("player hit bomb")
//                let bombNode = (contactA == NJPhysicsCategory.bomb) ? contact.bodyA.node : contact.bodyB.node
//                player?.toggleGravity()
//                stateMachine.enter(NJFallingState.self)
//                return
//            }
//        }
//        
//        //branch hits ground
//        if (contactA == NJPhysicsCategory.foxBranch && contactB == NJPhysicsCategory.ground) ||
//            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.foxBranch) {
//            print("branch hit ground")
//            let foxBranchNode = (contactA == NJPhysicsCategory.foxBranch) ? contact.bodyA.node : contact.bodyB.node
//            foxBranchNode?.removeFromParent()
//            return
//        }
//    }
//    
//    // MARK: - Powerup Functions
//    
//    func fruitPowerUp() {
//        guard let context else { return }
//    }
//    
//    func hawkPowerUp() {
//        guard let context else { return }
//        
//        context.gameInfo.playerIsInvincible = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + context.gameInfo.hawkPULength) {
//            context.gameInfo.playerIsInvincible = false
//            context.gameInfo.hawksCollected = 0
//            self.trackerNode.updatePowerUpDisplay(for: context.gameInfo.hawksCollected, with: CollectibleType.hawk)
//        }
//    }
//    
//    func foxPowerUp() {
//        guard let context else { return }
//    }
//    
//    // MARK: - Other
//    
//    func displayScore() {
//        guard let context else { return }
//        
//        scoreNode.removeFromParent()
//        scoreNode.setup(screenSize: size, score: context.gameInfo.score, nodePosition: CGPoint(x: size.width / 2, y: size.height / 2 + 50))
//        addChild(scoreNode)
//    }
//    
//    func reset() {
//        guard let context else { return }
//        
//        removeAllChildren()
//        removeAllActions()
//
//        context.resetGameContext()
//        
//        prepareStartNodes(screenSize: size)
//        scoreNode.updateScore(with: 0)
//        trackerNode.resetDisplay()
//
//        player?.position = rightWallPlayerPos
//        player?.physicsBody?.velocity = .zero
//
//        let spawnAction = SKAction.run { [weak self] in self?.spawnRandomObstacle() }
//        let delay = SKAction.wait(forDuration: 2.0)
//        let spawnSequence = SKAction.sequence([spawnAction, delay])
//        run(SKAction.repeatForever(spawnSequence), withKey: "spawnObstacles")
//
//        context.stateMachine?.enter(NJRunningState.self)
//    }
//}
