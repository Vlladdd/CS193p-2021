//
//  Cardify.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 21.01.2022.
//

import SwiftUI

//make card from content and also make flip animation
struct Cardify: AnimatableModifier {
    
    var card: SetGameVIewModel.SetCard
    
    var model: SetGameVIewModel
    
    var delay: Double
    
    var cardStatus: SetGameLogic.CardStatus {
        card.card.cardStatus
    }
    
    init(card: SetGameVIewModel.SetCard, model: SetGameVIewModel, delay: Double){
        self.card = card
        self.model = model
        self.delay = delay
        rotation = card.card.cardStatus != .faceDown ? 0 : 180
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
    
    //check for cardStatus and notify user which status is currently
    func body(content: Content) -> some View {
        ZStack(){
            if rotation < 90{
                Rectangle()
                    .border(.red, width: DrawingValues.lineWidth)
                    .foregroundColor(.white)
            }
            else if rotation > 90{
                Rectangle()
                    .border(.red, width: DrawingValues.lineWidth)
                    .foregroundColor(.red)
            }
            if cardStatus == .isPartOfSet{
                Rectangle()
                    .foregroundColor(.green).opacity(0.25)
                    .border(.red, width: DrawingValues.lineWidth)
            }
            else if cardStatus == .isSet{
                Rectangle()
                    .foregroundColor(.red).opacity(0.25)
                    .border(.red, width: DrawingValues.lineWidth)
            }
            else if cardStatus == .isSelected{
                Rectangle()
                    .foregroundColor(.blue).opacity(0.25)
                    .border(.red, width: DrawingValues.lineWidth)
            }
            else if cardStatus == .isCheat{
                Rectangle()
                    .foregroundColor(.yellow).opacity(0.25)
                    .border(.red, width: DrawingValues.lineWidth)
            }
            if rotation < 90 {
                content
            }
        }
        //some animations when user picked cards which are set and which are not set
        .rotationEffect(Angle(degrees: card.card.cardStatus == .isPartOfSet ? 360 : 0))
        .scaleEffect(x: card.card.cardStatus == .isSet ? 0.5 : 1, y: card.card.cardStatus == .isSet ? 0.8 : 1, anchor: .center)
        //flip animation
        .rotation3DEffect(Angle(degrees: rotation), axis: (0,1,0))
    }
    
}

//just syntactic sugar
extension View {
    
    func cardify(card: SetGameVIewModel.SetCard, model: SetGameVIewModel, delay: Double) -> some View{
        modifier(Cardify(card: card, model: model, delay: delay))
    }
}
