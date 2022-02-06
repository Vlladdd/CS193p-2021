//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Vlad Nechyporenko on 01.02.2022.
//

import SwiftUI

struct PaletteEditor: View {
    
    @Binding var palette: Palette
    
    @State private var emojisToAdd = ""
    
    
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Name", text: $palette.name)
            }
            Section(header: Text("Add Emojis")) {
                TextField("", text: $emojisToAdd)
                    .onChange(of: emojisToAdd){emojis in
                        withAnimation {
                            for character in emojis {
                                if character.isEmoji {
                                    palette.emojis += emojisToAdd
                                }
                            }
                            palette.emojis = palette.emojis.unique
                        }
                    }
            }
            Section(header: Text("Remove Emojis")) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]){
                    ForEach(palette.emojis.unique.map{$0}, id:\.self){ emoji in
                        Text(String(emoji))
                            .onTapGesture{
                                if let emojiIndex = palette.emojis.firstIndex(of: emoji){
                                    palette.emojis.remove(at: emojiIndex)
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle(palette.name)
        .frame(minWidth: 300, minHeight: 350, alignment: .center)
    }
    
    
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(named: "test").getPaletteByIndex(0)))
            .previewLayout(.fixed(width: 300, height: 350))
    }
}
