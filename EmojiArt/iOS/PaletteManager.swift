//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Vlad Nechyporenko on 01.02.2022.
//

import SwiftUI

struct PaletteManager: View {
    
    @EnvironmentObject var paletteStore: PaletteStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(paletteStore.palettes){palette in
                    NavigationLink(destination: PaletteEditor(palette: $paletteStore.palettes[palette])){
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete(){indexSet in
                    paletteStore.palettes.remove(atOffsets: indexSet)
                }
                .onMove(){indexSet,newSet in
                    paletteStore.palettes.move(fromOffsets: indexSet, toOffset: newSet)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .dismissMe{presentationMode.wrappedValue.dismiss()}
            .toolbar {
                ToolbarItem(){
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager().previewDevice("iPhone 12").environmentObject(PaletteStore(named: "Test"))
    }
}
