//
//  ThemeViewModel.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 02.02.2022.
//

import SwiftUI

//class that represents ViewModel of Theme and storage of themes
class ThemeViewModel: ObservableObject {
    
    private var name: String
    
    
    @Published var themes: [Theme] = [Theme]() {
        didSet {
            autosave()
        }
    }
    
    private var userDefaultsName: String {
        "ThemeModel" + name
    }
    
    private func autosave() {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(themes), forKey: userDefaultsName)
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsName), let decodedData = try? JSONDecoder().decode([Theme].self, from: data){
            themes = decodedData
        }
    }
    
    init(named name: String){
        self.name = name
        load()
        if themes.count == 0 {
            print("using build-in themes")
            createThemes()
        }
        else {
            print("succesfully load themes from UserDefaults: \(themes)")
        }
    }
    
    private func createThemes(){
        addTheme(name: "vehichles", emojis: ["🚘","✈️","🏎","🛵","🚒","🛩","🚉","🛳","🚇","🚕","🛥","🚗","🚁","🚀","🚃","🚟","🚎","🛻","🚋","🏍","🚜","🚑","🚓","🛺"], color: [RGBAColor(red: 255, green: 0, blue: 0, alpha: 1),RGBAColor(red: 0, green: 255, blue: 0, alpha: 1)], isRandomNumberPairsOfCards: true)
        addTheme(name: "animals", emojis: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐽","🐸","🐵","🐔","🐧","🦆","🐺","🦇"], numberOfPairs: 10, color: [RGBAColor(red: 0, green: 0, blue: 255, alpha: 1)])
        addTheme(name: "flags", emojis: ["🇰🇿","🇷🇺","🇲🇹","🇹🇨","🇩🇪","🇸🇧","🇺🇦","🇳🇺","🇦🇲","🇨🇱","🇦🇺","🇵🇸","🇬🇵","🇸🇨","🇹🇷","🇦🇼","🇲🇰","🇵🇦","🇸🇮","🇰🇷","🇨🇻","🇦🇹"], numberOfPairs: 6, color: [RGBAColor(red: 255, green: 255, blue: 0, alpha: 1)])
        addTheme(name: "currency", emojis: ["$","€","¥","¢","£","₽","₨","₩","฿","₺","₮","₱","₭","₴","₦","৲","৳","૱","௹","﷼","₹","₲","₪","₡"], numberOfPairs: 11, color: [RGBAColor(red: 0, green: 255, blue: 0, alpha: 1)])
        addTheme(name: "chess", emojis: ["♚","♛","♜","♝","♞","♟","♔","♕","♖","♗","♘","♙"], numberOfPairs: 5, color: [RGBAColor(red: 255, green: 100, blue: 0, alpha: 1)])
        addTheme(name: "food", emojis: ["🍏","🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🫐","🍈","🍒","🍑","🥭","🍍","🥥","🥝","🍅","🍆","🥑","🥦","🥬","🥒","🌶"], numberOfPairs: 24, color: [RGBAColor(red: 154, green: 0, blue: 255, alpha: 1)])
    }
    
    //MARK: - Intents
    
    func addTheme(name: String, emojis: [String], numberOfPairs: Int = 0, color: [RGBAColor], isRandomNumberPairsOfCards: Bool = false) {
        let id = (themes.max(by: {$0.id < $1.id})?.id ?? 0) + 1
        themes.append(Theme(name: name, emojis: emojis, numberOfPairs: numberOfPairs, color: color, isRandomNumberPairsOfCards: isRandomNumberPairsOfCards, id: id))
    }
    
    func removeTheme(at index: Int){
        if themes.count > 1 && themes.indices.contains(index){
            themes.remove(at: index)
        }
    }
    
    func findThemeIndexOf(theme: Theme) -> Int?{
        if let index = themes.firstIndex(where: {$0.id == theme.id}) {
            return index
        }
        return nil
    }
    
    func getRandomEmojisFromTheme(_ theme: Theme) -> [String]{
        if let theme = themes.first(where: {$0.id == theme.id}) {
            return Array(theme.emojis[0..<theme.emojis.count/4])
        }
        return ["Emojis not found!"]
    }
    
    func getColor(of theme: Theme) -> Color?{
        if let theme = themes.first(where: {$0.id == theme.id}) {
            if theme.color.count == 1 {
                return Color(rgbaColor: theme.color[0])
            }
        }
        return nil
    }
    
    func getGradientColor(of theme: Theme) -> LinearGradient?{
        if let theme = themes.first(where: {$0.id == theme.id}) {
            if theme.color.count == 2 {
                return LinearGradient(colors: [Color(rgbaColor: theme.color[0]),Color(rgbaColor: theme.color[1])], startPoint: UnitPoint.init(x: 0.5, y: 0), endPoint: UnitPoint.init(x: 0.5, y: 0.6))
            }
        }
        return nil
    }
    
}
