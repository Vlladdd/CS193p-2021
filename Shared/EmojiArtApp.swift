//
//  EmojiArtApp.swift
//  Shared
//
//  Created by Vlad Nechiporenko on 06.02.2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: EmojiArtDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
