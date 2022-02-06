//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

// syntactic sure to be able to pass an optional UIImage to Image
// (normally it would only take a non-optional UIImage)

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}

// syntactic sugar
// lots of times we want a simple button
// with just text or a label or a systemImage
// but we want the action it performs to be animated
// (i.e. withAnimation)
// this just makes it easy to create such a button
// and thus cleans up our code

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if title != nil && systemImage != nil {
                Label(title!, systemImage: systemImage!)
            } else if title != nil {
                Text(title!)
            } else if systemImage != nil {
                Image(systemName: systemImage!)
            }
        }
    }
}

// simple struct to make it easier to show configurable Alerts
// just an Identifiable struct that can create an Alert on demand
// use .alert(item: $alertToShow) { theIdentifiableAlert in ... }
// where alertToShow is a Binding<IdentifiableAlert>?
// then any time you want to show an alert
// just set alertToShow = IdentifiableAlert(id: "my alert") { Alert(title: ...) }
// of course, the string identifier has to be unique for all your different kinds of alerts

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
}

// a button that does undo (preferred) or redo
// also has a context menu which will display
// the given undo or redo description for each

struct UndoButton: View {
    let undo: String?
    let redo: String?
    
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        let canUndo = undoManager?.canUndo ?? false
        let canRedo = undoManager?.canRedo ?? false
        if canUndo || canRedo {
            Button {
                if canUndo {
                    undoManager?.undo()
                } else {
                    undoManager?.redo()
                }
            } label: {
                if canUndo {
                    Image(systemName: "arrow.uturn.backward.circle")
                } else {
                    Image(systemName: "arrow.uturn.forward.circle")
                }
            }
            .contextMenu {
                if canUndo {
                    Button {
                        undoManager?.undo()
                    } label: {
                        Label(undo ?? "Undo", systemImage: "arrow.uturn.backward")
                    }
                }
                if canRedo {
                    Button {
                        undoManager?.redo()
                    } label: {
                        Label(redo ?? "Redo", systemImage: "arrow.uturn.forward")
                    }
                }
            }
            //there is a bug because of which context menu is not updating properly. This almost fixes it except when there is only 1 undo or redo
            .id(canUndo == true ? undo : redo)
        }
    }
}

extension UndoManager {
    var optionalUndoMenuItemTitle: String? {
        return canUndo ? undoMenuItemTitle : nil
    }
    var optionalRedoMenuItemTitle: String? {
        return canRedo ? redoMenuItemTitle : nil
    }
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

struct CompactableToolbar: ViewModifier {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var compact: Bool {
        horizontalSizeClass == .compact
    }
    #else
    let compact = false
    #endif
    
    
    func body(content: Content) -> some View {
        if compact {
            Button(action: {
                
            }, label: {
                Image(systemName: "ellipsis.circle")
            })
            .contextMenu{
                content
            }
        }
        else {
            content
        }
    }
}

extension View {
    func compactableToolbar<Content>(@ViewBuilder content: () -> Content) -> some View where Content: View {
        self.toolbar{
            content().modifier(CompactableToolbar())
        }
    }
}
