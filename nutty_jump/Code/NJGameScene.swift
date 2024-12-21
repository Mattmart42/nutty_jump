//
//  NJGameScene.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import SpriteKit
import GameplayKit
import CoreHaptics
import AVFoundation
import AudioToolbox

class NJGameScene: SKScene, SKPhysicsContactDelegate {
    weak var context: NJGameContext?
    var info: NJGameInfo
    
    var player: NJPlayerNode?
    let scoreNode = NJScoreNode()
    var trackerNode: NJPowerUpTrackerNode!
    var equationNode: NJEquationNode!
    var backgroundNodes: [NJBackgroundNode] = []
    private var audioPlayer: AVAudioPlayer?
    
    let fruitAtlas = SKTextureAtlas(named: "NJFruitAtlas")
    let backgroundAtlas = SKTextureAtlas(named: "NJBackgroundAtlas")
    let playerAtlas = SKTextureAtlas(named: "NJPlayerAtlas")
    
    let runRAtlas = SKTextureAtlas(named: "NJRunRAtlas")
    let runRFAtlas = SKTextureAtlas(named: "NJRunRFAtlas")
    let runLAtlas = SKTextureAtlas(named: "NJRunLAtlas")
    let runLFAtlas = SKTextureAtlas(named: "NJRunLFAtlas")
    let flyRAtlas = SKTextureAtlas(named: "NJFlyRAtlas")
    let flyRFAtlas = SKTextureAtlas(named: "NJFlyRFAtlas")
    let flyLAtlas = SKTextureAtlas(named: "NJFlyLAtlas")
    let flyLFAtlas = SKTextureAtlas(named: "NJFlyLFAtlas")
    
    let leftWallPlayerPos: CGPoint
    let rightWallPlayerPos: CGPoint
    var currentPlayerXPos: CGFloat
    
    var usedPositions: [String: Set<CGFloat>] = [
        "fruit": [],
        "fox": [],
        "hawk": [],
        "branch": []
    ]
    
    init(context: NJGameContext, size: CGSize, info: NJGameInfo) {
        self.info = NJGameInfo(screenSize: size)
        self.leftWallPlayerPos = CGPoint(x: info.playerXPosLeft, y: info.playerYPos)
        self.rightWallPlayerPos = CGPoint(x: info.playerXPosRight, y: info.playerYPos)
        self.currentPlayerXPos = CGFloat(info.playerXPosRight)
        self.context = context
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
        runRAtlas.preload {}
        runRFAtlas.preload {}
        runLAtlas.preload {}
        runLFAtlas.preload {}
        flyRAtlas.preload {}
        flyRFAtlas.preload {}
        flyLAtlas.preload {}
        flyLFAtlas.preload {}
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard let context else { return }
        print("Screen Size: \(size)")
        prepareGameContext()
        prepareStartNodes(screenSize: size)
        physicsWorld.contactDelegate = self
        context.stateMachine?.enter(NJGameIdleState.self)
    }
    
    func prepareBackgroundNodes() {
        backgroundNodes.forEach { $0.removeFromParent() }
        backgroundNodes.removeAll()
        
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
                if wallNode.position.y <= -info.wallHeight / 2 {
                    wallNode.position.y += info.wallHeight * 2
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
        print("preparing start")
        prepareBackgroundNodes()
        
        scoreNode.removeFromParent()
        scoreNode.setup(screenSize: size, score: info.score, nodePosition: info.scoreNodePos)
        scoreNode.zPosition = info.hudZPos
        addChild(scoreNode)
        
        trackerNode?.removeFromParent()
        trackerNode = NJPowerUpTrackerNode(size: info.trackerSize, defaultCollectible: NJCollectibleType.empty)
        trackerNode.position = CGPoint(x: trackerNode.frame.width / 2, y: 40 + trackerNode.frame.height / 2)
        trackerNode.zPosition = info.hudZPos
        addChild(trackerNode)
        
        equationNode?.removeFromParent()
        equationNode = NJEquationNode(size: info.equationSize, position: info.equationPos, texture: SKTexture(imageNamed: "nj_equation"))
        equationNode.zPosition = info.hudZPos
        addChild(equationNode)
        
        for wall in ["leftWallTop", "leftWallBot", "rightWallTop", "rightWallBot", "ground", "player"] { self.childNode(withName: wall)?.removeFromParent() }
        
        let leftWallTop = NJWallNode(size: CGSize(width: info.wallWidth, height: info.wallHeight),
                                     position: CGPoint(x: info.wallXPosLeft, y: 0), texture: SKTexture(imageNamed: "nj_leftWall"))
        let leftWallBot = NJWallNode(size: CGSize(width: info.wallWidth, height: info.wallHeight),
                                     position: CGPoint(x: info.wallXPosLeft, y: info.wallHeight), texture: SKTexture(imageNamed: "nj_leftWall"))
        leftWallTop.name = "leftWallTop"
        leftWallBot.name = "leftWallBot"
        leftWallTop.zPosition = info.wallZPos
        leftWallBot.zPosition = info.wallZPos
        addChild(leftWallTop)
        addChild(leftWallBot)
        
        let rightWallTop = NJWallNode(size: CGSize(width: info.wallWidth, height: info.wallHeight),
                                     position: CGPoint(x: info.wallXPosRight, y: 0), texture: SKTexture(imageNamed: "nj_rightWall"))
        let rightWallBot = NJWallNode(size: CGSize(width: info.wallWidth, height: info.wallHeight),
                                position: CGPoint(x: info.wallXPosRight, y: info.wallHeight), texture: SKTexture(imageNamed: "nj_rightWall"))
        rightWallTop.name = "rightWallTop"
        rightWallBot.name = "rightWallBot"
        rightWallTop.zPosition = info.wallZPos
        rightWallBot.zPosition = info.wallZPos
        addChild(rightWallTop)
        addChild(rightWallBot)
        
        let ground = NJGroundNode(size: CGSize(width: screenSize.width, height: info.groundHeight), position: CGPoint(x: size.width / 2, y: 0))
        ground.zPosition = info.branchZPos
        ground.name = "ground"
        addChild(ground)
        
        let player = NJPlayerNode(size: info.playerSize, position: rightWallPlayerPos, texture: SKTexture(imageNamed: "nj_runR1"))
        player.zPosition = info.playerZPos
        player.name = "player"
        addChild(player)
        self.player = player
    }
    
    func addTrailToPlayer(player: SKSpriteNode) {
        if let trail = SKEmitterNode(fileNamed: "NJPlayerTrail") {
            trail.name = "playerTrail"
            trail.targetNode = scene
            trail.position = CGPoint(x: 0, y: 0)
            player.addChild(trail)
        }
    }
    
    func handleEnemyHit(enemy: SKNode, at position: CGPoint) {
        if enemy is NJNutNode {
            if let poof = SKEmitterNode(fileNamed: "NJNutCollection") {
                poof.position = position
                addChild(poof)
                print(enemy is NJBombNode)
                
                let stopEmission = SKAction.run { poof.particleBirthRate = 0 }
                let waitBeforeStop = SKAction.wait(forDuration: 0.05)
                let removeEmitter = SKAction.sequence([
                    SKAction.wait(forDuration: TimeInterval(poof.particleLifetime)),
                    SKAction.removeFromParent()
                ])
                
                poof.run(SKAction.sequence([waitBeforeStop, stopEmission]))
                poof.run(removeEmitter)
            }
        } else {
            if let poof = SKEmitterNode(fileNamed: "NJEnemyDeath") {
                poof.position = position
                addChild(poof)
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.75)
                print(enemy is NJBombNode)
                
                let stopEmission = SKAction.run { poof.particleBirthRate = 0 }
                let waitBeforeStop = SKAction.wait(forDuration: 0.05)
                let removeEmitter = SKAction.sequence([
                    SKAction.wait(forDuration: TimeInterval(poof.particleLifetime)),
                    SKAction.removeFromParent()
                ])
                
                poof.run(SKAction.sequence([waitBeforeStop, stopEmission]))
                poof.run(removeEmitter)
            }
        }
        let scale = SKAction.scale(to: 0.0, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([scale, fade])
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([group, remove]))
        enemy.removeFromParent()
    }
    
