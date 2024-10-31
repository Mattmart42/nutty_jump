//
//  NJLayoutInfo.swift
//  nutty_jump
//
//  Created by matt on 10/22/24.
//

import Foundation

struct NJLayoutInfo {
    let screenSize: CGSize
    //iPhone 16: 852 x 393
    // 10/213 = x/100
    //iPhone 16 Pro:
    //iPhone SE:
    
    let wallSizeFactor = 40.0 / 393.0
    let boxSize: CGSize = .init(width: 40, height: 40)
}
