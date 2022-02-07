//
//  ViewExtensions.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 06.02.2022.
//

import SwiftUI

//an animatable ViewModifier which fixes problem with font scaling(because font is not animatable by default which results in poor quaility)
struct AnimatableSystemFontModifier: AnimatableModifier {
    
    var fontSize: CGFloat
    var fontScale: CGFloat
    var resultSize: CGFloat
    
    init(fontSize: CGFloat, fontScale: CGFloat){
        self.fontSize = fontSize
        self.fontScale = fontScale
        self.resultSize = fontSize * fontScale
    }
    
    var animatableData: CGFloat {
        get {
            resultSize
        }
        set {
            resultSize = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content.font(.system(size: resultSize))
    }
    
}

extension View {
    func animatableSystemFontModifier(fontSize: CGFloat, fontScale: CGFloat) -> some View{
        self.modifier(AnimatableSystemFontModifier(fontSize: fontSize, fontScale: fontScale))
    }
}
