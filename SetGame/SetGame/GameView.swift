//
//  ContentView.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 16.01.2022.
//

import SwiftUI

//view that represents game
struct GameView: View {
    
    @ObservedObject var model: SetGameVIewModel
    
    //used for transition between deck/game/discard
    @Namespace private var discardingCards
    
    //delay animation for card when number of cards needs to be animated
    private func dealAnimationForCardCount(id: Int, count: Int) -> Animation {
        var delay = 0.0
        delay = Double(id) * (Double(2) / Double(count))
        return Animation.easeInOut(duration: Double(1)).delay(delay)
    }
    
    //make transition between game and discard delayed when set is picked
    private func delayIfSet() -> Double {
        var delay: Double = 0
        let countOfSetCards = model.deck.filter({$0.card.cardStatus == .isPartOfSet}).count
        if countOfSetCards > 0 {
            delay = 1
        }
        return delay
    }

    //change availability of set button in multiplayer to not let users spam it
    @State private var isSetAvailable = true
    
    //just to make cards fly from top of the deck
    private func zIndex(of card: SetGameVIewModel.SetCard) -> Double {
        -Double(model.deck.firstIndex(where: { $0.id == card.id }) ?? 0)
    }

    var body: some View {
        GeometryReader{ geometry in
            VStack{
                if model.gameType == .multiplayer {
                    buttons(player: .player2).rotationEffect(Angle(degrees: -180))
                        .animatableSystemFontModifier(fontSize: DrawingValues.fontSize, fontScale: fontScale(size: geometry.size))
                    Text("Score:\(model.player2Score)").animatableSystemFontModifier(fontSize: DrawingValues.fontSize, fontScale: fontScale(size: geometry.size)).rotationEffect(Angle(degrees: -180))
                }
                ZStack {
                    VStack{
                        decks(in: geometry.size)
                        AspectViewAdapter(items: model.deck.filter({$0.card.place == .game}), aspectRatio: DrawingValues.aspectRatioForCard){ card in
                            Card(card: card, model: model)
                                .padding(5)
                                .zIndex(zIndex(of: card))
                                .onTapGesture {
                                    withAnimation(Animation.linear.delay(delayIfSet())){
                                        model.choose(card: card.card)
                                    }
                                }
                                .matchedGeometryEffect(id: card.id, in: discardingCards)
                                .transition(AnyTransition.asymmetric(insertion: .scale, removal: .identity))
                        }
                    }
                    .onAppear(){
                        //animate start of the game
                        //first we change place of cards from deck to game
                        //then we make them faceup
                        //cant do it all in one cuz then it will be no flip animation
                        for index in 0..<12 {
                            withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                                model.changePlace(of: model.deck[index], to: .game)
                            }
                        }
                        for index in 0..<12 {
                            withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                                model.changeStatus(of: model.deck[index], to: .faceUp)
                            }
                        }
                    }
                }
                Text("Score:\(model.player1Score)").animatableSystemFontModifier(fontSize: DrawingValues.fontSize, fontScale: fontScale(size: geometry.size)).font(.largeTitle)
                buttons(player: .player1)
                    .animatableSystemFontModifier(fontSize: DrawingValues.fontSize, fontScale: fontScale(size: geometry.size))
            }
        }
    }
    
    //deck/discard and arrows which shows whos turn in multiplayer
    @ViewBuilder
    func decks(in size: CGSize) -> some View {
        HStack{
            if model.gameType == .multiplayer {
                turnArrrow(player: .player1, buttonName: "arrow.down")
                    .animatableSystemFontModifier(fontSize: DrawingValues.fontSize, fontScale: fontScale(size: size))
                Spacer()
            }
            HStack {
                Spacer()
                Deck(cards: model.deck.filter({$0.card.place == .deck}), model: model, discardingCards: discardingCards, isZindex: true).frame(width: size.width / DrawingValues.scaleFactor, alignment: .center).onTapGesture {
                    let delay = delayIfSet()
                    withAnimation(Animation.linear.delay(delay)){
                        model.addCards(player: model.currentPlayer)
                    }
                    withAnimation(Animation.linear(duration: 1).delay(delay)){
                        model.changeStatusOfFaceDownCards()
                    }
                }
                //disable ability to add cards when there is no cards in deck and also in multiplayer
                //(cuz in multiplayer there is a button for each player for that)
                .disabled(model.countOfDeck == 0 || model.gameType == .multiplayer)
                Spacer()
                Deck(cards: model.deck.filter({$0.card.place == .discard}), model: model, discardingCards: discardingCards, isZindex: false).frame(width: size.width / DrawingValues.scaleFactor, alignment: .center)
                Spacer()
            }
            if model.gameType == .multiplayer {
                Spacer()
                turnArrrow(player: .player2, buttonName: "arrow.up")
                    .animatableSystemFontModifier(fontSize: DrawingValues.fontSize, fontScale: fontScale(size: size))
            }
        }
    }
    
    @ViewBuilder
    func turnArrrow(player: SetGameLogic.Player, buttonName: String) -> some View {
        if model.currentPlayer == player {
            Image(systemName: buttonName)
                .padding()
        }
        else {
            Image(systemName: buttonName)
                .padding()
                .opacity(0)
        }
    }
    
    //when cards are added they first change place from deck to game then unface
    func unFaceCards() {
        withAnimation(Animation.linear(duration: 1)){
            model.changeStatusOfFaceDownCards()
        }
    }
    
    //newgame, cheat, add cards and set buttons. Add cards and set are only in multiplayer. Set button used to let player
    //indicate that he saw a set and then have a little of time to choose it
    @ViewBuilder
    func buttons(player: SetGameLogic.Player) -> some View {
        HStack{
            Button(action: {
                withAnimation(){
                    model.newGame(gameType: model.gameType)
                }
                for index in 0..<12 {
                    withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                        model.changePlace(of: model.deck[index], to: .game)
                    }
                }
                for index in 0..<12 {
                    withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                        model.changeStatus(of: model.deck[index], to: .faceUp)
                    }
                }
            })
            {
                Image(systemName: "arrowtriangle.right.circle.fill")
            }
            .contextMenu{
                Button(action: {
                    withAnimation(){
                        model.newGame(gameType: .singleplayer)
                    }
                    for index in 0..<12 {
                        withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                            model.changePlace(of: model.deck[index], to: .game)
                        }
                    }
                    for index in 0..<12 {
                        withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                            model.changeStatus(of: model.deck[index], to: .faceUp)
                        }
                    }
                }, label: {
                    Text("Singleplayer")
                })
                Button(action: {
                    isSetAvailable = false
                    _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false){_ in
                        isSetAvailable = true
                    }
                    withAnimation(){
                        model.newGame(gameType: .multiplayer)
                    }
                    for index in 0..<12 {
                        withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                            model.changePlace(of: model.deck[index], to: .game)
                        }
                    }
                    for index in 0..<12 {
                        withAnimation(dealAnimationForCardCount(id: index,count: 12)){
                            model.changeStatus(of: model.deck[index], to: .faceUp)
                        }
                    }
                }, label: {
                    Text("Multiplayer")
                })
            }
            Spacer()
            Button(action: {
                withAnimation(){
                    model.cheat()
                }
                if model.gameType == .multiplayer {
                    isSetAvailable = false
                    _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false){_ in
                        self.unFaceCards()
                        isSetAvailable = true
                    }
                }
            }) {
                Text("Cheat")
            }
            Spacer()
            if model.gameType == .multiplayer{
                Button(action: {
                    _ = Timer.scheduledTimer(withTimeInterval: 3.1, repeats: false, block: {_ in
                        let delay = delayIfSet()
                        withAnimation(Animation.linear.delay(delay)){
                            model.nextTurn()
                        }
                        withAnimation(Animation.linear(duration: 1).delay(delay)){
                            model.changeStatusOfFaceDownCards()
                        }
                        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in isSetAvailable = true })
                    })
                    isSetAvailable = false
                    model.switchPlayer(player: player)
                }) {
                    Text("Set")
                }
                .disabled(!isSetAvailable)
                Spacer()
            }
            if model.gameType == .multiplayer {
                Button(action: {
                    withAnimation(Animation.linear){
                        model.addCards(player: player)
                    }
                    withAnimation(Animation.linear(duration: 1)){
                        model.changeStatusOfFaceDownCards()
                    }
                })
                {
                    Image(systemName: "plus.app")
                }
                //disable ability to add cards when there is no cards in deck
                .disabled(model.countOfDeck == 0)
            }
        }
        .padding(.horizontal)
    }
    
    //used to adjust fonts
    func fontScale(size: CGSize) -> CGFloat {
        min(size.width,size.height)/DrawingValues.geometryScale
    }
}

