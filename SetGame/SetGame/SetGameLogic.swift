//
//  SetGameLogic.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 16.01.2022.
//

import Foundation

//game logic
struct SetGameLogic {
    
    //i have only 1 deck, no discard, game etc
    //i just change place of cards
    //at the start i had some variable for discard, game and deck
    //but it was hard to make a flip animation with that and code was reducanted
    //so i decided to have 1 var for deck and a var that represent place of card
    private(set) var deck: [Card]

    private(set) var player1Score: Int = 0
    private(set) var player2Score: Int = 0
    
    private var startOfTheGame = Date()
    
    struct Card: Identifiable,Hashable {
        var id: Int
        var symbolsCount: Int
        var symbol: String
        var symbolColor: String
        var colorType: String
        var place = Place.deck
        var rotation = Double.random(in: -5...5)
        var cardStatus = CardStatus.faceDown
    }
    
    enum CardStatus {
        //actual set
        case isPartOfSet
        case isSelected
        //when there is 3 cards selected but they are not part of a set
        case isSet
        case isCheat
        case faceDown
        case faceUp
    }
    
    enum Place {
        case deck
        case game
        case discard
    }
    
    enum GameStatus {
        case multiplayer
        case singleplayer
        case none
    }
    
    enum Player {
        case player1
        case player2
        case none
    }
    
    //count of shapes on card
    private var possibleCount = [1,2,3]
    private(set) var currentPlayer = Player.player1
    private(set) var gameStatus = GameStatus.singleplayer
    
    //computed var that represent selected cards and do something when there is a set or nonset
    private var selectedCards: [Card] {
        mutating get{
            let cards = deck.filter({$0.cardStatus != .faceUp && $0.place == .game})
            let setCards = deck.filter({$0.cardStatus == .isPartOfSet && $0.place == .game})
            if cards.count == 3 {
                for card in cards {
                    if let currentCard = deck.firstIndex(where: {$0.id == card.id}){
                        if deck[currentCard].cardStatus != .isPartOfSet{
                            deck[currentCard].cardStatus = .isSet
                        }
                    }
                }
            }
            if cards.count == 4 {
                if setCards.count == 3{
                    for card in setCards {
                        changePlace(of: card, to: .discard)
                    }
                }
            }
            return cards
        }
        set{
            if newValue.count == 1 {
                deck.indices.forEach({if deck[$0].cardStatus != .isPartOfSet && deck[$0].place == .game {deck[$0].cardStatus = newValue[0].id == deck[$0].id ? .isSelected: .faceUp}})
            }
            else {
                for card in newValue {
                    if let currentCard = deck.firstIndex(where: {$0.id == card.id}){
                        deck[currentCard].cardStatus = .isPartOfSet
                    }
                }
            }
        }
    }
    
    private var points: Double {
        max(10,100 - (Date().timeIntervalSince(startOfTheGame)))
    }
    
    //main logic of game
    mutating func choose(card: Card) {
        if (currentPlayer != .none && selectedCards.count < 3  && gameStatus == .multiplayer) || gameStatus == .singleplayer {
            if let currentCard = deck.firstIndex(where: {$0.id == card.id}){
                if selectedCards.count == 3 {
                    for card in selectedCards {
                        if card.id != deck[currentCard].id {
                            if deck[currentCard].cardStatus != .isPartOfSet {
                                deck[currentCard].cardStatus = .isSelected
                            }
                        }
                        else {
                            for card in selectedCards {
                                if card.cardStatus != .isPartOfSet {
                                    deck[currentCard].cardStatus = .faceUp
                                    selectedCards = [deck[currentCard]]
                                }
                            }
                        }
                    }
                }
                else {
                    if deck[currentCard].cardStatus == .isSelected {
                        deck[currentCard].cardStatus = .faceUp
                    }
                    else {
                        deck[currentCard].cardStatus = .isSelected
                    }
                }
                if selectedCards.count == 4 {
                    if let currentCard = deck.firstIndex(where: {$0.id == card.id}){
                        selectedCards = [deck[currentCard]]
                    }
                }
                if selectedCards.count == 3 {
                    let isSet = isSet(card1: selectedCards[0], card2: selectedCards[1], card3: selectedCards[2])
                    if isSet {
                        selectedCards = selectedCards
                        if currentPlayer == .player1 {
                            player1Score += Int(points)
                        }
                        else {
                            player2Score += Int(points)
                        }
                    }
                    else {
                        if currentPlayer == .player1 {
                            player1Score -= Int(points)
                        }
                        else {
                            player2Score -= Int(points)
                        }
                    }
                }
            }
        }
    }
    