    func prepareGameContext() {
        guard let context else { return }

        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func displayPowerUpText(type: String) {
        var text = SKLabelNode()
        if type == "fox" {
            text = SKLabelNode(text: "Fox Disguise activated!")
            text.name = "foxPowerUpText"
            text.fontColor = .orange
        } else if type == "hawk" {
            text = SKLabelNode(text: "Soaring Hawk activated!")
            text.name = "hawkPowerUpText"
            text.fontColor = .brown
        } else if type == "fruit" {
            text = SKLabelNode(text: "Fruit Shoot activated!")
            text.name = "fruitPowerUpText"
            text.fontColor = .blue
        }
        text.fontSize = 20
        text.fontName = "PPNeueMontreal-SemiBolditalic"
        text.position = info.powerUpTextPos
        text.zPosition = info.hudZPos
        addChild(text)
        
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let flashing = SKAction.sequence([fadeOut, fadeIn])
        text.run(SKAction.repeatForever(flashing))
    }
    
    func removePowerUpText() {
        childNode(withName: "foxPowerUpText")?.removeFromParent()
        childNode(withName: "hawkPowerUpText")?.removeFromParent()
        childNode(withName: "fruitPowerUpText")?.removeFromParent()
    }
    
    func increaseSpeed() {
        let speedIncreaseAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    guard let self else { return }
                    if info.gameSpeed < 1.62 && info.score <= 7500 {
                        info.gameSpeed += 0.03
                    }
                    if info.gameSpeed < 1.65 && info.score > 7500 {
                        info.gameSpeed += 0.03
                    }
                    if info.gameSpeed < 1.68 && info.score > 10000 {
                        info.gameSpeed += 0.03
                    }
                    if info.gameSpeed < 1.71 && info.score > 12500 {
                        info.gameSpeed += 0.03
                    }
                    if info.gameSpeed < 1.74 && info.score > 15000 {
                        info.gameSpeed += 0.03
                    }
                    if info.gameSpeed < 1.77 && info.score > 17500 {
                        info.gameSpeed += 0.03
                    }
                    if info.gameSpeed < 1.80 && info.score > 20000 {
                        info.gameSpeed += 0.03
                    }
                    if info.gameSpeed < 1.83 && info.score > 22500 {
                        info.gameSpeed += 0.03
                    }
                },
                SKAction.wait(forDuration: 3.0)
            ])
        )
        run(speedIncreaseAction, withKey: "speedIncreaseAction")
    }
    
    func runObstacles() {
        guard let stateMachine = context?.stateMachine else { return }
        
        increaseSpeed()
        
        let spawnAction = SKAction.run {
            if !self.info.isBossSequence {
                self.spawnRandomObstacle()
            }
        }
        let delay = SKAction.wait(forDuration: info.obstacleSpawnRate)
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawnObstacles")
        
        let spawnAction2 = SKAction.run {
            if self.info.score > 3000 && !self.info.isBossSequence {
                self.spawnRandomObstacle()
            }
        }
        let delay2 = SKAction.wait(forDuration: info.obstacleSpawnRate * 2)
        let spawnSequence2 = SKAction.sequence([spawnAction2, delay2])
        run(SKAction.repeatForever(spawnSequence2), withKey: "spawnObstacles2")
        
        let spawnAction3 = SKAction.run {
            if self.info.score > 5000 && !self.info.isBossSequence {
                self.spawnRandomObstacle()
            }
        }
        let delay3 = SKAction.wait(forDuration: info.obstacleSpawnRate * 3)
        let spawnSequence3 = SKAction.sequence([spawnAction3, delay3])
        run(SKAction.repeatForever(spawnSequence3), withKey: "spawnObstacles3")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + info.branchSpawnRate) {
            let spawnBranch = SKAction.run {
                if !(stateMachine.currentState is NJGameOverState) && !(stateMachine.currentState is NJFallingState) && !self.info.isBossSequence {
                    self.spawnRandomBranch()
                }
            }
            let delayBranch = SKAction.wait(forDuration: self.info.branchSpawnRate)
            let branchSequence = SKAction.sequence([spawnBranch, delayBranch])
            self.run(SKAction.repeatForever(branchSequence))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + info.nutSpawnRate) {
            let spawnNutAction = SKAction.run {
                if !(self.info.playerIsProtected) && !(stateMachine.currentState is NJGameOverState) && !(stateMachine.currentState is NJFallingState) {
                    self.spawnNut(obstacleSize: self.info.nutSize, yPos: self.size.height + (self.size.height * (50 / 852)))
                }
            }
            let delayNut = SKAction.wait(forDuration: self.info.nutSpawnRate)
            let spawnNutSequence = SKAction.sequence([spawnNutAction, delayNut])
            self.run(SKAction.repeatForever(spawnNutSequence), withKey: "spawnNuts")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let context else { return }
        
        despawn()
        
        let bossMarks = [5000, 10000, 15000, 20000, 25000]
        if bossMarks.contains(info.score) {
            bossSequence()
        }
        
        if !(context.stateMachine?.currentState is NJGameIdleState) && !(context.stateMachine?.currentState is NJFallingState) && !(context.stateMachine?.currentState is NJGameOverState) && !info.isPaused {
            scrollScreen()
            info.score += 1
            scoreNode.updateScore(with: info.score)
        }
    }

    // MARK: - Spawners
    
    func spawnRandomObstacle() {
        let obstacleYPos = size.height + 50
        let possiblePositions: [CGFloat] = [info.obstacleXPos, size.width - info.obstacleXPos]

        // Select a random obstacle type
        let obstacleTypes = ["fruit", "fox", "hawk"]
        let selectedType = obstacleTypes.randomElement()!

        // Get positions currently in use by this obstacle type
        let usedPositionsForType = usedPositions[selectedType] ?? []

        // Filter available positions
        let availablePositions = possiblePositions.filter { !usedPositionsForType.contains($0) }
        guard let newPosition = availablePositions.randomElement() else {
            print("No available positions for \(selectedType)")
            return
        }

        // Spawn the obstacle
        switch selectedType {
        case "fruit":
            spawnFruit(obstacleSize: info.fruitSize, yPos: obstacleYPos, xPos: newPosition)
        case "fox":
            spawnFox(obstacleSize: info.foxSize, yPos: obstacleYPos, xPos: newPosition)
        case "hawk":
            spawnHawk(obstacleSize: info.hawkSize, yPos: obstacleYPos, xPos: newPosition)
        default:
            break
        }

        // Mark position as used for this type
        usedPositions[selectedType, default: []].insert(newPosition)

        // Schedule removal from `usedPositions` after despawn
        DispatchQueue.main.asyncAfter(deadline: .now() + info.obstacleSpawnRate) {
            self.usedPositions[selectedType]?.remove(newPosition)
        }
    }


    
    func spawnRandomBranch() {
        let obstacleYPos = size.height + 50
        let possiblePositions: [CGFloat] = [info.obstacleXPos, size.width - info.obstacleXPos]
        
        let usedFoxPositions = usedPositions["fox"] ?? []
        let availablePositions = possiblePositions.filter { !usedFoxPositions.contains($0) }
        
        guard let xPos = availablePositions.randomElement() else {
            print("No available positions for branch due to active foxes")
            return
        }
        
        spawnBranch(obstacleSize: info.branchSize, yPos: obstacleYPos, xPos: xPos)
        
        usedPositions["branch", default: []].insert(xPos)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + info.obstacleSpawnRate) {
            self.usedPositions["branch"]?.remove(xPos)
        }
    }

    
