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
    var scrollSpeed = 10
    var fruitsCollected = 0
    var hawksCollected = 0
    var foxesCollected = 0
    var playerIsInvincible = false
}

enum CollectibleType {
    case fruit
    case hawk
    case fox
    
    var texture: SKTexture {
        switch self {
        case .fruit: return SKTexture(imageNamed: "blueberry")
        case .hawk: return SKTexture(imageNamed: "coconut")
        case .fox: return SKTexture(imageNamed: "orange")
        }
    }
}
