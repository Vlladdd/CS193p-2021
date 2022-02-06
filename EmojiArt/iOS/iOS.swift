//
//  iOS.swift
//  EmojiArt
//
//  Created by Vlad Nechyporenko on 06.02.2022.
//

import SwiftUI

extension UIImage {
    var imageData: Data? {
        jpegData(compressionQuality: 1.0)
    }
}

struct Pasteboard {
    static var imageData: Data? {
        UIPasteboard.general.image?.imageData
    }
    static var imageURL: URL? {
        UIPasteboard.general.url?.imageURL
    }
}

extension View {
    
    func paletteControlButtonStyle() -> some View {
        self
    }
    
    func popoverPadding() -> some View {
        self
    }
    
    @ViewBuilder
    func makeMeDismiss(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            NavigationView {
                self
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissMe(dismiss)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        else {
            self
        }
    }
    
    @ViewBuilder
    func dismissMe(_ dismiss: (() -> Void)?) -> some View {
        
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            self
                .toolbar{
                    ToolbarItem(placement: .cancellationAction){
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Close")
                        })
                    }
                }
        }
        else {
            self
        }
    }
}
