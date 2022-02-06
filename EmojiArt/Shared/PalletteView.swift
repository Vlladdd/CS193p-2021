//
//  PalletteView.swift
//  EmojiArt
//
//  Created by Vlad Nechyporenko on 31.01.2022.
//

import SwiftUI

struct PalletteView: View {
    
    @EnvironmentObject var paletteStore: PaletteStore
    
    var emojiFontSize: CGFloat
    
    
    var body: some View {
        palette
            .clipped()
            .popover(item: $currentPalette){palette in
                PaletteEditor(palette: $paletteStore.palettes[palette])
                    .popoverPadding()
                    .makeMeDismiss{currentPalette = nil}
            }
            .sheet(isPresented: $managing) {
                PaletteManager()
            }
    }
    
    @SceneStorage("PaletteEditor.currentPaletteIndex")
    private var currentPaletteIndex = 0
    
    @ViewBuilder
    var palette: some View {
        let myPallet = paletteStore.getPaletteByIndex(currentPaletteIndex)
        HStack {
            changeEmojis
            Group {
                Text(myPallet.name)
                ScrollingEmojisView(emojis: myPallet.emojis)
            }
            .id(myPallet.id)
            .transition(myTrancition)
        }
        .font(.system(size: emojiFontSize))
    }
    
    @State private var currentPalette: Palette?
    @State private var managing: Bool = false
    
    private var changeEmojis: some View{
        Button(action: {
            withAnimation{
                currentPaletteIndex = (currentPaletteIndex + 1) % paletteStore.palettes.count
            }
        }, label: {
            Image(systemName: "paintpalette")
        })
            .paletteControlButtonStyle()
            .contextMenu(){
                AnimatedActionButton(title: "Edit", systemImage: "pencil"){
                    currentPalette = paletteStore.palettes[currentPaletteIndex]
                }
                AnimatedActionButton(title: "New", systemImage: "plus"){
                    paletteStore.insertPalette(named: "New", emojis: "", at: currentPaletteIndex)
                    currentPalette = paletteStore.palettes[currentPaletteIndex]
                }
                AnimatedActionButton(title: "Delete", systemImage: "minus"){
                    currentPaletteIndex = paletteStore.removePaletteAtIndex(currentPaletteIndex)
                }
                #if os(iOS)
                AnimatedActionButton(title: "Manage", systemImage: "doc.plaintext"){
                    managing = true
                }
                #endif
                Menu {
                    ForEach(paletteStore.palettes){ palette in
                        AnimatedActionButton(title: "\(palette.name)"){
                            if let paletteIndex = paletteStore.palettes.index(matching: palette){
                                currentPaletteIndex = paletteIndex
                            }
                        }
                    }
                } label: {
                    Label("Go to", systemImage: "doc.text.magnifyingglass")
                }
            }
    }
    
    private var myTrancition: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: 0, y: emojiFontSize), removal: .offset(x: 0, y: -emojiFontSize))
    }
    
}

struct ScrollingEmojisView: View {
    let emojis: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.unique.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct PalletteView_Previews: PreviewProvider {
    static var previews: some View {
        PalletteView(emojiFontSize: 40).environmentObject(PaletteStore(named: "Test"))
    }
}
