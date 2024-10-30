//
//  NJGameScene.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import SpriteKit
import GameplayKit

class NJGameScene: SKScene {
    weak var context: NJGameContext?
    
    var player: NJPlayerNode?
    
    let leftWallPlayerPos: CGPoint
    let rightWallPlayerPos: CGPoint
    
    init(context: NJGameContext, size: CGSize) {
        self.leftWallPlayerPos = CGPoint(x: 40 * 1.5, y: size.height / 2.0)
        self.rightWallPlayerPos = CGPoint(x: size.width - 40 * 1.5, y: size.height / 2.0)
        self.context = context
        super.init(size: size)
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard let context else {
            return
        }
        
        
        
        let wallWidth: CGFloat = 40
        let wallHeight: CGFloat = size.height
        
        let leftWall = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: wallWidth / 2, y: 0))
        let leftWall2 = GreenWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                position: CGPoint(x: wallWidth / 2, y: size.height))
        addChild(leftWall)
        addChild(leftWall2)
        
        let rightWall = NJWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                     position: CGPoint(x: size.width - wallWidth / 2, y: 0))
        let rightWall2 = GreenWallNode(size: CGSize(width: wallWidth, height: wallHeight),
                                position: CGPoint(x: size.width - wallWidth / 2, y: size.height))
        addChild(rightWall)
        addChild(rightWall2)
        
        prepareGameContext()
        prepareStartNodes()
        
        context.stateMachine?.enter(NJGameIdleState.self)
    }
    
    func prepareGameContext() {
        guard let context else {
            return
        }

        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func prepareStartNodes() {
        guard let context else {
            return
        }
        let rightWallPlayerPos = CGPoint(x: size.width - 40 * 1.5,
                             y: size.height / 2.0)
        
        let leftWallPlayerPos = CGPoint(x: 40 * 1.5,
                             y: size.height / 2.0)
        let player = NJPlayerNode(size: context.layoutInfo.boxSize, position: rightWallPlayerPos)
        addChild(player)
        self.player = player
    }
    
    override func update(_ currentTime: TimeInterval) {
        //let's check for
        children
            .compactMap { $0 as? NJWallNode }
            .forEach { wallNode in
                
                wallNode.position.y -= 10
                
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
        
        children
            .compactMap { $0 as? GreenWallNode }
            .forEach { wallNode in
                
                wallNode.position.y -= 10
                
                if wallNode.position.y <= -wallNode.size.height / 2 {
                    wallNode.position.y += wallNode.size.height * 2
                }
            }
            

    }
    
    func togglePlayerLocation(currentPlayerPos: CGPoint) {
        let rightWallPlayerPos = CGPoint(x: size.width - 40 * 1.5,
                             y: size.height / 2.0)
        
        let leftWallPlayerPos = CGPoint(x: 40 * 1.5,
                             y: size.height / 2.0)
        
        if currentPlayerPos == rightWallPlayerPos {
            player?.position = leftWallPlayerPos
        }
        if currentPlayerPos == leftWallPlayerPos {
            player?.position = rightWallPlayerPos
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let stateMachine = context?.stateMachine,
              stateMachine.currentState is NJRunningState else {
            return // Ignore touch if not in running state
        }
        
        // Get the first touch (since we're only handling single taps)
        if let touch = touches.first {
            (stateMachine.currentState as? NJRunningState)?.handleTouch(touch)
        }
    }

}
