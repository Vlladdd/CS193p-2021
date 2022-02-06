//
//  Cardify.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 20.01.2022.
//

import SwiftUI

//modfier that make a card from content and also animates it with a flip animation when card is change status from faceDown to faceUp
struct Cardify: AnimatableModifier {
    
    var isFaceUp: Bool
    var isMatched: Bool
    var color: Color?
    var gradientColor: LinearGradient?
    
    init(isFaceUp: Bool, isMatched: Bool, color: Color?, gradientColor: LinearGradient?){
        self.isFaceUp = isFaceUp
        self.isMatched = isMatched
        if let color = color {
            self.color = color
        }
        if let gradientColor = gradientColor {
            self.gradientColor = gradientColor
        }
        rotation = isFaceUp ? 0 : 180
    }
    
    
    var animatableData: Double {
        get {
            rotation
        }
        set {
            rotation = newValue
        }
    }
    
    var rotation: Double
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: DrawingValues.rounderRectangleRadius)
            if isFaceUp {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingValues.lineWidth).foregroundColor(.red)
            }
            else if isMatched && rotation == 180 {
                shape.opacity(0)
            }
            else if let color = color{
                shape.fill().foregroundColor(color)
            }
            else if let gradientColor = gradientColor {
                shape.fill(gradientColor)
            }
            if rotation < 90 {
                content
            }
        }
        .rotation3DEffect(Angle(degrees: rotation), axis: (0,1,0))
    }
    
}

extension View {
    func cardify(isFaceUp: Bool,isMatched: Bool, color: Color?, gradientColor: LinearGradient?) -> some View{
        self.modifier(Cardify(isFaceUp: isFaceUp, isMatched: isMatched, color: color, gradientColor: gradientColor))
    }
}
