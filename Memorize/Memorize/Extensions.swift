//
//  Extensions.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 02.02.2022.
//

import Foundation



extension RangeReplaceableCollection where Element: Hashable {
    
    //var that makes RangeReplaceableCollection with unique elements
    var unique: Self {
        var set = Set<Element>()
        for element in self {
            set.insert(element)
        }
        return Self(set)
    }
    
}
