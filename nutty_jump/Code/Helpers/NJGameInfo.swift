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
    private let baseScreenWidth: CGFloat = 393.0
    private let baseScreenHeight: CGFloat = 852.0

    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    init(screenSize: CGSize) {
        screenWidth = screenSize.width
        screenHeight = screenSize.height
    }
    
    private var widthScale: CGFloat { screenWidth / baseScreenWidth }
    private var heightScale: CGFloat { screenHeight / baseScreenHeight }
    private var uniformScale: CGFloat { min(widthScale, heightScale) }
    
    var score = 0
    
    let fps = 60.0
    
    var gameSpeed: CGFloat = 0.75
    
    
    var scrollSpeed: CGFloat { return 10.0 * gameSpeed }
    var backgroundScrollSpeed: CGFloat { return 0.8 * gameSpeed }
    var obstacleSpawnRate: CGFloat { return 2.0 }
    var nutSpawnRate: CGFloat { return 17.0 }
    
    var fruitSpeed: CGFloat { return 700.0 * gameSpeed }
    var hawkSpeed: CGFloat { return 500.0 * gameSpeed }
    var foxSpeed1: CGFloat { return 840.0 * gameSpeed }
    var foxSpeed2: CGFloat { return 800.0 * gameSpeed }
    var foxStep: CGFloat { return screenHeight / 1.5 }
    var nutSpeed: CGFloat { return 900.0 * gameSpeed }
    var bombSpeed: CGFloat { return 900.0 * gameSpeed }
    var jumpDuration: CGFloat { return 0.3 - gameSpeed / 15 }
    
    var fruitShootSpeed: CGFloat { return 1000.0 }
    var fruitShootDuration: CGFloat { return 5.0 }
    var fruitShootInterval: CGFloat { return 0.1 }
    
    var foxDisguiseDuration = 10.0
    
    var fruitsCollected = 0
    var hawksCollected = 0
    var foxesCollected = 0
    var nutsCollected = 0
    
    let wallWidth = 40.0
    var obstacleXPos: CGFloat { return (screenWidth * (50/852)) }
    let fruitXPos = 65.0
    let nutXPos = 60.0
    var playerXPosLeft: CGFloat { return (screenWidth * (125/852)) }
    var playerXPosRight: CGFloat { return screenWidth - (screenWidth * (125/852)) }
    var playerYPos: CGFloat { return screenHeight / 2.0 - (screenHeight * (100/852)) }
    
    var fruitSize: CGSize { CGSize(width: 40.0 * uniformScale, height: 50.0 * uniformScale) }
    var foxSize: CGSize { CGSize(width: 76.98 * uniformScale, height: 50.0 * uniformScale) }
    var hawkSize: CGSize { CGSize(width: 50.0 * uniformScale, height: 71.99 * uniformScale) }
    var nutSize: CGSize { CGSize(width: 40.0 * uniformScale, height: 40.0 * uniformScale) }
    var obstacleSize: CGSize { CGSize(width: 30.0 * uniformScale, height: 30.0 * uniformScale) }
    
    let trackerSize = CGSize(width: 30.0, height: 30.0)
    let equationSize = CGSize(width: 166.0, height: 18.0)
    var equationPos: CGPoint { CGPoint(x: 180, y: 40.0) }
    var resultPos: CGPoint { CGPoint(x: 300, y: 0.0) }
    
    var powerUpTextPos: CGPoint { CGPoint(x: screenWidth * (0/852), y: screenWidth * (0/852)) }
    
    var fruitTrackerSize: CGSize { CGSize(width: 30.0 * uniformScale, height: 37.19 * uniformScale) }
    var foxTrackerSize: CGSize { CGSize(width: 48.48 * uniformScale, height: 30.0 * uniformScale) }
    var hawkTrackerSize: CGSize { CGSize(width: 40.0 * uniformScale, height: 57.59 * uniformScale) }
    
    var fruitResultSize: CGSize { CGSize(width: 30.0 * uniformScale, height: 30.0 * uniformScale) }
    var foxResultSize: CGSize { CGSize(width: 52.0 * uniformScale, height: 25.0 * uniformScale) }
    var hawkResultSize: CGSize { CGSize(width: 45.73 * uniformScale, height: 40.0 * uniformScale) }
    
    let branchHeight = 40.0
    let branchSize = CGSize(width: 150.0, height: 40.0)
    let groundHeight = 10.0
    let backgroundHeight = 2500.0
    
    var playerIsInvincible = false
    var playerIsProtected = false
    var playerIsDisguised = false
    var isFruitShoot = false
    var isPoweredUp = false
    
    let hawkPULength = 5.0
    
    let bgZPos: CGFloat = 0
    let branchZPos: CGFloat = 1
    let wallZPos: CGFloat = 2
    let playerZPos: CGFloat = 3
    let obstacleZPos: CGFloat = 4
    let hudZPos: CGFloat = 10
    let titleZPos: CGFloat = 11
    
    let playerSize = CGSize(width: 80.0, height: 80.0)
    let playerFlightSize = CGSize(width: 85.0, height: 85.0)
    let hawkModeSize = CGSize(width: 93.62, height: 65.0)
    
    let runR = SKTexture(imageNamed: "squirrelRunRight")
    let runL = SKTexture(imageNamed: "squirrelRunLeft")
    let flyR = SKTexture(imageNamed: "squirrelFlyRight")
    let flyL = SKTexture(imageNamed: "squirrelFlyLeft")

    let runRProt = SKTexture(imageNamed: "squirrelRunRightProtected")
    let runLProt = SKTexture(imageNamed: "squirrelRunLeftProtected")
    let flyRProt = SKTexture(imageNamed: "squirrelFlyRightProtected")
    let flyLProt = SKTexture(imageNamed: "squirrelFlyLeftProtected")
    
    let runRDisg = SKTexture(imageNamed: "squirrelRunRightDisg")
    let runLDisg = SKTexture(imageNamed: "squirrelRunLeftDisg")
    let flyRDisg = SKTexture(imageNamed: "squirrelFlyRightDisg")
    let flyLDisg = SKTexture(imageNamed: "squirrelFlyLeftDisg")

    let runRProtDisg = SKTexture(imageNamed: "squirrelRunRightProtectedDisg")
    let runLProtDisg = SKTexture(imageNamed: "squirrelRunLeftProtectedDisg")
    let flyRProtDisg = SKTexture(imageNamed: "squirrelFlyRightProtectedDisg")
    let flyLProtDisg = SKTexture(imageNamed: "squirrelFlyLeftProtectedDisg")
    
}

