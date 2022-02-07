//
//  Squiggle.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 18.01.2022.
//

import SwiftUI

//representation of squiggle. Not the best one but i am proud of myself:)
struct Squiggle: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var p = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let modifier = min(rect.size.width,rect.size.height) / 3.5
        let modifier2 = modifier * 2
        
        let point1 = CGPoint(x: rect.midX + modifier, y: rect.midY)
        let point2 = CGPoint(x: rect.midX - modifier2, y: rect.midY + modifier2)
        let point3 = CGPoint(x: rect.midX - modifier2, y: rect.midY - modifier2)
        let point4 = CGPoint(x: rect.midX - modifier2, y: rect.midY)
        let point5 = CGPoint(x: rect.midX + modifier, y: rect.midY + modifier2)
        let point6 = CGPoint(x: rect.midX - modifier, y: rect.midY + modifier)
        let point7 = CGPoint(x: rect.midX - modifier, y: rect.midY + modifier)
        let point8 = CGPoint(x: rect.midX + modifier2, y: rect.midY + modifier2)
        let point9 = CGPoint(x: rect.midX + modifier2, y: rect.midY)
        let point10 = CGPoint(x: rect.midX + modifier2, y: rect.midY - modifier)
        
        p.move(to: center)
        p.move(to: point1)
        p.addCurve(to: point2, control1: point3, control2: point4)
        p.addCurve(to: point5, control1: point6, control2: point7)
        p.addCurve(to: point10, control1: point8, control2: point9)
        p.addCurve(to: point1, control1: point1, control2: point1)

        return p
    }
    
}

