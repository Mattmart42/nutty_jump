//
//  ContentView.swift
//  nutty_jump
//
//  Created by matt on 10/14/24.
//

import SwiftUI
import SpriteKit

import SwiftUI
import SpriteKit

struct ContentView: View {
    let context = NJGameContext(dependencies: .init(),
                                gameMode: .single)
    let screenSize: CGSize = UIScreen.main.bounds.size
    let info = NJGameInfo(screenSize: UIScreen.main.bounds.size)
    
    var body: some View {
        SpriteView(scene: NJGameScene(context: context,
                                      size: screenSize, info: info))
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea()
}

