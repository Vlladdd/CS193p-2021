//
//  SetGameApp.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 16.01.2022.
//

import SwiftUI

@main
struct SetGameApp: App {
    @StateObject var model = SetGameVIewModel()
    var body: some Scene {
        WindowGroup {
            GameView(model: model)
        }
    }
}