//    func spawnMultiplier() {
//        let obstacleYPos = size.height + 50
//        
//        let functions: [() -> Void] = [
//            { self.spawnFruit(obstacleSize: self.info.fruitSize, yPos: obstacleYPos) },
//            { self.spawnHawk(obstacleSize: self.info.hawkSize, yPos: obstacleYPos) },
//            { self.spawnFox(obstacleSize: self.info.foxSize, yPos: obstacleYPos) }
//        ]
//            
//        let randomIndex = Int.random(in: 0..<functions.count)
//        functions[randomIndex]()
//    }
    
    
    func spawnFruit(obstacleSize: CGSize, yPos: CGFloat, xPos: CGFloat) {
        let texture = SKTexture(imageNamed: "nj_pinecone")
        
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
    
    func spawnHawk(obstacleSize: CGSize, yPos: CGFloat, xPos: CGFloat) {
        let isMovingLeftToRight = xPos == info.obstacleXPos
        
        let targetPos = CGPoint(x: isMovingLeftToRight ? size.width - info.obstacleXPos : info.obstacleXPos, y: info.playerYPos)
        let moveAction = SKAction.move(to: targetPos, duration: size.width / info.hawkSpeed)
        
        let circleCenter = CGPoint(x: size.width / 2, y: info.playerYPos)
        let radius = abs(size.width / 2 - info.obstacleXPos)
        let circularPath = CGMutablePath()
        let startAngle: CGFloat = isMovingLeftToRight ? 0 : .pi
        let endAngle: CGFloat = isMovingLeftToRight ? .pi : 0
        circularPath.addArc(center: circleCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: isMovingLeftToRight)
        let circularMotion = SKAction.follow(circularPath, asOffset: false, orientToPath: false, duration: 1.5)
        
        let endTarget = CGPoint(x: xPos == info.obstacleXPos ? -50.0 : size.width + 50.0, y: info.playerYPos + 100.0)
        let endAction = SKAction.move(to: endTarget, duration: 0.2)
        
        let removeAction = SKAction.removeFromParent()
        
        let obstacle = xPos == info.obstacleXPos ? NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "nj_hawkLeft")) : NJHawkNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "nj_hawkRight"))
        
        obstacle.run(SKAction.sequence([moveAction, circularMotion, endAction, removeAction]))
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
    }
    
    func spawnFox(obstacleSize: CGSize, yPos: CGFloat, xPos: CGFloat) {
        spawnFoxBranch(obstacleSize: obstacleSize, yPos: yPos)
        
        let obstacle = NJFoxNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos + info.branchHeight), texture: SKTexture(imageNamed: "nj_fox1"))
        obstacle.name = "FoxNode"
        
        moveFoxDown(obstacle, startPos: CGPoint(x: xPos, y: yPos + info.branchHeight), distance: info.foxStep)
        
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
    }
    
    func despawnFox(obstacle: SKNode) {
        obstacle.removeAction(forKey: "foxMovementWithCompletion")
        
        let xPos: CGFloat = currentPlayerXPos == rightWallPlayerPos.x ? rightWallPlayerPos.x : leftWallPlayerPos.x
        let endTarget = CGPoint(x: xPos == rightWallPlayerPos.x ? size.width + 50.0 : -50.0, y: obstacle.position.y)
        
        let endAction = SKAction.move(to: endTarget, duration: 0.2)
        let removeAction = SKAction.removeFromParent()
        
        obstacle.run(SKAction.sequence([endAction, removeAction]))
    }
    
    func moveFoxDown(_ obstacle: NJFoxNode, startPos: CGPoint, distance: CGFloat) {
        let isMovingRight = startPos.x == info.obstacleXPos
        
        obstacle.xScale = isMovingRight ? 1.0 : -1.0
        
        if obstacle.action(forKey: "foxAnimation") == nil {
            let foxTextures = [
                SKTexture(imageNamed: "nj_fox1"),
                SKTexture(imageNamed: "nj_fox2"),
                SKTexture(imageNamed: "nj_fox3"),
                SKTexture(imageNamed: "nj_fox4"),
                SKTexture(imageNamed: "nj_fox5"),
                SKTexture(imageNamed: "nj_fox6"),
                SKTexture(imageNamed: "nj_fox7")
            ]
            let animationAction = SKAction.animate(with: foxTextures, timePerFrame: info.foxAnimationTime)
            let repeatAnimation = SKAction.repeatForever(animationAction)
            obstacle.run(repeatAnimation, withKey: "foxAnimation")
        }
        
        let targetPos = CGPoint(x: isMovingRight ? size.width - info.obstacleXPos : info.obstacleXPos, y: startPos.y - (distance))
        let moveAction = SKAction.move(to: targetPos, duration: size.width / info.foxSpeed)
        
        obstacle.run(moveAction, withKey: "foxMovement")
        obstacle.run(SKAction.sequence([
            moveAction,
            SKAction.run {
                if targetPos.y > 0 {
                    self.moveFoxDown(obstacle, startPos: targetPos, distance: distance)
                } else {
                    obstacle.removeFromParent()
                }
            }
        ]), withKey: "foxMovementWithCompletion")
    }
    
    func spawnFoxBranch(obstacleSize: CGSize, yPos: CGFloat) {
        let branch = NJFoxBranchNode(size: CGSize(width: size.width, height: info.branchHeight), position: CGPoint(x: size.width / 2, y: yPos), texture: SKTexture(imageNamed: "nj_foxBranch"))
        let branchTargetPos = CGPoint(x: size.width / 2, y: 0)
        let branchDistance = yPos - branchTargetPos.y
        let branchDuration = branchDistance / (info.scrollSpeed * info.fps)
        
        let moveActionBranch = SKAction.move(to: branchTargetPos, duration: branchDuration)
        let removeActionBranch = SKAction.removeFromParent()
        let branchSequence = SKAction.sequence([moveActionBranch, removeActionBranch])
        branch.run(branchSequence, withKey: "moveFoxBranch")
        
        branch.zPosition = info.branchZPos
        addChild(branch)
    }
    
    func spawnBranch(obstacleSize: CGSize, yPos: CGFloat, xPos: CGFloat) {
        let texture: SKTexture = Bool.random() ? SKTexture(imageNamed: "nj_branchRight") : SKTexture(imageNamed: "nj_branchLeft")
        
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
        let xPos: CGFloat = Bool.random() ? info.nutXPos : size.width - info.nutXPos
        
        let obstacle = NJNutNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "nj_nut"))
        let targetPos = CGPoint(x: xPos, y: 0)
        let distance = yPos - targetPos.y
        let duration = distance / (info.scrollSpeed * info.fps)
        
        let moveAction = SKAction.move(to: targetPos, duration: duration)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
        
        obstacle.zPosition = info.obstacleZPos
        addChild(obstacle)
        if let effect = SKEmitterNode(fileNamed: "NJNutParticle") {
            effect.name = "nutEffect"
            effect.targetNode = scene // Ensure particles remain in the scene
            effect.position = CGPoint(x: 0, y: 0) // Position at the bottom
            obstacle.addChild(effect)
        }
    }
    
