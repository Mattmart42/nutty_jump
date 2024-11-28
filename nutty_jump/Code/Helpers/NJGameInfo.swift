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
    
    var gameSpeed: CGFloat = 0.5
    
    
    var scrollSpeed: CGFloat { return 10.0 * gameSpeed }
    var backgroundScrollSpeed: CGFloat { return 2.0 * gameSpeed }
    var obstacleSpawnRate: CGFloat { return 2.0 }
    
    var fruitSpeed: CGFloat { return 900.0 * gameSpeed }
    var hawkSpeed: CGFloat { return 500.0 * gameSpeed }
    var foxSpeed: CGFloat { return 500.0 * gameSpeed }
    var nutSpeed: CGFloat { return 900.0 * gameSpeed }
    var bombSpeed: CGFloat { return 900.0 * gameSpeed }
    
    var fruitShootSpeed: CGFloat { return 1000.0 }
    var fruitShootDuration: CGFloat { return 5.0 }
    var fruitShootInterval: CGFloat { return 0.1 }
    
    var fruitsCollected = 0
    var hawksCollected = 0
    var foxesCollected = 0
    var nutsCollected = 0
    
    let wallWidth = 40.0
    let obstacleXPos = 50.0
    let playerSize = CGSize(width: 20.0, height: 61.735)
    let playerFlightSize = CGSize(width: 51.555, height: 40.0)
    
    let obstacleSize = CGSize(width: 30.0, height: 30.0)
    static let fruitSize = CGSize(width: 30.0, height: 30.0)
    static let foxSize = CGSize(width: 61.58, height: 40.0)
    static let hawkSize = CGSize(width: 40.0, height: 57.59)
    static let nutSize = CGSize(width: 30.0, height: 30.0)
    let trackerSize = CGSize(width: 30.0, height: 30.0)
    let branchHeight = 40.0
    let groundHeight = 10.0
    let backgroundHeight = 2500.0
    
    var playerIsInvincible = false
    var playerIsProtected = false
    
    let hawkPULength = 10.0
    
    let bgZPos: CGFloat = 0
    let branchZPos: CGFloat = 1
    let wallZPos: CGFloat = 2
    let playerZPos: CGFloat = 3
    let obstacleZPos: CGFloat = 4
    let hudZPos: CGFloat = 10
}

enum CollectibleType {
    case fruit
    case hawk
    case fox
    case nut
    
    var texture: SKTexture {
        switch self {
        case .fruit: return SKTexture(imageNamed: "blueberry")
        case .hawk: return SKTexture(imageNamed: "hawkRight")
        case .fox: return SKTexture(imageNamed: "foxRight1")
        case .nut: return SKTexture(imageNamed: "nut")
        }
    }
    
    var size: CGSize {
        switch self {
        case .fruit: return NJGameInfo.fruitSize
        case .hawk: return NJGameInfo.hawkSize
        case .fox: return NJGameInfo.foxSize
        case .nut: return NJGameInfo.nutSize
        }
    }
}
