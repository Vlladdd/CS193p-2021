//
//  MemoryGame.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 12.01.2022.
//

import Foundation

//game logic
struct MemoryGame<CardContent> where CardContent: Hashable {
    
    private(set) var cards = [Card]()
    
    private(set) var score = 0
    
    struct Card: Identifiable {
        let id: Int
        var isFaceUp = false
        var isMatched = false
        let content: CardContent
        var haveSeen = false
        //used to give points or take points depending on when you first time saw the card
        var pickedAtTime: Date?
    }
    
    private var indexOfFirstPickedCard: Int? {
        get {
            cards.indices.filter({cards[$0].isFaceUp}).oneAndOnlyElement
        }
        set {
            cards.indices.forEach{cards[$0].isFaceUp = ($0 == newValue)}
        }
    }
    
    //func that lets user play the game
    mutating func choose(_ card: Card) {
        if let currentCardIndex = cards.firstIndex(where: {$0.id == card.id}),
            !cards[currentCardIndex].isFaceUp,
            !cards[currentCardIndex].isMatched
        {
            if cards[currentCardIndex].pickedAtTime == nil {
                cards[currentCardIndex].pickedAtTime = Date()
            }
            if let firstCardIndex = indexOfFirstPickedCard, let currentCardPickedAtTime = cards[currentCardIndex].pickedAtTime {
                let extraPoints = Int(max(10 - (Date().timeIntervalSince(currentCardPickedAtTime)),1))
                if cards[currentCardIndex].content == cards[firstCardIndex].content {
                    cards[currentCardIndex].isMatched = true
                    cards[firstCardIndex].isMatched = true
                    score += 2 * extraPoints
                }
                else {
                    if cards[currentCardIndex].haveSeen {
                        score -= 1 * extraPoints
                    }
                    if cards[firstCardIndex].haveSeen {
                        score -= 1
                    }
                    cards[currentCardIndex].haveSeen = true
                    cards[firstCardIndex].haveSeen = true
                }
            }
            else {
                indexOfFirstPickedCard = currentCardIndex
            }
            cards[currentCardIndex].isFaceUp = true
        }
    }
    
    init(pairsOfCards: Int, content: [CardContent]){
        for id in 0..<pairsOfCards {
            cards.append(Card(id: id * 2, content: content[id]))
            cards.append(Card(id: id * 2 + 1, content: content[id]))
        }
        cards.shuffle()
    }
    
}

//simple extension to array
extension Array {
    var oneAndOnlyElement: Element? {
        if count == 1 {
            return self[0]
        }
        else {
            return nil
        }
    }
}
