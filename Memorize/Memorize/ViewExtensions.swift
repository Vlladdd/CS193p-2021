//
//  ViewExtensions.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 02.02.2022.
//

import SwiftUI

extension Color {
    //just simple convertion from rgbaColor to Color
    init(rgbaColor rgba: RGBAColor) {
        self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }
}

extension RGBAColor {
    //just simple convertion from Color to rgbaColor
    init(color: Color) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if let cgColor = color.cgColor {
            UIColor(cgColor: cgColor).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        self.init(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
}

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
}

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
