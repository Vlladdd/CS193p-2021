//
//  ThemeChoser.swift
//  Memorize
//
//  Created by Vlad Nechyporenko on 02.02.2022.
//

import SwiftUI

//view that lets user choose theme to play with
struct ThemeChoser: View {
    
    @EnvironmentObject var themeStore: ThemeViewModel
    @State private var editMode: EditMode = .inactive
    //dicstionary that stored all games and their themes
    @State var gamesDictionary = [Int:GameViewModel]()
    //there are some alerts for example when we cant play game because not enough cards etc
    @State var alert: IdentifiableAlert?
    
    var body: some View {
        NavigationView {
            list
        }
        .onAppear{
            for theme in themeStore.themes{
                gamesDictionary[theme.id] = GameViewModel(with: theme)
            }
        }
        .alert(item: $alert){alert in
            alert.alert()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    //theme to edit
    @State var editingTheme: Theme?
    
    //gesture that lets user edit theme
    private func tapGesture(theme: Theme) -> some Gesture {
        TapGesture().onEnded{
            editingTheme = theme
        }
    }
    
    //gesture that represents alert when user cant play game
    private func disabledTapGesture() -> some Gesture {
        TapGesture().onEnded{
            alert = IdentifiableAlert(id: "myAlert") { Alert(title: Text("Error"), message: Text("emojis and numbers of pairs should be more then 2 and color should be picked"), dismissButton: .default(Text("OK"))) }
        }
    }
    
    //info about color of the theme in list
    private func colorStack(of theme: Theme) -> some View {
        HStack{
            Text("Color: ")
            if let color = themeStore.getColor(of: theme) {
                Rectangle()
                    .foregroundColor(color)
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    //info about gradientColor of the theme in list
    private func gradientColorStack(of theme: Theme) -> some View {
        HStack{
            Text("Gradient Colors: ")
            if let color = themeStore.getGradientColor(of: theme) {
                Rectangle()
                    .fill(color)
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    //button that lets user add and start editing a new theme
    private var addButton: some View {
        Button(action: {
            themeStore.addTheme(name: "New", emojis: [String](), color: [RGBAColor]())
            editingTheme = themeStore.themes[themeStore.themes.count - 1]
            let index = themeStore.themes.count-1
            let theme = themeStore.themes[index]
            gamesDictionary[theme.id] = GameViewModel(with: theme)
        }, label: {
            Text("Add")
        })
    }
    
    //container which contains all info about theme
    private func listItem(of theme: Theme) -> some View {
        VStack(alignment: .center){
            Text(theme.name)
            VStack(alignment: .leading){
                if theme.color.count == 1{
                    colorStack(of: theme)
                }
                else if theme.color.count == 2{
                    gradientColorStack(of:  theme)
                }
                Text("Cards in theme: \(theme.numberOfPairs * 2)")
                Text("Emoji example: \(themeStore.getRandomEmojisFromTheme(theme).joined(separator: ","))")
            }
        }
    }
    
    //content of list(all themes)
    private var listContent: some View {
        ForEach(themeStore.themes){theme in
            if let game = gamesDictionary[theme.id]{
                NavigationLink(destination: GameView().environmentObject(game)){
                    listItem(of: theme)
                }
                .disabled(game.randomTheme.emojis.count < 2 || game.randomTheme.numberOfPairs < 2 || game.randomTheme.color.count < 1)
                .gesture((game.randomTheme.emojis.count < 2 || game.randomTheme.numberOfPairs < 2 || game.randomTheme.color.count < 1) && editMode == .inactive ? disabledTapGesture() : nil)
                .gesture(editMode == .inactive ? nil : tapGesture(theme: theme))
            }
        }
        .onDelete(){indexSet in
            themeStore.themes.remove(atOffsets: indexSet)
        }
        .onMove(){oldIndexSet, newIndexSet in
            themeStore.themes.move(fromOffsets: oldIndexSet, toOffset: newIndexSet)
        }
    }
    
    //some modifiers to list
    private var list: some View {
        List {
            listContent
        }
        .sheet(item: $editingTheme, onDismiss: {
            for theme in themeStore.themes {
                if gamesDictionary[theme.id]?.randomTheme != theme {
                    gamesDictionary[theme.id]?.randomTheme = theme
                }
            }
        }) { item in
            if let index = themeStore.findThemeIndexOf(theme: item) {
                ThemeEditor(theme: $themeStore.themes[index])
            }
        }
        .navigationTitle("Available themes")
        .toolbar {
            ToolbarItem{EditButton()}
            ToolbarItem(placement: .navigationBarLeading){
                addButton
            }
        }
        .environment(\.editMode, $editMode)
    }
}

struct ThemeChoser_Previews: PreviewProvider {
    static var previews: some View {
        ThemeChoser().environmentObject(ThemeViewModel(named: "Test"))
    }
}
