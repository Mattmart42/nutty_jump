//
//  NJGameIdleState.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import GameplayKit
import AVFoundation

class NJGameIdleState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    private var audioPlayer: AVAudioPlayer?
    
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
        context?.playMusic()
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
        let delayAction = SKAction.wait(forDuration: 2.0)
        let runObstaclesAction = SKAction.run { [weak scene] in
            scene?.runObstacles()
        }
        
        let sequence = SKAction.sequence([delayAction, runObstaclesAction])
        
        scene.run(sequence)
    }
    
    private func playMusic() {
        guard let musicSoundURL = Bundle.main.url(forResource: "NJMusic", withExtension: "m4a") else {
            print("Failed to find Music.mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicSoundURL)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Failed to play music: \(error)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func setupIdleUI() {
        guard let scene else { return }
        
        let titleNode = NJTitleNode(size: scene.info.titleScreenSize, position: scene.info.titleScreenPos, texture: SKTexture(imageNamed: "nj_titleScreen"))
        titleNode.name = "titleNode"
        titleNode.zPosition = scene.info.titleZPos
        scene.addChild(titleNode)
        
        let text = SKLabelNode(text: "tap to start")
        text.name = "startText"
        text.fontColor = .black
        text.fontSize = 20
        text.fontName = "PPNeueMontreal-SemiBolditalic"
        text.position = scene.info.tapStartPos
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
}