//    func spawnBomb(obstacleSize: CGSize, yPos: CGFloat) {
//        let xPos: CGFloat = CGFloat.random(in: info.obstacleXPos...(size.width - info.obstacleXPos))
//        
//        let obstacle = NJBombNode(size: obstacleSize, position: CGPoint(x: xPos, y: yPos), texture: SKTexture(imageNamed: "bomb"))
//        let targetPos = CGPoint(x: xPos, y: 0)
//        
//        let moveAction = SKAction.move(to: targetPos, duration: size.height / info.bombSpeed)
//        let removeAction = SKAction.removeFromParent()
//        obstacle.run(SKAction.sequence([moveAction, removeAction]))
//        
//        obstacle.zPosition = info.obstacleZPos
//        addChild(obstacle)
//    }
    
    func togglePlayerLocation() {
//        print("toggling")
//        print("currentPos: \(Int(currentPlayerXPos))")
//        print("rightPos): \(Int(info.playerXPosRight))")
        let isOnRightWall = Int(currentPlayerXPos) == Int(info.playerXPosRight)
        let targetPos = isOnRightWall ? leftWallPlayerPos : rightWallPlayerPos
        currentPlayerXPos = targetPos.x
        
        let moveAction = SKAction.move(to: targetPos, duration: info.jumpDuration)
        moveAction.timingMode = .easeInEaseOut
        player?.run(moveAction)
    }
    
    func animatePlayerBasedOnState() {
        guard let stateMachine = context?.stateMachine,
              let currentState = stateMachine.currentState,
              let player else { return }
        if currentState is NJFallingState {
            player.size = info.playerFlightSize
            player.texture = SKTexture(imageNamed: "nj_flyFall")
            return
        }
        let atlasName: String
        let textures: [SKTexture]
        let size: CGSize
        let isRightWall = currentPlayerXPos == rightWallPlayerPos.x

        switch (info.playerIsDisguised, currentState) {
        case (true, is NJRunningState):
            atlasName = isRightWall ? "NJRunRFAtlas" : "NJRunLFAtlas"
            size = info.playerSize

        case (true, is NJJumpingState):
            atlasName = isRightWall ? "NJFlyLFAtlas" : "NJFlyRFAtlas"
            size = info.playerFlightSize

        case (false, is NJRunningState):
            atlasName = isRightWall ? "NJRunRAtlas" : "NJRunLAtlas"
            size = info.playerSize

        case (false, is NJJumpingState):
            atlasName = isRightWall ? "NJFlyLAtlas" : "NJFlyRAtlas"
            size = info.playerFlightSize

        case (false, is NJHawkState):
            atlasName = "NJHawkModeAtlas"
            size = info.hawkModeSize

        default:
            atlasName = "NJRunRAtlas"
            size = info.playerSize
        }

        let atlas = SKTextureAtlas(named: atlasName)
        textures = atlas.textureNames.sorted().map { atlas.textureNamed($0) }
        player.size = size

        let animationAction = SKAction.animate(with: textures, timePerFrame: info.playerSpeed)
        let repeatAnimation = SKAction.repeatForever(animationAction)
        
        if player.physicsBody == nil {
            player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30))
        }
        
        player.run(repeatAnimation, withKey: "playerAnimation")
    }
    
    // MARK: - User Input
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let stateMachine = context?.stateMachine,
              let currentState = stateMachine.currentState else { return }
        
        if currentState is NJGameIdleState {
            stateMachine.enter(NJRunningState.self)
            
        } else if currentState is NJRunningState {
            stateMachine.enter(NJJumpingState.self)
            togglePlayerLocation()
            
            removeAction(forKey: "returnToRunning")
            
            let delayAction = SKAction.wait(forDuration: info.jumpDuration)
            let switchStateAction = SKAction.run { [weak self] in
                guard let stateMachine = self?.context?.stateMachine else { return }
                if stateMachine.currentState is NJJumpingState {
                    stateMachine.enter(NJRunningState.self)
                }
            }
            let sequence = SKAction.sequence([delayAction, switchStateAction])
            run(sequence, withKey: "returnToRunning")
            
            
        } else if currentState is NJJumpingState {
            print("cannot tap you're jumping")
            
        } else if currentState is NJFallingState {
            print("cannot tap you're falling")
            
        } else if currentState is NJGameOverState {
            if let touch = touches.first {
                let location = touch.location(in: self)
                if let node = atPoint(location) as? NJTitleNode, node.name == "ContinueButton" {
                    continueScreen()
                }
                else if let node = atPoint(location) as? SKLabelNode, node.name == "RestartButton" {
                    reset()
                }
            }
        } else if currentState is NJHawkState {
            print("cannot tap, hawk power-up active")
            
        } else {
            print("unknown state")
        }
    }
    
    // MARK: - Sounds    
    private func playFoxDeath() {
        run(SKAction.playSoundFileNamed("NJFoxDeath.m4a", waitForCompletion: false))
    }
    
    private func playHawkDeath() {
        run(SKAction.playSoundFileNamed("NJHawkDeath.m4a", waitForCompletion: false))
    }
    
    private func playPinecone() {
        run(SKAction.playSoundFileNamed("NJPinecone.m4a", waitForCompletion: false))
    }
    
    private func playAcorn() {
        run(SKAction.playSoundFileNamed("NJAcorn.m4a", waitForCompletion: false))
    }

    private func playFruitShoot() {
        run(SKAction.playSoundFileNamed("NJFruitShoot.m4a", waitForCompletion: false))
    }

    private func playFoxPowerup() {
        run(SKAction.playSoundFileNamed("NJFoxPowerup.mp3", waitForCompletion: false))
    }
    
    private func playOwl() {
        run(SKAction.playSoundFileNamed("NJOwl.mp3", waitForCompletion: false))
    }
    
    private func playSword() {
        run(SKAction.playSoundFileNamed("NJSword.m4a", waitForCompletion: false))
    }

        
    // MARK: - Physics Contacts
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let context else { return }
        guard let stateMachine = context.stateMachine else { return }
        
        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        //player hits ground
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.ground) ||
            (contactA == NJPhysicsCategory.ground && contactB == NJPhysicsCategory.player) {
            print("player hit ground")
            audioPlayer?.stop()
            let playerNode = (contactA == NJPhysicsCategory.player) ? contact.bodyA.node : contact.bodyB.node
            playerNode?.removeFromParent()
            stateMachine.enter(NJGameOverState.self)
            return
        }
        
        //player hits branch
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.branch) ||
            (contactA == NJPhysicsCategory.branch && contactB == NJPhysicsCategory.player) {
            let branchNode = (contactA == NJPhysicsCategory.branch) ? contact.bodyA.node : contact.bodyB.node
            if stateMachine.currentState is NJHawkState {
                branchNode?.removeFromParent()
                return
            }
            if info.playerIsProtected {
                guard let branchNode else { return }
                handleEnemyHit(enemy: branchNode, at: branchNode.position)
                toggleShield(protect: false)
                animatePlayerBasedOnState()
                return
            }
            print("player hit branch")
            branchNode?.removeAction(forKey: "moveBranch")
            stateMachine.enter(NJFallingState.self)
        }
        
        //player hits fruit
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fruit) ||
            (contactA == NJPhysicsCategory.fruit && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !info.isFruitShoot && !info.playerIsInvincible {
                if info.playerIsProtected {
                    toggleShield(protect: false)
                    animatePlayerBasedOnState()
                    return
                }
                print("player hit fruit while running")
                stateMachine.enter(NJFallingState.self)
                
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit fruit while jumping")
                playPinecone()
                let fruitNode = (contactA == NJPhysicsCategory.fruit) ? contact.bodyA.node : contact.bodyB.node
                guard let fruitNode else { return }
                handleEnemyHit(enemy: fruitNode, at: fruitNode.position)
                
                info.hawksCollected = 0
                info.foxesCollected = 0
                
                if !info.isPoweredUp {
                    if info.fruitsCollected == 2 {
                        fruitPowerUp()
                        info.fruitsCollected += 1
                        
                    } else if info.fruitsCollected == 1 {
                        info.fruitsCollected += 1
                        
                    } else if info.fruitsCollected == 0 {
                        trackerNode.resetDisplay()
                        info.fruitsCollected += 1
                    }
                    trackerNode.updatePowerUpDisplay(for: info.fruitsCollected, with: NJCollectibleType.fruit)
                }
            } else if stateMachine.currentState is NJHawkState {
                let fruitNode = (contactA == NJPhysicsCategory.fruit) ? contact.bodyA.node : contact.bodyB.node
                guard let fruitNode else { return }
                handleEnemyHit(enemy: fruitNode, at: fruitNode.position)
            }
        }
        
        //player hits hawk
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.hawk) ||
            (contactA == NJPhysicsCategory.hawk && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !info.playerIsInvincible {
                if info.playerIsProtected {
                    toggleShield(protect: false)
                    animatePlayerBasedOnState()
                    return
                }
                print("player hit hawk while running")
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit hawk while jumping")
                playHawkDeath()
                let hawkNode = (contactA == NJPhysicsCategory.hawk) ? contact.bodyA.node : contact.bodyB.node
                guard let hawkNode else { return }
                handleEnemyHit(enemy: hawkNode, at: hawkNode.position)
                
                info.fruitsCollected = 0
                info.foxesCollected = 0
                
                if !info.isPoweredUp {
                    if info.hawksCollected == 2 {
                        hawkPowerUp()
                        info.hawksCollected += 1
                        
                    } else if info.hawksCollected == 1 {
                        info.hawksCollected += 1
                        
                    } else if info.hawksCollected == 0 {
                        trackerNode.resetDisplay()
                        info.hawksCollected += 1
                    }
                    trackerNode.updatePowerUpDisplay(for: info.hawksCollected, with: NJCollectibleType.hawk)
                }
            } else if stateMachine.currentState is NJHawkState {
                let hawkNode = (contactA == NJPhysicsCategory.hawk) ? contact.bodyA.node : contact.bodyB.node
                guard let hawkNode else { return }
                handleEnemyHit(enemy: hawkNode, at: hawkNode.position)
            }
        }
        
        //player hits fox
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.fox) ||
            (contactA == NJPhysicsCategory.fox && contactB == NJPhysicsCategory.player) {
            if stateMachine.currentState is NJRunningState && !info.playerIsInvincible {
                if info.playerIsProtected {
                    toggleShield(protect: false)
                    animatePlayerBasedOnState()
                    return
                }
                print("player hit fox while running")
                checkAndDespawnFox()
                stateMachine.enter(NJFallingState.self)
            } else if stateMachine.currentState is NJJumpingState {
                print("player hit fox while jumping")
                playFoxDeath()
                let foxNode = (contactA == NJPhysicsCategory.fox) ? contact.bodyA.node : contact.bodyB.node
                guard let foxNode else { return }
                handleEnemyHit(enemy: foxNode, at: foxNode.position)
                
                info.fruitsCollected = 0
                info.hawksCollected = 0
                
                if !info.isPoweredUp {
                    if info.foxesCollected == 2 {
                        foxPowerUp()
                        info.foxesCollected += 1
                        
                    } else if info.foxesCollected == 1 {
                        info.foxesCollected += 1
                        
                    } else if info.foxesCollected == 0 {
                        trackerNode.resetDisplay()
                        info.foxesCollected += 1
                    }
                    trackerNode.updatePowerUpDisplay(for: info.foxesCollected, with: NJCollectibleType.fox)
                }
            } else if stateMachine.currentState is NJHawkState {
                let foxNode = (contactA == NJPhysicsCategory.fox) ? contact.bodyA.node : contact.bodyB.node
                guard let foxNode else { return }
                handleEnemyHit(enemy: foxNode, at: foxNode.position)
            }
        }
        
        //player hits nut
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.nut) ||
            (contactA == NJPhysicsCategory.nut && contactB == NJPhysicsCategory.player) {
            print("player hit nut")
            playAcorn()
            let nutNode = (contactA == NJPhysicsCategory.nut) ? contact.bodyA.node : contact.bodyB.node
            guard let nutNode else { return }
            handleEnemyHit(enemy: nutNode, at: nutNode.position)
            nutNode.removeFromParent()
            info.nutsCollected += 1
            toggleShield(protect: true)
            animatePlayerBasedOnState()
            return
        }
        
        //player hits bomb
        if (contactA == NJPhysicsCategory.player && contactB == NJPhysicsCategory.bomb) ||
            (contactA == NJPhysicsCategory.bomb && contactB == NJPhysicsCategory.player) {
            let bombNode = (contactA == NJPhysicsCategory.bomb) ? contact.bodyA.node : contact.bodyB.node
            guard let bombNode else { return }
            handleEnemyHit(enemy: bombNode, at: bombNode.position)
            if stateMachine.currentState is NJHawkState {
                return
            }
            if info.playerIsProtected {
                toggleShield(protect: false)
                animatePlayerBasedOnState()
                return
            }
            print("player hit bomb")
            stateMachine.enter(NJFallingState.self)
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
        
        //fruit shoot
        if contactA == NJPhysicsCategory.shoot {
            guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
            handleContactBetween(shoot: nodeA, target: nodeB)
        } else if contactB == NJPhysicsCategory.shoot {
            guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
            handleContactBetween(shoot: nodeB, target: nodeA)
        }
    }
    
    func toggleShield(protect: Bool) {
        guard let player else { return }
        info.playerIsProtected = protect
        if protect, let shield = SKEmitterNode(fileNamed: "NJNutParticle") {
            shield.name = "playerShield"
            shield.targetNode = scene // Ensure particles remain in the scene
            shield.position = CGPoint(x: 0, y: 0) // Position at the bottom
            player.addChild(shield)
            let shieldNode = SKSpriteNode(texture: SKTexture(imageNamed: "nj_shield"), size: info.shieldSize)
            shieldNode.name = "playerShieldNode"
            player.addChild(shieldNode)
            return
        }
        player.childNode(withName: "playerShield")?.removeFromParent()
        player.childNode(withName: "playerShieldNode")?.removeFromParent()
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
            
            if let poof = SKEmitterNode(fileNamed: "NJEnemyDeath") {
                poof.position = target.position
                addChild(poof)
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.75)
                
                let stopEmission = SKAction.run { poof.particleBirthRate = 0 }
                let waitBeforeStop = SKAction.wait(forDuration: 0.05)
                let removeEmitter = SKAction.sequence([
                    SKAction.wait(forDuration: TimeInterval(poof.particleLifetime)),
                    SKAction.removeFromParent()
                ])
                
                poof.run(SKAction.sequence([waitBeforeStop, stopEmission]))
                poof.run(removeEmitter)
            }
        }
    }
    
    // MARK: - Powerup Functions
    
    func fruitPowerUp() {
        guard let player else { return }
        info.isPoweredUp = true
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        playFruitShoot()
        
        print("Power-up activated: Shooting fruits!")
        displayPowerUpText(type: "fruit")
        info.isFruitShoot = true
        
        let texture = SKTexture(imageNamed: "nj_pinecone")
        let pinecone = NJFruitNode(size: info.fruitSize, position: CGPoint(x: 0, y: info.fruitSize.height), texture: texture)
        pinecone.name = "pineconeShooter"
        pinecone.zPosition = info.obstacleZPos
        pinecone.physicsBody?.affectedByGravity = false
        pinecone.physicsBody?.isDynamic = false
        pinecone.physicsBody?.categoryBitMask = 0
        player.addChild(pinecone)
        
        let shootAction = SKAction.run { [weak self] in
            self?.shootFruit()
        }

        let waitAction = SKAction.wait(forDuration: info.fruitShootInterval)
        let shootingSequence = SKAction.sequence([shootAction, waitAction])

        let repeatShooting = SKAction.repeatForever(shootingSequence)
        let stopAction = SKAction.run { [weak self] in
            self?.removeAction(forKey: "fruitShooting")
            print("Power-up ended.")
        }

        let powerUpDuration = SKAction.sequence([SKAction.wait(forDuration: info.fruitShootDuration), stopAction])

        run(repeatShooting, withKey: "fruitShooting")
        run(powerUpDuration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + info.fruitShootDuration) {
            self.info.fruitsCollected = 0
            self.trackerNode.resetDisplay()
            self.removePowerUpText()
            player.childNode(withName: "pineconeShooter")?.removeFromParent()
            self.info.isFruitShoot = false
            self.info.isPoweredUp = false
        }
    }
    
    func shootFruit() {
        guard let player else { return }
        
        let fruitTextures = fruitAtlas.textureNames.map { fruitAtlas.textureNamed($0) }
        let randomTexture = fruitTextures.randomElement() ?? fruitTextures[0]
        
        
        let fruit = NJFruitShootNode(size: info.defaultSize, position: CGPoint(x: player.position.x, y: info.playerYPos + info.defaultSize.height + info.fruitSize.height), texture: randomTexture)
        
        let targetPos = CGPoint(x: player.position.x, y: size.height - 10)
        
        let moveAction = SKAction.move(to: targetPos, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        fruit.run(SKAction.sequence([moveAction, removeAction]))
        
        fruit.zPosition = info.obstacleZPos
        addChild(fruit)
        
    }
    
    func hawkPowerUp() {
        guard let stateMachine = context?.stateMachine, let player else { return }
        info.isPoweredUp = true
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        displayPowerUpText(type: "hawk")
        stateMachine.enter(NJHawkState.self)
        
        let pos1 = CGPoint(x: size.width / 2, y: rightWallPlayerPos.y)
        let pos2 = CGPoint(x: info.obstacleXPos, y: rightWallPlayerPos.y + 50)
        let pos3 = CGPoint(x: size.width / 2, y: size.height - 200)
        let pos4 = CGPoint(x: size.width - info.obstacleXPos, y: rightWallPlayerPos.y + 50)
        let pos5 = rightWallPlayerPos
        
        let move1 = SKAction.move(to: pos1, duration: 1.0)
        let move2 = SKAction.move(to: pos2, duration: 1.0)
        let move3 = SKAction.move(to: pos3, duration: 1.0)
        let move4 = SKAction.move(to: pos4, duration: 1.0)
        let move5 = SKAction.move(to: pos5, duration: 1.0)
        
        player.run(SKAction.sequence([move1, move2, move3, move4, move5]))
        DispatchQueue.main.asyncAfter(deadline: .now() + info.hawkPULength) {
            self.info.hawksCollected = 0
            self.trackerNode.resetDisplay()
            self.removePowerUpText()
            self.info.isPoweredUp = false
            self.currentPlayerXPos = self.info.playerXPosRight
            stateMachine.enter(NJRunningState.self)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + info.hawkPULength + 2.0) {
            self.info.playerIsInvincible = false
        }
    }
    
    func foxPowerUp() {
        displayPowerUpText(type: "fox")
        info.isPoweredUp = true
        info.playerIsInvincible = true
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        playFoxPowerup()
        info.playerIsDisguised = true
        DispatchQueue.main.asyncAfter(deadline: .now() + info.foxDisguiseDuration) {
            self.info.playerIsDisguised = false
            self.info.foxesCollected = 0
            self.trackerNode.resetDisplay()
            self.animatePlayerBasedOnState()
            self.removePowerUpText()
            self.info.isPoweredUp = false
            self.info.playerIsInvincible = false
        }
    }
    
    func bossSequence() {
        info.isBossSequence = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.spawnOwl()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            self.getFeather()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
            self.getFeather()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.getFeather()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
            self.getFeather()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) {
            self.getFeather()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.despawnOwl()
            self.info.isBossSequence = false
        }
    }
    
    func getFeather() {
        guard let stateMachine = context?.stateMachine else { return }
        let target1 = CGPoint(x: -150.0, y: 0)
        let target2 = CGPoint(x: size.width * 0.25, y: 0)
        let target3 = CGPoint(x: size.width * 0.5, y: 0)
        let target4 = CGPoint(x: size.width * 0.75, y: 0)
        let target5 = CGPoint(x: size.width + 150.0, y: 0)
        let targets = [target1, target2, target3, target4, target5]
        
        let randomNumber = Int.random(in: 0...4)
        var texture = "nj_feather2"
        if randomNumber < 2 { texture = "nj_feather1" }
        else if randomNumber > 3 { texture = "nj_feather3" }
        if !(stateMachine.currentState is NJGameOverState) {
            self.owlShoot(target: targets[randomNumber], texture: texture)
        }
    }
    
    func spawnOwl() {
        let owl = NJOwlNode(size: info.owlSize, position: info.owlPos1, texture: SKTexture(imageNamed: "nj_owl"))
        owl.name = "owl"
        
        let moveAction = SKAction.move(to: info.owlPos2, duration: 1.0)
        
        owl.run(moveAction)
        owl.zPosition = info.obstacleZPos
        addChild(owl)
        playOwl()
    }
    
    func despawnOwl() {
        guard let owl = childNode(withName: "owl") else { return }
        
        let targetPos = CGPoint(x: size.width / 2, y: size.height + 50)
        let moveAction = SKAction.move(to: targetPos, duration: 1.0)
        
        let removeAction = SKAction.removeFromParent()
        
        owl.run(SKAction.sequence([moveAction, removeAction]), withKey: "despawnOwl")
    }
    
    func owlShoot(target: CGPoint, texture: String) {
        let feather = NJBombNode(size: info.featherSize, position: info.featherPos, texture: SKTexture(imageNamed: texture))
        feather.name = "feather"
        let moveAction = SKAction.move(to: target, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        
        //let rotateAction = SKAction.rotate(byAngle: 90.0, duration: 10.0)
        
        feather.run(SKAction.sequence([moveAction, removeAction]), withKey: "shootFeather")
        //feather.run(SKAction.sequence([rotateAction]))
        
        feather.zPosition = info.obstacleZPos
        addChild(feather)
        playSword()
    }
    
    // MARK: - Other
    
    func displayScore() {
        scoreNode.removeFromParent()
        scoreNode.setup(screenSize: size, score: info.score, nodePosition: CGPoint(x: size.width / 2, y: size.height / 2 + 50))
        addChild(scoreNode)
    }
    
    func continueScreen() {
        self.removeAllChildren()
        self.removeAllActions()

        let titleNode = NJTitleNode(size: info.gameOverSize, position: CGPoint(x: size.width / 2, y: size.height / 2 + 100), texture: SKTexture(imageNamed: "nj_gameOverWhite"))
        titleNode.name = "gameOver"
        addChild(titleNode)
        
        let restartButton = SKLabelNode(text: "Restart")
        restartButton.name = "RestartButton"
        restartButton.fontName = "PPNeueMontreal-Bold"
        restartButton.fontSize = 36
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        addChild(restartButton)
    }
    
    func checkAndDespawnFox() {
        self.enumerateChildNodes(withName: "FoxNode") { node, _ in
            if let specificNode = node as? NJFoxNode {
                self.despawnFox(obstacle: specificNode)
            }
        }
    }
    
    func despawn() {
        self.enumerateChildNodes(withName: "//*") { node, _ in
            if let specificNode = node as? NJFoxNode {
                if specificNode.position.y < -50 || specificNode.position.x < 0 || specificNode.position.x > self.size.width {
                    specificNode.removeFromParent()
                    print("item despawned")
                }
            }
        }
    }
    
    func reset() {
        guard let context else { return }
        context.stopMusic()
        self.removeAllChildren()
        self.removeAllActions()
        let newScene = NJGameScene(context: context, size: self.size, info: info)
        newScene.scaleMode = self.scaleMode
        let animation = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene, transition: animation)
    }
}
