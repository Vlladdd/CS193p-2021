//
//  AspectViewAdapter.swift
//  SetGame
//
//  Created by Vlad Nechyporenko on 16.01.2022.
//

import SwiftUI

//making cards as big as possible in LazyVGrid
struct AspectViewAdapter<Item, ItemView>: View where ItemView: View, Item: Identifiable {
    
    let items: [Item]
    let aspectRatio: CGFloat
    let content: (Item) -> ItemView
    
    init(items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView){
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = widthThatFits(in: geometry.size)
            VStack{
                ScrollView{
                    LazyVGrid(columns: [gridWithNoSpacing(width: width)], spacing: 0) {
                        ForEach(items) { item in
                            content(item).aspectRatio(aspectRatio, contentMode: .fit)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    private func gridWithNoSpacing(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    private func widthThatFits(in size: CGSize) -> CGFloat {
        if items.count < 13 {
            var columnCount = 1
            var rowCount = items.count
            repeat {
                let itemWidth = size.width / CGFloat(columnCount)
                let itemHeight = itemWidth / aspectRatio
                if  CGFloat(rowCount) * itemHeight < size.height {
                    break
                }
                columnCount += 1
                rowCount = (items.count + (columnCount - 1)) / columnCount
            } while columnCount < items.count
            if columnCount > items.count {
                columnCount = items.count
            }
            return floor(size.width / CGFloat(columnCount))
        }
        else {
            return size.width/5
        }
    }
    
// my own representation of widtThatFits. Not working perfectly
//    private func widthThatFits(in size: CGSize) -> CGFloat {
//
//        if items.count < 13 {
//
//            var columns = 1
//            var rows = items.count
//            while(columns <= rows) {
//                columns += 1
//                rows = items.count / columns
//            }
//
//            if size.width/CGFloat(columns) > size.width/3 {
//                return size.width/3
//            }
//            else {
//                return size.width/CGFloat(columns)
//            }
//        }
//        else {
//            return size.width/5
//        }
//    }
}

//struct AspectViewAdapter_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectViewAdapter()
//    }
//}