//represents card
struct Card: View {
    
    let card: SetGameVIewModel.SetCard
    
    let model: SetGameVIewModel
    
    private func dealAnimation(for card: SetGameVIewModel.SetCard) -> Double {
        var delay = 0.0
        if let index = model.deck.filter({$0.card.place == .game}).firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (Double(1) / 12)
        }
        return delay
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(){
                getCardContent()
                    .padding(.horizontal)
                    .aspectRatio(DrawingValues.aspectRatioForContent, contentMode: .fit)
            }
            .cardify(card: card, model: model, delay: dealAnimation(for: card))
            //just for testing purposes to see that cards really fly from top of deck and also fly to top of discard
            //Text("\(card.card.id)").padding(5)
            //for color blind people so they can see a text representation of color. Not the best idea but i quess also not dat bad because
            //all color blind people can see black and white color
            if card.forColorBlind == true {
                Text("\(card.card.symbolColor)").padding(5)
            }
        }
        .aspectRatio(DrawingValues.aspectRatioForCard, contentMode: .fit)
    }
    
    //getting shapes on card
    @ViewBuilder
    func getCardContent() -> some View {
        switch card.card.symbolsCount {
        case 1:
            VStack(alignment: .center){
                card.cardContent
            }
        case 2:
            VStack(alignment: .center){
                card.cardContent
                card.cardContent
            }
        case 3:
            VStack(alignment: .center){
                card.cardContent
                card.cardContent
                card.cardContent
            }
        default:
            VStack(alignment: .center){
                card.cardContent
            }
        }
    }
}

