//
//  EmojiArtApp.swift
//  Shared
//
//  Created by Vlad Nechyporenko on 06.02.2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) {config in
            EmojiArtDocumentView().environmentObject(config.document).environmentObject(paletteStore)
        }
    }
}
