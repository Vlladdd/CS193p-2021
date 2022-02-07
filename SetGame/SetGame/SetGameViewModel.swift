//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 16.01.2022.
//

import SwiftUI

//ViewModel of game logic
class SetGameVIewModel:ObservableObject {
    
    typealias Card = SetGameLogic.Card
    
    //just to represent content of card
    struct SetCard:Identifiable,Equatable {
        var card: Card
        var id:Int {
            card.id
        }
        var forColorBlind = false
        var cardContent: some View {
            theme.getContent(symbolColor: card.symbolColor, colorType: card.colorType, symbol: card.symbol)
        }
    }
    
    @Published private var setModel: SetGameLogic
    
    var countOfDeck: Int {
        setModel.deck.filter({$0.place == .deck}).count
    }
    
    var deck: [SetCard] {
        var result: [SetCard] = []
        for card in setModel.deck{
            result.append(SetCard(card: card))
        }
        return result
    }
    
    var player1Score: Int {
        setModel.player1Score
    }
    
    var player2Score: Int {
        setModel.player2Score
    }
    
    var currentPlayer: SetGameLogic.Player {
        setModel.currentPlayer
    }
    
    
    var gameType: SetGameLogic.GameStatus {
        setModel.gameStatus
    }
    
    private static var theme = SetTheme(colors: ["red","green","purple"], shapes: ["diamond","squiggle","oval"], shades: ["solid","striped","open"])
    
    
    init() {
        setModel = SetGameLogic(possibleShapes: SetGameVIewModel.theme.shapes, possibleColors: SetGameVIewModel.theme.colors, possibleColorTypes: SetGameVIewModel.theme.shades)
    }
    
    func newGame(gameType: SetGameLogic.GameStatus = .singleplayer) {
        setModel.newGame(gameType: gameType)
    }
    
    //MARK: - Intent
    
    func choose(card: Card) {
        setModel.choose(card: card)
    }
    
    func checkCards(cards: [SetCard]) -> Bool{
        if cards.count == 3 {
            return setModel.isSet(card1: cards[0].card, card2: cards[1].card, card3: cards[2].card)
        }
        else {
            return false
        }
    }
    
    func addCards(player: SetGameLogic.Player) {
        setModel.addCards(player: player)
    }
    
    func cheat() {
        setModel.cheat()
    }
    
    func changePlace(of card: SetCard, to place: SetGameLogic.Place, at index: Int = -1) {
        setModel.changePlace(of: card.card, to: place, at: index)
    }
    
    func changeStatus(of card: SetCard, to cardStatus: SetGameLogic.CardStatus) {
        setModel.changeStatus(of: card.card, to: cardStatus)
    }
    
    func changeStatusOfFaceDownCards() {
        setModel.changeStatusOfFaceDownCards()
    }
    
    //for multiplayer. When player press button that he saw a set he have 3 seconds to pick it or otherwise he will get penalty points and also if
    //picked cards are not a set
    func penalty() {
        var isSet = false
        for card in deck.filter({$0.card.place == .game}) {
            if card.card.cardStatus == .isPartOfSet {
                isSet = true
                break
            }
        }
        if !isSet {
            setModel.penalty()
        }
        setModel.switchPlayer(player: .none)
    }
    
    func nextTurn() {
        setModel.nextTurn()
    }

    func switchPlayer(player: SetGameLogic.Player) {
        if setModel.currentPlayer == .none {
            _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in self.penalty()})
            setModel.switchPlayer(player: player)
        }
    }
}
