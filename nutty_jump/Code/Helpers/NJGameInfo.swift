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
    
    static let fps = 60.0
    
    static var scrollSpeed = 10.0
    static var backgroundScrollSpeed = 2.0
    static var fruitSpeed = 10.0
    static var hawkSpeed = 10.0
    static var foxSpeed = 500.0
    
    var fruitsCollected = 0
    var hawksCollected = 0
    var foxesCollected = 0
    var nutsCollected = 0
    
    static let wallWidth = 40.0
    static let obstacleXPos = 60.0
    static let obstacleSize = CGSize(width: 30.0, height: 30.0)
    static let fruitSize = CGSize(width: 30.0, height: 30.0)
    static let foxSize = CGSize(width: 61.58, height: 40.0)
    static let hawkSize = CGSize(width: 40.0, height: 57.59)
    static let nutSize = CGSize(width: 30.0, height: 30.0)
    static let trackerSize = CGSize(width: 30.0, height: 30.0)
    static let branchHeight = 40.0
    static let groundHeight = 10.0
    static let backgroundHeight = 2500.0
    
    var playerIsInvincible = false
    var playerIsProtected = false
    
    let hawkPULength = 10.0
    
    static let bgZPos: CGFloat = 0
    static let branchZPos: CGFloat = 1
    static let wallZPos: CGFloat = 2
    static let playerZPos: CGFloat = 3
    static let obstacleZPos: CGFloat = 4
    static let hudZPos: CGFloat = 10
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
        case .fox: return SKTexture(imageNamed: "fox1")
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