//represents deck and discard
struct Deck: View {
    
    let cards: [SetGameVIewModel.SetCard]
    
    let model: SetGameVIewModel
    
    let discardingCards: Namespace.ID
    
    //if deck - then cards fly from top, else - cards fly on top of discard
    let isZindex: Bool
    
    private func zIndex(of card: SetGameVIewModel.SetCard) -> Double {
        if isZindex {
            return -Double(model.deck.firstIndex(where: { $0.id == card.id }) ?? 0)
        }
        else {
            return 0
        }
    }
    
    var body: some View {
        ZStack{
            ForEach(cards) { card in
                Card(card: card, model: model)
                    .zIndex(zIndex(of: card))
                    .rotationEffect(Angle(degrees: card.card.rotation))
                    .matchedGeometryEffect(id: card.id, in: discardingCards)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .animation(Animation.linear(duration: 0.3))
            }
        }.aspectRatio(DrawingValues.aspectRatioForCard, contentMode: .fit)
    }
}

//some constrants
struct DrawingValues {
    static var scaleFactor:CGFloat = 4
    static let fontSize: CGFloat = 32
    //this value is too big because i use whole geometry of game body to adjusts fonts
    static let geometryScale: CGFloat = 500
    static var aspectRatioForCard:CGFloat = 2/3
    static var aspectRatioForContent:CGFloat = 3/2
    static var lineWidth:CGFloat = 3
    static var lineWidthForCircle:CGFloat = 1
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SetGameVIewModel()
        GameView(model: model)
            .previewDevice("iPhone 12")
    }
}
