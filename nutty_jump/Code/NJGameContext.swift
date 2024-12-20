//
//  Untitled.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import Combine
import GameplayKit
import AVFAudio

class NJGameContext: GameContext {
    var gameScene: NJGameScene? {
        scene as? NJGameScene
    }
    let gameMode: GameModeType
    var gameInfo: NJGameInfo
    var layoutInfo: NJLayoutInfo = .init(screenSize: .zero)
    var isPaused: Bool = false
    
    private(set) var stateMachine: GKStateMachine?
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameInfo = NJGameInfo(screenSize: UIScreen.main.bounds.size)
        self.gameMode = gameMode
        super.init(dependencies: dependencies)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

    }
    
    func updateLayoutInfo(withScreenSize size: CGSize) {
        layoutInfo = NJLayoutInfo(screenSize: size)
    }
    
    func configureStates() {
        guard let gameScene else { return }
        print("did configure states")
        stateMachine = GKStateMachine(
            states: [
            NJGameIdleState(scene: gameScene, context: self),
            NJRunningState(scene: gameScene, context: self),
            NJJumpingState(scene: gameScene, context: self),
            NJFallingState(scene: gameScene, context: self),
            NJGameOverState(scene: gameScene, context: self),
            NJHawkState(scene: gameScene, context: self),
            ]
        )
    }
    
    func resetGameContext() {
        gameInfo = NJGameInfo(screenSize: UIScreen.main.bounds.size)
        layoutInfo = NJLayoutInfo(screenSize: layoutInfo.screenSize)
    }
    
    @objc func appWillResignActive() {
        pauseGame() // Ensure all nodes/actions are paused.
    }

    @objc func appDidBecomeActive() {
        if scene?.isPaused == true {
            scene?.enumerateChildNodes(withName: "//") { node, _ in
                node.isPaused = true
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func pauseGame() {
        scene?.isPaused = true
        scene?.enumerateChildNodes(withName: "//") { node, _ in
            node.isPaused = true
        }
    }
    
    var audioPlayer: AVAudioPlayer?

    func playMusic() {
        guard let musicSoundURL = Bundle.main.url(forResource: "NJMusic", withExtension: "m4a") else {
            print("Failed to find NJMusic.m4a")
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

}