enum CollectibleType {
    case fruit
    case hawk
    case fox
    case nut
    case empty
    
    var texture: SKTexture {
        switch self {
        case .fruit: return SKTexture(imageNamed: "pinecone")
        case .hawk: return SKTexture(imageNamed: "hawkRight")
        case .fox: return SKTexture(imageNamed: "foxRight1")
        case .nut: return SKTexture(imageNamed: "nut")
        case .empty: return SKTexture(imageNamed: "powerUpDefault")
        }
    }
    
    var resultTexture: SKTexture {
        switch self {
        case .fruit: return SKTexture(imageNamed: "shootTracker")
        case .hawk: return SKTexture(imageNamed: "wingTracker")
        case .fox: return SKTexture(imageNamed: "disguiseTracker")
        case .nut: return SKTexture(imageNamed: "nut")
        case .empty: return SKTexture(imageNamed: "powerUpDefault")
        }
    }
    
    func size(for gameInfo: NJGameInfo) -> CGSize {
        switch self {
        case .fruit: return gameInfo.fruitTrackerSize
        case .hawk: return gameInfo.hawkTrackerSize
        case .fox: return gameInfo.foxTrackerSize
        case .nut: return gameInfo.nutSize
        case .empty: return gameInfo.obstacleSize
        }
    }
    
    func resultSize(for gameInfo: NJGameInfo) -> CGSize {
        switch self {
        case .fruit: return gameInfo.fruitResultSize
        case .hawk: return gameInfo.hawkResultSize
        case .fox: return gameInfo.foxResultSize
        case .nut: return gameInfo.nutSize
        case .empty: return gameInfo.obstacleSize
        }
    }
}
