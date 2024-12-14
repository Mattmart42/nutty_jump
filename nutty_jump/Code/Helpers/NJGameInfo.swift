//
//  NJGameInfo.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import Foundation
import UIKit
import SpriteKit

struct NJGameInfo {
    
    var score: Int = 0
    let fps: CGFloat = 60
    
    //MARK: Scaling
    
    private let baseScreenWidth: CGFloat = 393
    private let baseScreenHeight: CGFloat = 852
    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    init(screenSize: CGSize) {
        screenWidth = screenSize.width
        screenHeight = screenSize.height
    }
    
    private var widthScale: CGFloat { screenWidth / baseScreenWidth }
    private var heightScale: CGFloat { screenHeight / baseScreenHeight }
    private var uniformScale: CGFloat { min(widthScale, heightScale) }
    
    //MARK: Game Speed
    
    var gameSpeed: CGFloat = 0.75
    var scrollSpeed: CGFloat { return 10 * gameSpeed }
    var backgroundScrollSpeed: CGFloat { return 0.8 * gameSpeed }
    var obstacleSpawnRate: CGFloat { return 2 }
    var nutSpawnRate: CGFloat { return 17 }
    var branchSpawnRate: CGFloat { return 29 }
    
    var fruitSpeed: CGFloat { return 700 * gameSpeed }
    var hawkSpeed: CGFloat { return 500 * gameSpeed }
    var foxSpeed: CGFloat { return 840 * gameSpeed }
    var nutSpeed: CGFloat { return 900 * gameSpeed }
    var foxStep: CGFloat { return 568 * heightScale }
    var playerSpeed: CGFloat { return 0.18 - (0.1 * gameSpeed) }
    //var bombSpeed: CGFloat { return 900.0 * gameSpeed }
    
    //MARK: Position & Sizing
    
    var wallWidth: CGFloat { return 40 * widthScale }
    var wallHeight: CGFloat { return baseScreenHeight * heightScale }
    var wallXPosLeft: CGFloat { return wallWidth / 2 }
    var wallXPosRight: CGFloat { return screenWidth - (wallWidth / 2) }
    
    var obstacleXPos: CGFloat { return (50 * widthScale) }
    var fruitXPos: CGFloat { return (65 * widthScale) }
    var nutXPos: CGFloat { return (60 * widthScale) }
    
    var fruitSize: CGSize { CGSize(width: 40 * uniformScale, height: 50 * uniformScale) }
    var foxSize: CGSize { CGSize(width: 76.98 * uniformScale, height: 50 * uniformScale) }
    var hawkSize: CGSize { CGSize(width: 50 * uniformScale, height: 71.99 * uniformScale) }
    var nutSize: CGSize { CGSize(width: 50 * uniformScale, height: 50 * uniformScale) }
    var defaultSize: CGSize { CGSize(width: 30 * uniformScale, height: 30 * uniformScale) }
    var shieldSize: CGSize { CGSize(width: 90 * uniformScale, height: 90 * uniformScale) }
    
    var scoreNodePos: CGPoint { CGPoint(x: screenWidth / 2, y: screenHeight - (80 * heightScale)) }
    var scoreNodeSize: CGSize { CGSize(width: 180 * uniformScale, height: 51 * uniformScale) }
    var branchSize: CGSize { CGSize(width: 150 * uniformScale, height: 40 * uniformScale) }
    var branchHeight: CGFloat { return (40 * heightScale) }
    var groundHeight: CGFloat { return (10 * heightScale) }
    var backgroundHeight: CGFloat { return (2500) }
    
    var gameOverSize: CGSize { CGSize(width: 340 * uniformScale, height: 44 * uniformScale) }
    
    var titleScreenSize: CGSize { CGSize(width: 393 * uniformScale, height: 741 * uniformScale) }
    
