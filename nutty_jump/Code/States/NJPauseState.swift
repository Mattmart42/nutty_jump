//
//  NJPauseState.swift
//  nutty_jump
//
//  Created by Matthew Martinez on 12/17/24.
//

import GameplayKit

class NJPauseState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJRunningState.self || stateClass == NJGameOverState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let scene, let context else { return }
        scene.isPaused = true
        scene.enumerateChildNodes(withName: "//") { node, _ in
            node.isPaused = true
        }
        context.isPaused = true
        scene.pauseNode.isHidden.toggle()
        scene.playNode.isHidden.toggle()
        scene.quitNode.isHidden.toggle()
    }
    
    override func willExit(to nextState: GKState) {
        guard let scene, let context else { return }
        scene.isPaused = false
        scene.enumerateChildNodes(withName: "//") { node, _ in
            node.isPaused = false
        }
        context.isPaused = false
        scene.pauseNode.isHidden.toggle()
        scene.playNode.isHidden.toggle()
        scene.quitNode.isHidden.toggle()
    }
    
    

}
