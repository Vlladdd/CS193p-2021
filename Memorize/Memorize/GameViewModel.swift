//
//  GameViewModel.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 12.01.2022.
//

import SwiftUI

//ViewModel of game logic
class GameViewModel: ObservableObject {
    
    typealias Card = MemoryGame<String>.Card
    
    @Published private var model: MemoryGame<String>
    
    var cards: [Card] {
        model.cards
    }
    
    var score: Int {
        model.score
    }
    
    var randomTheme: Theme {
        didSet {
            newGame()
        }
    }
    
    var nameOfTheme: String {
        randomTheme.name
    }
    
    init(with theme: Theme) {
        randomTheme = theme
        model = MemoryGame<String>(pairsOfCards: randomTheme.numberOfPairs, content: randomTheme.currentEmojis)
    }
    
    // MARK: - Intent
    
    func choose(_ card : Card) {
        model.choose(card)
    }
    
    func newGame() {
        model = MemoryGame<String>(pairsOfCards: randomTheme.numberOfPairs, content: randomTheme.currentEmojis)
    }
}
