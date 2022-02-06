//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 27.09.2021.
//

import SwiftUI

@main
struct MemorizeApp: App {
    @StateObject var themeStore = ThemeViewModel(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            ThemeChoser().environmentObject(themeStore)
        }
    }
}
