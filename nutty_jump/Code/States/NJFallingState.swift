//
//  NJFallingState.swift
//  nutty_jump
//
//  Created by matt on 10/29/24.
//

import GameplayKit
import CoreHaptics
import AVFoundation
import AudioToolbox

class NJFallingState: GKState {
    weak var scene: NJGameScene?
    weak var context: NJGameContext?
    private var audioPlayer: AVAudioPlayer?
    
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
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        playSquirrelDeath()
        scene.animatePlayerBasedOnState()
        scene.checkAndDespawnFox()
        
        let targetPos = CGPoint(x: scene.size.width / 2, y: player.position.y - 50.0)
        
        let moveAction = SKAction.move(to: targetPos, duration: 0.2)
        let rotateAction = SKAction.rotate(byAngle: 90.0, duration: 7.0)
        player.toggleGravity()
        
        player.run(SKAction.sequence([moveAction]))
        player.run(SKAction.sequence([rotateAction]))
        
        scene.removeAction(forKey: "speedIncreaseAction")
        scene.removeAction(forKey: "spawnObstacles")
        scene.removeAction(forKey: "spawnBranches")
        scene.removeAction(forKey: "spawnObstacles2")
        scene.removeAction(forKey: "spawnObstacles3")
        scene.removeAction(forKey: "spawnNuts")
        scene.removeAction(forKey: "moveFoxBranch")
        
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
    
    private func playSquirrelDeath() {
        guard let scene else { return }
        scene.run(SKAction.playSoundFileNamed("NJSquirrelDeath.m4a", waitForCompletion: false))
    }
}
