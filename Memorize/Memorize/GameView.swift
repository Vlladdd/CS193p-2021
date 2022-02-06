//
//  GameView.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 27.09.2021.
//

import SwiftUI

//view that represents game
struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var themeStore: ThemeViewModel
    
    var body: some View {
        VStack{
            top
            cards
            bottom
        }
        .navigationTitle(viewModel.nameOfTheme)
    }
    
    //just a red line
    @ViewBuilder
    private var top: some View {
        Color.red.frame(height:CGFloat(20) / UIScreen.main.scale)
    }
    
    //cards to play with
    private var cards: some View {
        AspectViewAdapter(items: viewModel.cards, aspectRatio: 2/3) {card in
            Card(card: card, color: themeStore.getColor(of: viewModel.randomTheme), gradientColor: themeStore.getGradientColor(of: viewModel.randomTheme))
                .padding(4)
                .onTapGesture {
                    withAnimation {
                        viewModel.choose(card)
                    }
                }
        }
    }
    
    //newGame button and score label
    @ViewBuilder
    private var bottom: some View {
        HStack{
            VStack {
                Image(systemName: "arrowtriangle.right.circle.fill")
                    .font(.largeTitle)
                    .onTapGesture{
                        withAnimation {
                            viewModel.newGame()
                        }
                    }
                Text("New Game")
            }
            .foregroundColor(.blue)
            Spacer()
            Text("Score:\(viewModel.score)").font(.largeTitle)
        }
        .padding(.horizontal)
    }
}

//view that represents card
struct Card: View {
    let card: MemoryGame<String>.Card
    let color: Color?
    let gradientColor: LinearGradient?
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                Text(card.content)
                    .foregroundColor(.black)
                    .animatableSystemFontModifier(fontSize: DrawingValues.fontSize, fontScale: fontScale(size: geometry.size))
            }.cardify(isFaceUp: card.isFaceUp, isMatched: card.isMatched, color: color, gradientColor: gradientColor)
        }
    }
}

//used to adjust font of cards
func fontScale(size: CGSize) -> CGFloat {
    min(size.width,size.height)/(DrawingValues.fontSize/DrawingValues.fontScale)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView().environmentObject(GameViewModel(with: ThemeViewModel(named: "Test").themes[0])).environmentObject(ThemeViewModel(named: "Test"))
            .previewDevice("iPhone 12")
    }
}

//some constants
struct DrawingValues {
    static let rounderRectangleRadius: CGFloat = 10
    static let fontScale: CGFloat = 0.7
    static let fontSize: CGFloat = 32
    static let lineWidth: CGFloat = 3
    static func getFont(by geometry: GeometryProxy) -> Font {
        Font.system(size: (min(geometry.size.width,geometry.size.height)) * fontScale)
    }
}
