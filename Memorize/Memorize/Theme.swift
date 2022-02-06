//
//  Theme.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 12.01.2022.
//

import Foundation

//struct that represent theme in a model
struct Theme: Codable,Identifiable, Equatable {
    var id: Int
    var name: String
    var emojis: [String]
    var removedEmoji = [String]()
    //identifiable emojis needed to use emojis in ForEaches in Views
    var removedEmojiIdentifiable: [IdentifiableEmoji] {
        var result = [IdentifiableEmoji]()
        var id = 0
        for emoji in removedEmoji {
            result.append(IdentifiableEmoji(id: id, emoji: emoji))
            id += 1
        }
        return result
    }
    var identiableEmojis: [IdentifiableEmoji] {
        var result = [IdentifiableEmoji]()
        var id = 0
        for emoji in emojis {
            result.append(IdentifiableEmoji(id: id, emoji: emoji))
            id += 1
        }
        return result
    }
    var numberOfPairs: Int
    var color: [RGBAColor]
    var currentEmojis: [String] {
        if numberOfPairs/2 == self.emojis.count {
            return emojis
        }
        else {
            let shuffledEmojis = emojis.shuffled()
            var newEmojis = [String]()
            for index in 0..<numberOfPairs {
                newEmojis.append(shuffledEmojis[index])
            }
            return newEmojis
        }
    }
    
    init(name: String, emojis: [String], numberOfPairs: Int = 0, color: [RGBAColor], isRandomNumberPairsOfCards: Bool = false, id: Int) {
        self.name = name
        self.emojis = emojis
        if numberOfPairs > emojis.count || numberOfPairs == 0 {
            self.numberOfPairs = emojis.count
        }
        else {
            self.numberOfPairs = numberOfPairs
        }
        if isRandomNumberPairsOfCards {
            self.numberOfPairs = Int.random(in: 1..<emojis.count)
        }
        self.color = color
        self.id = id
    }
}

//struct that represents color in theme
struct RGBAColor: Codable, Equatable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}

//struct that make emoji identifiable
struct IdentifiableEmoji: Identifiable, Codable, Equatable {
    var id: Int
    var emoji: String
}