    var gameOverScreenSize: CGSize { CGSize(width: 393 * uniformScale, height: 533 * uniformScale) }
    var continueButtonSize: CGSize { CGSize(width: 292 * uniformScale, height: 83 * uniformScale) }
    var gameOverScreenPos: CGPoint { CGPoint(x: screenWidth / 2, y: screenHeight / 2 + 80) }
    var continueButtonPos: CGPoint { CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 300) }
    var tapStartPos: CGPoint { CGPoint(x: screenWidth / 2, y: 110 * heightScale) }
    
    
    //MARK: Power-Up Tracking
    
    var trackerSize: CGSize { CGSize(width: 30 * uniformScale, height: 30 * uniformScale) }
    var equationSize: CGSize { CGSize(width: 166 * uniformScale, height: 18 * uniformScale) }
    
    var equationPos: CGPoint { CGPoint(x: 180 * uniformScale, y: 40 * uniformScale) }
    var node1Pos: CGPoint { CGPoint(x: 70 * uniformScale, y: 5 * uniformScale) }
    var node2Pos: CGPoint { CGPoint(x: 145 * uniformScale, y: 5 * uniformScale) }
    var node3Pos: CGPoint { CGPoint(x: 215 * uniformScale, y: 5 * uniformScale) }
    var resultPos: CGPoint { CGPoint(x: 300 * uniformScale, y: 5 * uniformScale) }
    var powerUpTextPos: CGPoint { CGPoint(x: 160 * heightScale, y: 80 * widthScale) }
    
    var fruitTrackerSize: CGSize { CGSize(width: 34 * uniformScale, height: 34 * uniformScale) }
    var foxTrackerSize: CGSize { CGSize(width: 48.48 * uniformScale, height: 30 * uniformScale) }
    var hawkTrackerSize: CGSize { CGSize(width: 40 * uniformScale, height: 57.59 * uniformScale) }
    
    var fruitResultSize: CGSize { CGSize(width: 30 * uniformScale, height: 30 * uniformScale) }
    var foxResultSize: CGSize { CGSize(width: 52 * uniformScale, height: 52 * uniformScale) }
    var hawkResultSize: CGSize { CGSize(width: 45.73 * uniformScale, height: 40 * uniformScale) }
    
    //MARK: Power-Ups
    
    var fruitsCollected = 0
    var hawksCollected = 0
    var foxesCollected = 0
    var nutsCollected = 0
    
    var playerIsInvincible = false
    var playerIsProtected = false
    var playerIsDisguised = false
    var isFruitShoot = false
    var isPoweredUp = false
    
    var fruitShootSpeed: CGFloat { return 1000 }
    var fruitShootDuration: CGFloat { return 5 }
    var fruitShootInterval: CGFloat { return 0.1 }
    
    let foxDisguiseDuration = 10.0
    
    let hawkPULength = 5.0
    
    //MARK: Z-Positions
    
    let bgZPos: CGFloat = 0
    let branchZPos: CGFloat = 1
    let wallZPos: CGFloat = 2
    let playerZPos: CGFloat = 3
    let obstacleZPos: CGFloat = 4
    let hudZPos: CGFloat = 10
    let titleZPos: CGFloat = 11
    
    //MARK: Player
    
    var jumpDuration: CGFloat { return 0.3 - gameSpeed / 15 }
    
    var playerXPosLeft: CGFloat { return (55 * widthScale) }
    var playerXPosRight: CGFloat { return screenWidth - playerXPosLeft }
    var playerYPos: CGFloat { return screenHeight / 2.0 - (100 * heightScale) }
    
    var playerSize: CGSize { CGSize(width: 80 * uniformScale, height: 80 * uniformScale) }
    var playerFlightSize: CGSize { CGSize(width: 85 * uniformScale, height: 85 * uniformScale) }
    var hawkModeSize: CGSize { CGSize(width: 91 * uniformScale, height: 70 * uniformScale) }
}

enum CollectibleType {
    case fruit
    case hawk
    case fox
    case empty
    
    var texture: SKTexture {
        switch self {
        case .fruit: return SKTexture(imageNamed: "pinecone")
        case .hawk: return SKTexture(imageNamed: "hawkRight")
        case .fox: return SKTexture(imageNamed: "foxRight1")
        case .empty: return SKTexture(imageNamed: "powerUpDefault")
        }
    }
    
    var resultTexture: SKTexture {
        switch self {
        case .fruit: return SKTexture(imageNamed: "shootTracker")
        case .hawk: return SKTexture(imageNamed: "wingTracker")
        case .fox: return SKTexture(imageNamed: "disguiseTracker")
        case .empty: return SKTexture(imageNamed: "powerUpDefault")
        }
    }
    
    func size(for gameInfo: NJGameInfo) -> CGSize {
        switch self {
        case .fruit: return gameInfo.fruitTrackerSize
        case .hawk: return gameInfo.hawkTrackerSize
        case .fox: return gameInfo.foxTrackerSize
        case .empty: return gameInfo.defaultSize
        }
    }
    
    func resultSize(for gameInfo: NJGameInfo) -> CGSize {
        switch self {
        case .fruit: return gameInfo.fruitResultSize
        case .hawk: return gameInfo.hawkResultSize
        case .fox: return gameInfo.foxResultSize
        case .empty: return gameInfo.defaultSize
        }
    }
}
