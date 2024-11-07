//
//  NJPhysicsCategory.swift
//  nutty_jump
//
//  Created by matt on 10/31/24.
//

struct NJPhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let wall: UInt32 = 1 << 1
    static let ground: UInt32 = 1 << 2
    static let fruit: UInt32 = 1 << 3
    static let hawk: UInt32 = 1 << 4
    static let fox: UInt32 = 1 << 5
    static let nut: UInt32 = 1 << 6
}
