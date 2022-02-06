//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Vlad Nechyporenko on 30.01.2022.
//

import SwiftUI

struct Palette: Identifiable, Codable, Hashable{
    
    var name: String
    var emojis: String
    var id: Int
    
    
    fileprivate init(name: String, emojis: String, id: Int){
        self.name = name
        self.emojis = emojis
        self.id = id
    }
    
    
}


class PaletteStore: ObservableObject {
    
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            save()
        }
    }
    
    init(named name: String){
        self.name = name
        load()
        if palettes.count == 0 {
            insertPalette(named: "faces", emojis: "😀😃😄😁😆😅😂🤣🥲☺️")
            insertPalette(named: "weather", emojis: "☀️🌤⛅️🌥☁️🌦🌧⛈🌩🌨")
            insertPalette(named: "vehicles", emojis: "🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐")
            print("using built-in palettes: \(palettes)")
        }
        else {
            print("succesfully load palettes: \(palettes)")
        }
    }
    
    private var userDefaultsKey: String {
        "PaletteStore:" + name
    }
    
    private func save() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey), let savedPalettes = try? JSONDecoder().decode([Palette].self, from: data){
            palettes = savedPalettes
        }
    }
    
    
    // MARK: - Intents
    
    
    func getPaletteByIndex(_ index: Int) -> Palette {
        let safeIndex = min(max(index,0),palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePaletteAtIndex(_ index: Int) -> Int {
        if palettes.count > 1 && palettes.indices.contains(index){
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    
    func insertPalette(named name: String, emojis: String?, at index: Int = 0) {
        
        let id = (palettes.max(by: {$0.id < $1.id})?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: id)
        let safeIndex = max(max(index,0),palettes.count - 1)
        palettes.insert(palette, at: safeIndex)
        
    }
    
    
    
}
