//
//  ThemeEditor.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 02.02.2022.
//

import SwiftUI

//view that lets user edit theme
struct ThemeEditor: View {
    
    @Binding var theme: Theme
    
    @State private var emojisToAdd: String = ""
    @State private var colorType: ColorType = .none
    
    @State private var color1: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    @State private var color2: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    //used to specify colorType of theme
    private enum ColorType {
        case gradient
        case color
        case none
    }
    
    //used in Stepper to increase or decrease numberOfPairs
    func incrementStep() {
        theme.numberOfPairs += 1
        if theme.numberOfPairs > theme.emojis.count { theme.numberOfPairs = 2 }
    }

    func decrementStep() {
        theme.numberOfPairs -= 1
        if theme.numberOfPairs < 2 { theme.numberOfPairs = theme.emojis.count }
    }
    

    var body: some View {
        Form {
            nameSection
            addSection
            removeSection
            removedEmojiSection
            numberOfPairsSection
            colorSection
        }
    }
    
    //section in form to edit name of theme
    private var nameSection: some View {
        Section(content: {
            TextField("Name", text: $theme.name)
        }, header: {
            Text("Name")
        })
    }
    
    //section in form to add emojis to theme
    //currently accepts any characters(in other words there is no isEmoji check) cuz i thought its fun to play with letters as well or some other
    //characters that a not emoji
    private var addSection: some View {
        Section(content: {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd){emojis in
                    for emoji in emojis.unique {
                        theme.emojis.append(String(emoji))
                    }
                    theme.emojis = theme.emojis.unique
                }
        }, header: {
            Text("Add emoji")
        })
    }
    
    //section in form to remove emojis from theme
    private var removeSection: some View {
        Section(content: {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]){
                ForEach(theme.identiableEmojis){ emoji in
                    Text(emoji.emoji)
                        .onTapGesture{
                            if let emojiIndex = theme.emojis.firstIndex(of: emoji.emoji){
                                theme.removedEmoji.append(theme.emojis[emojiIndex])
                                theme.emojis.remove(at: emojiIndex)
                            }
                        }
                }
            }
        }, header: {
            Text("Remove emoji")
        })
    }
    
    //section in form to add removed mojis back to the theme
    private var removedEmojiSection: some View {
        Section(content: {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]){
                ForEach(theme.removedEmojiIdentifiable){ emoji in
                    Text(emoji.emoji)
                        .onTapGesture{
                            if let emojiIndex = theme.removedEmoji.firstIndex(of: emoji.emoji){
                                theme.emojis.append(theme.removedEmoji[emojiIndex])
                                theme.removedEmoji.remove(at: emojiIndex)
                            }
                        }
                }
            }
        }, header: {
            Text("Removed emoji")
        })
    }
    
    //section in form to increase or decrease number of pairs in theme
    private var numberOfPairsSection: some View {
        Section(content: {
            Stepper("\(theme.numberOfPairs)", onIncrement: incrementStep, onDecrement: decrementStep)
        }, header: {
            Text("Number of pairs")
        })
    }
    
    //section in form to pick a color of theme
    private var colorSection: some View {
        Section(content: {
            if theme.color.count == 1 {
                Rectangle()
                    .foregroundColor(Color(rgbaColor: theme.color[0]))
            }
            if theme.color.count == 2 {
                Rectangle()
                    .fill(LinearGradient(colors: [Color(rgbaColor: theme.color[0]),Color(rgbaColor: theme.color[1])], startPoint: UnitPoint.init(x: 0.5, y: 0), endPoint: UnitPoint.init(x: 0.5, y: 0.6)))
            }
            Button(action: {
                colorType = .gradient
            }, label: {
                Text("Gradient")
            })
            Button(action: {
                colorType = .color
            }, label: {
                Text("Color")
            })
            if colorType == .color{
                Text("Color Type: Color")
                ColorPicker("Pick Color", selection: $color1)
                    .onChange(of: color1){color in
                        while theme.color.count > 0 {
                            theme.color.remove(at: 0)
                        }
                        theme.color.insert(RGBAColor(color: Color(color)), at: 0)
                    }
            }
            if colorType == .gradient{
                Text("Color Type: Gradient")
                ColorPicker("Pick Color", selection: $color1)
                    .onChange(of: color1){color in
                        while theme.color.count > 1 {
                            theme.color.remove(at: 0)
                        }
                        theme.color.insert(RGBAColor(color: Color(color)), at: 0)
                    }
                ColorPicker("Pick Color", selection: $color2)
                    .onChange(of: color2){color in
                        while theme.color.count > 1 {
                            theme.color.remove(at: 1)
                        }
                        theme.color.insert(RGBAColor(color: Color(color)), at: 1)
                    }
            }
        }, header: {
            Text("Color")
        })
    }
}

struct ThemeEditor_Previews: PreviewProvider {
    static var previews: some View {
        ThemeEditor(theme: .constant(Theme(name: "vehichles", emojis: ["🚘","✈️","🏎","🛵","🚒","🛩","🚉","🛳","🚇","🚕","🛥","🚗","🚁","🚀","🚃","🚟","🚎","🛻","🚋","🏍","🚜","🚑","🚓","🛺"],color: [RGBAColor(red: 255, green: 0, blue: 0, alpha: 1),RGBAColor(red: 0, green: 255, blue: 0, alpha: 1)], isRandomNumberPairsOfCards: true, id: 0)))
    }
}