    //check if there is a set on the game board
    private mutating func isSetAvailable(player: Player) {
        var isSet = false
        outerLoop: for card1 in deck.filter({$0.place == .game})[0..<deck.filter({$0.place == .game}).count-2] {
            for card2 in deck.filter({$0.place == .game})[1..<deck.filter({$0.place == .game}).count-1] {
                for card3 in deck.filter({$0.place == .game})[2..<deck.filter({$0.place == .game}).count] {
                    isSet = self.isSet(card1: card1, card2: card2, card3: card3)
                    if isSet {
                        break outerLoop
                    }
                }
            }
        }
        if isSet && selectedCards.count != 3{
            if player == .player1 {
                player1Score -= Int(points) * 2
            }
            else {
                player2Score -= Int(points) * 2
            }
        }
    }
    
    //check if 3 cards are a set
    func isSet(card1 : Card, card2: Card, card3: Card) -> Bool {
        var firstRule = false
        var secondRule = false
        var thirdRule = false
        var fourthRule = false
        if ((card1.symbolsCount == card2.symbolsCount) && (card1.symbolsCount == card3.symbolsCount)) || ((card1.symbolsCount != card2.symbolsCount) && (card1.symbolsCount != card3.symbolsCount) && (card2.symbolsCount != card3.symbolsCount)) {
            firstRule = true
        }
        if ((card1.symbol == card2.symbol) && (card1.symbol == card3.symbol)) || ((card1.symbol != card2.symbol) && (card1.symbol != card3.symbol) && (card2.symbol != card3.symbol)) {
            secondRule = true
        }
        if ((card1.colorType == card2.colorType) && (card1.colorType == card3.colorType)) || ((card1.colorType != card2.colorType) && (card1.colorType != card3.colorType) && (card2.colorType != card3.colorType)) {
            thirdRule = true
        }
        if ((card1.symbolColor == card2.symbolColor) && (card1.symbolColor == card3.symbolColor)) || ((card1.symbolColor != card2.symbolColor) && (card1.symbolColor != card3.symbolColor) && (card2.symbolColor != card3.symbolColor)) {
            fourthRule = true
        }
        if firstRule || secondRule || thirdRule || fourthRule {
            return true
        }
        else {
            return false
        }
    }
    
    mutating func addCards(player: Player) {
        if deck.filter({$0.place == .deck}).count > 0 {
            isSetAvailable(player: player)
            let setCards = deck.filter({$0.cardStatus == .isPartOfSet})
            let cardsToGame = deck.filter({$0.place == .deck})
            if setCards.count == 3 {
                var index = 0
                for card in setCards {
                    if let cardIndex = deck.firstIndex(where: {$0.id == card.id}){
                        changePlace(of: cardsToGame[index], to: .game, at: cardIndex)
                        index += 1
                    }
                }
            }
            else {
                for index in 0..<3 {
                    changePlace(of: cardsToGame[index], to: .game)
                }
            }
        }
    }
    
    //by default gameStatus is singleplayer
    init(possibleShapes: [String], possibleColors: [String], possibleColorTypes: [String]) {
        var id = 0
        deck = []
        for shape in possibleShapes {
            for count in possibleCount {
                for color in possibleColors {
                    for colorType in possibleColorTypes {
                        deck.append(Card(id: id, symbolsCount: count, symbol: shape, symbolColor: color, colorType: colorType))
                        id += 1
                    }
                }
            }
        }
        deck.shuffle()
    }
    
