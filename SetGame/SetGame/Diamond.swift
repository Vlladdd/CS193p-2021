//
//  Diamond.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 18.01.2022.
//

import SwiftUI

//representation of diamond
struct Diamond: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var p = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        //just a side length
        let modifier = min(rect.size.width,rect.size.height) / 2
        
        
        let point1 = CGPoint(x: rect.midX, y: rect.midY - modifier)
        let point2 = CGPoint(x: rect.midX - modifier, y: rect.midY)
        let point3 = CGPoint(x: rect.midX, y: rect.midY + modifier)
        let point4 = CGPoint(x: rect.midX + modifier, y: rect.midY)
        
        p.move(to: center)
        p.move(to: point1)
        p.addLine(to: point2)
        p.addLine(to: point3)
        p.addLine(to: point4)
        p.addLine(to: point1)
        
        
        return p
    }
    
}


