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
    var score = 0
    
    let fps = 60.0
    
    var gameSpeed: CGFloat = 0.75
    
    
    var scrollSpeed: CGFloat { return 10.0 * gameSpeed }
    var backgroundScrollSpeed: CGFloat { return 2.0 * gameSpeed }
    var obstacleSpawnRate: CGFloat { return 2.0 }
    
    var fruitSpeed: CGFloat { return 700.0 * gameSpeed }
    var hawkSpeed: CGFloat { return 500.0 * gameSpeed }
    var foxSpeed1: CGFloat { return 700.0 * gameSpeed }
    var foxSpeed2: CGFloat { return 800.0 * gameSpeed }
    var nutSpeed: CGFloat { return 900.0 * gameSpeed }
    var bombSpeed: CGFloat { return 900.0 * gameSpeed }
    
    var fruitShootSpeed: CGFloat { return 1000.0 }
    var fruitShootDuration: CGFloat { return 5.0 }
    var fruitShootInterval: CGFloat { return 0.1 }
    
    var foxDisguiseDuration = 10.0
    
    var fruitsCollected = 0
    var hawksCollected = 0
    var foxesCollected = 0
    var nutsCollected = 0
    
    let wallWidth = 40.0
    let obstacleXPos = 50.0
    
    static let obstacleSize = CGSize(width: 30.0, height: 30.0)
    static let fruitSize = CGSize(width: 40.0, height: 50.0)
    static let foxSize = CGSize(width: 76.98, height: 50.0)
    static let hawkSize = CGSize(width: 50.0, height: 71.99)
    static let nutSize = CGSize(width: 40.0, height: 40.0)
    let trackerSize = CGSize(width: 30.0, height: 30.0)
    let branchHeight = 40.0
    let branchSize = CGSize(width: 150.0, height: 40.0)
    let groundHeight = 10.0
    let backgroundHeight = 2500.0
    
    var playerIsInvincible = false
    var playerIsProtected = false
    var playerIsDisguised = false
    var isFruitShoot = false
    
    let hawkPULength = 5.0
    
    let bgZPos: CGFloat = 0
    let branchZPos: CGFloat = 1
    let wallZPos: CGFloat = 2
    let playerZPos: CGFloat = 3
    let obstacleZPos: CGFloat = 4
    let hudZPos: CGFloat = 10
    
    let playerSize = CGSize(width: 20.0, height: 61.03)
    let playerFlightSize = CGSize(width: 51.56, height: 53.0)
    let playerProtSize = CGSize(width: 24.0, height: 72.03)
    let playerProtFlightSize = CGSize(width: 58, height: 60.0)
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
    
    var size: CGSize {
        switch self {
        case .fruit: return NJGameInfo.fruitSize
        case .hawk: return NJGameInfo.hawkSize
        case .fox: return NJGameInfo.foxSize
        case .nut: return NJGameInfo.nutSize
        case .empty: return NJGameInfo.obstacleSize
        }
    }
}
