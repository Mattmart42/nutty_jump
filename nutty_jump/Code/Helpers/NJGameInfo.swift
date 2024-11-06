//
//  NJGameInfo.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import Foundation
import UIKit

struct NJGameInfo {
    var score = 0
    var fruitsCollected = 0
    var hawksCollected = 0
}

enum CollectibleType {
    case fruit
    case hawk
    case fox
    
    var color: UIColor {
        switch self {
        case .fruit: return .yellow
        case .hawk: return .brown
        case .fox: return .orange
        }
    }
}
