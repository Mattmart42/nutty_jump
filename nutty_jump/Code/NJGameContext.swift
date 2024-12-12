//
//  Untitled.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import Combine
import GameplayKit

class NJGameContext: GameContext {
    var gameScene: NJGameScene? {
        scene as? NJGameScene
    }
    let gameMode: GameModeType
    var gameInfo: NJGameInfo
    var layoutInfo: NJLayoutInfo = .init(screenSize: .zero)
    
    private(set) var stateMachine: GKStateMachine?
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameInfo = NJGameInfo(screenSize: UIScreen.main.bounds.size)
        self.gameMode = gameMode
        super.init(dependencies: dependencies)
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
            NJHawkState(scene: gameScene, context: self)
            ]
        )
    }
    
    func resetGameContext() {
        gameInfo = NJGameInfo(screenSize: UIScreen.main.bounds.size)
        layoutInfo = NJLayoutInfo(screenSize: layoutInfo.screenSize)
    }
}