    mutating func newGame(gameType: GameStatus = .singleplayer) {
        for card in deck {
            changePlace(of: card, to: .deck)
            if let index = deck.firstIndex(where: {$0.id == card.id}){
                deck[index].rotation = Double.random(in: -5...5)
            }
        }
        deck.shuffle()
        player1Score = 0
        player2Score = 0
        startOfTheGame = Date()
        gameStatus = gameType
        if gameType == .multiplayer {
            currentPlayer = .none
        }
        else {
            currentPlayer = .player1
        }
    }
    
    //find first available set on the game board
    mutating func cheat() {
        var isSet = false
        for index in deck.filter({$0.place == .game}).indices {
            deck[index].cardStatus = .faceUp
        }
    outerLoop: for card1 in deck.filter({$0.place == .game})[0..<deck.filter({$0.place == .game}).count-2] {
        for card2 in deck.filter({$0.place == .game})[1..<deck.filter({$0.place == .game}).count-1] {
            for card3 in deck.filter({$0.place == .game})[2..<deck.filter({$0.place == .game}).count] {
                    isSet = self.isSet(card1: card1, card2: card2, card3: card3)
                    if isSet {
                        let cards = deck.filter({$0.id == card1.id || $0.id == card2.id || $0.id == card3.id})
                        for card in cards {
                            if let cardIndex = deck.firstIndex(where: {$0.id == card.id}) {
                                deck[cardIndex].cardStatus = .isCheat
                            }
                        }
                        break outerLoop
                    }
                }
            }
        }
    }
    
    //for multiplayer
    mutating func switchPlayer(player: Player) {
        currentPlayer = player
    }
    
    //for multiplayer
    mutating func penalty() {
        if currentPlayer == .player1 {
            player1Score -= 100
        }
        else {
            player2Score -= 100
        }
    }
    
    //for multiplayer
    mutating func nextTurn() {
        let setCards = deck.filter({$0.cardStatus == .isPartOfSet})
        if setCards.count == 3{
            for card in setCards {
                changePlace(of: card, to: .discard)
            }
            if deck.count > 0 {
                let cardsToGame = deck.filter({$0.place == .deck})
                for index in 0..<3 {
                    changePlace(of: cardsToGame[index], to: .game)
                }
            }
        }  
    }
    
    //move cards from deck to game, from game to discard, from discard to deck
    //purely made so animations are working perfectly
    mutating func changePlace(of card: Card, to place: Place, at cardsToShowindex: Int = -1){
        if place == .game && cardsToShowindex == -1 {
            if let index = deck.firstIndex(where: {$0.id == card.id}){
                deck[index].place = place
            }
        }
        if place == .deck {
            if let index = deck.firstIndex(where: {$0.id == card.id}){
                deck[index].place = .deck
                deck[index].cardStatus = .faceDown
            }
        }
        if place == .game && cardsToShowindex != -1 {
            if let index = deck.firstIndex(where: {$0.id == card.id}){
                var card = deck[index]
                card.place = place
                deck[cardsToShowindex].rotation = Double.random(in: -5...5)
                deck[cardsToShowindex].place = .discard
                deck[cardsToShowindex].cardStatus = .faceUp
                deck[index] = deck[cardsToShowindex]
                deck[cardsToShowindex] = card
            }
        }
        
        if place == .discard {
            if let index = deck.firstIndex(where: {$0.id == card.id}){
                deck[index].place = .discard
                deck[index].cardStatus = .faceUp
            }
        }
    }
    
    //change status of card(e.g faceup, facedown etc)
    mutating func changeStatus(of card: Card, to cardStatus: CardStatus){
        if let index = deck.firstIndex(where: {$0.id == card.id}){
            deck[index].cardStatus = cardStatus
        }
    }
    
    //change all cards that are faceDown to faceUp
    mutating func changeStatusOfFaceDownCards(){
        let cards = deck.filter({$0.place == .game && ($0.cardStatus == .faceDown || $0.cardStatus == .isSet || $0.cardStatus == .isCheat)})
        for card in cards {
            if let index = deck.firstIndex(where: {$0.id == card.id}){
                deck[index].cardStatus = .faceUp
            }
        }
    }
    
    
}


