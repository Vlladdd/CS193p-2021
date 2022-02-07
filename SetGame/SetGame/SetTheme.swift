//
//  SetTheme.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 18.01.2022.
//

import SwiftUI

//representation of theme
//it should be a viedModel for that but since there is no themeChoser no need to and thats why i did getContent here which is obviosly
//a viewModel stuff and schouldnt be here cuz its a model
struct SetTheme {
    
    var colors: [String]
    var shapes: [String]
    var shades: [String]
    
    //func that returns an actual figure of card
    @ViewBuilder
    func getContent (symbolColor: String, colorType: String, symbol: String) -> some View{
        let color = getColor(by: symbolColor)
        let transperancy = getTransperancy(by: colorType)
        switch(symbol){
        case "diamond" :
            ZStack{
                Diamond().stroke(lineWidth: DrawingValues.lineWidth)
                    .foregroundColor(color)
                Diamond().foregroundColor(color).opacity(transperancy)
            }
        case "squiggle" :
            ZStack{
                Squiggle().stroke(lineWidth: DrawingValues.lineWidth)
                    .foregroundColor(color)
                Squiggle().foregroundColor(color).opacity(transperancy)
            }
        case "oval" :
            ZStack{
                Ellipse().stroke(lineWidth: DrawingValues.lineWidth)
                    .foregroundColor(color)
                Ellipse().foregroundColor(color).opacity(transperancy)
            }
        default:
            Rectangle().foregroundColor(color).opacity(transperancy)
        }
    }
    
    private func getColor(by colorName: String) -> Color {
        switch(colorName){
        case "red" :
            return .red
        case "green" :
            return .green
        case "purple" :
            return .purple
        default:
            return .red
        }
    }
    
    private func getTransperancy(by colorType: String) -> CGFloat {
        switch(colorType){
        case "solid" :
            return 1
        case "striped" :
            return 0.4
        case "open" :
            return 0
        default:
            return 1
        }
    }
}
