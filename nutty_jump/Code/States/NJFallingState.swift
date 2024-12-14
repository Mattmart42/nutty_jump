//
//  NJFallingState.swift
//  nutty_jump
//
//  Created by matt on 10/29/24.
//

import GameplayKit

class NJFallingState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    
    init(scene: NJGameScene, context: NJGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NJGameOverState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let scene, let player = scene.player else { return }
        print("did enter falling state")
        scene.animatePlayerBasedOnState()
        let targetPos = CGPoint(x: scene.size.width / 2, y: player.position.y - 50.0)
        
        let moveAction = SKAction.move(to: targetPos, duration: 0.2)
        let rotateAction = SKAction.rotate(byAngle: 90.0, duration: 7.0)
        player.toggleGravity()
        
        player.run(SKAction.sequence([moveAction]))
        player.run(SKAction.sequence([rotateAction]))
        scene.children
            .compactMap { $0 as? NJWallNode }
            .forEach { wallNode in wallNode.position.y += scene.info.scrollSpeed
                if wallNode.position.y >= wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        scene.children
            .compactMap { $0 as? NJFoxBranchNode }
            .forEach { branch in
                if branch.action(forKey: "moveFoxBranch") != nil {
                    branch.removeAction(forKey: "moveFoxBranch")
                    print("Removed 'moveFoxBranch' action from branch at \(branch.position)")
                } else {
                    print("No 'moveFoxBranch' action found for branch at \(branch.position)")
                }
            }
    }
}
