//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @EnvironmentObject var document: EmojiArtDocument
    @Environment(\.undoManager) var undoManager
    
    @ScaledMetric private var defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PalletteView(emojiFontSize: defaultEmojiFontSize)
                .onDrop(of: [.plainText], isTargeted: nil) { providers in
                    deleteEmoji(providers: providers)
                }
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                OptionalImage(uiImage: document.backgroundImage)
                    .scaleEffect(zoomScale)
                    .position(convertFromEmojiCoordinatesForBackground((0,0), in: geometry))
                    .gesture(doubleTapToZoom(in: geometry.size).exclusively(before: backgroundTapGesture()))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        ZStack {
                            if emojiIsSelected(emoji: emoji) {
                                Rectangle()
                                    .opacity(0)
                                    .border(Color.red, width: 2)
                                    .frame(width: fontSize(for: emoji), height: fontSize(for: emoji), alignment: .center)
                                    .scaleEffect(scaleEffect(for: emoji))
                                    .position(position(for: emoji, in: geometry))
                            }
                            Text(emoji.text)
                                .animatableSystemFontModifier(fontSize: fontSize(for: emoji), fontScale: scaleEffect(for: emoji))
                                .onDrag { NSItemProvider(object: String(emoji.id) as NSString) }
                                .position(position(for: emoji, in: geometry))
                                .gesture(emojiTapGesture(emoji: emoji).simultaneously(with: panGestureForSelection(emoji: emoji)))
                        }
                    }
                }
            }
            .compactableToolbar {
                AnimatedActionButton(title: "Paste Background", systemImage: "doc.on.clipboard", action: {
                    pasteBackground()
                })
                if Camera.isAvailable {
                    AnimatedActionButton(title: "Take Photo", systemImage: "camera") {
                        backgroundPicker = .camera
                    }
                }
                if PhotoLibrary.isAvailable {
                    AnimatedActionButton(title: "Search Photos", systemImage: "photo") {
                        backgroundPicker = .library
                    }
                }
                #if os(iOS)
                if let undoManager = undoManager {
                    //if undoManager.canUndo {
                        AnimatedActionButton(title: undoManager.undoActionName, systemImage: "arrow.uturn.backward", action: {
                            undoManager.undo()
                        })
                   // }
                   // if undoManager.canRedo {
                        AnimatedActionButton(title: undoManager.redoActionName, systemImage: "arrow.uturn.forward", action: {
                            undoManager.redo()
                        })
                  //  }
                }
                //UndoButton(undo: undoManager?.optionalUndoMenuItemTitle, redo: undoManager?.optionalRedoMenuItemTitle)
                #endif
            }
            //there is a bug because of which context menu is not updating properly. This almost fixes it except when there is only 1 undo or redo
            .id(undoManager?.canUndo == true ? undoManager?.undoActionName : undoManager?.redoActionName)
            .clipped()
            .onDrop(of: [.utf8PlainText,.url,.image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alert){alert in
                alert.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus){ _ in
                makeAlertIfBackgroundStatusIsFailed()
            }
            .onReceive(document.$backgroundImage){image in
                zoomToFit(image, in: geometry.size)
            }
            .sheet(item: $backgroundPicker) { pickerType in
                switch pickerType {
                case .camera: Camera(handlePickedImage: { image in handlePickedBackgroundImage(image) })
                case .library: PhotoLibrary(handlePickedImage: { image in handlePickedBackgroundImage(image) })
                }
            }
        }
    }
    
    @State private var backgroundPicker: BackgroundPickerType?
    
    enum BackgroundPickerType: Identifiable {
        case camera
        case library
        var id: BackgroundPickerType { self }
    }
    
    private func handlePickedBackgroundImage(_ image: UIImage?) {
        if let imageData = image?.imageData {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        }
        backgroundPicker = nil
    }
    
    private func pasteBackground() {
        if let imageData = Pasteboard.imageData{
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        } else if let url = Pasteboard.imageURL {
            document.setBackground(.url(url), undoManager: undoManager)
        } else {
            alert = IdentifiableAlert(id: "Paste Background", alert: {
                Alert(title: Text("Paste background"), message: Text("There is no image in pasteboard!"), dismissButton: .default(Text("Ok")))}
            )
        }
    }
    
    // MARK: - Alert
    
    @State private var alert: IdentifiableAlert?
    
    private func makeAlertIfBackgroundStatusIsFailed() {
        switch document.backgroundImageFetchStatus {
        case .failed(let url):
            alert = IdentifiableAlert(id: "failedBackground" + url.absoluteString){
                Alert(title: Text("Error!"), message: Text("Cant fetch background image from \(url)"), dismissButton: .default(Text("Ok")))
            }
        default:
            break
        }
    }
    
    // MARK: - Drag and Drop
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL),undoManager: undoManager)
        }
        #if os(iOS)
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data),undoManager: undoManager)
                }
            }
        }
        #endif
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale,
                        undoManager: undoManager
                    )
                }
            }
        }
        return found
    }
    
    // MARK: - Positioning/Sizing Emoji
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        if selectedEmojis.contains(emoji) {
            return convertFromEmojiCoordinatesForEmoji((emoji.x, emoji.y), in: geometry)
        }
        else if unSelectedEmoji != emoji{
            return convertFromEmojiCoordinatesForBackground((emoji.x, emoji.y), in: geometry)
        }
        else {
            return convertFromEmojiCoordinatesForUnselectedEmoji((emoji.x, emoji.y), in: geometry)
        }
    }
    
    private func scaleEffect(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        if selectedEmojis.contains(emoji) {
            return zoomScaleForEmoji
        }
        else {
            return zoomScale
        }
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinatesForBackground(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    private func convertFromEmojiCoordinatesForEmoji(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScaleForEmoji + panOffsetForEmoji.width,
            y: center.y + CGFloat(location.y) * zoomScaleForEmoji + panOffsetForEmoji.height
        )
    }
    
    private func convertFromEmojiCoordinatesForUnselectedEmoji(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScaleForEmoji + panOffsetForUnselectedEmoji.width,
            y: center.y + CGFloat(location.y) * zoomScaleForEmoji + panOffsetForUnselectedEmoji.height
        )
    }
    
    // MARK: - Zooming
    
    
    @State private var steadyStateZoomScale: (forBackground :CGFloat, forEmoji :CGFloat) = (1,1)
    @GestureState private var gestureZoomScale: (forBackground :CGFloat, forEmoji :CGFloat) = (1,1)
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale.forBackground * gestureZoomScale.forBackground
    }
    
    private var zoomScaleForEmoji: CGFloat {
        steadyStateZoomScale.forBackground * gestureZoomScale.forBackground * steadyStateZoomScale.forEmoji * gestureZoomScale.forEmoji
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                if selectedEmojis.count == 0 {
                    gestureZoomScale.forBackground = latestGestureScale
                }
                else {
                    gestureZoomScale.forEmoji = latestGestureScale
                }
            }
            .onEnded { gestureScaleAtEnd in
                if selectedEmojis.count == 0 {
                    steadyStateZoomScale.forBackground *= gestureScaleAtEnd
                }
                else {
                    steadyStateZoomScale.forEmoji *= gestureScaleAtEnd
                    for emoji in selectedEmojis {
                        document.scaleEmoji(emoji, by: zoomScaleForEmoji / zoomScale, undoManager: undoManager)
                        toggleSelectionOfEmoji(emoji: emoji)
                        if let emoji = document.getEmoji(emoji) {
                            toggleSelectionOfEmoji(emoji: emoji)
                        }
                    }
                    steadyStateZoomScale.forEmoji = 1
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset.forBackground = .zero
            steadyStateZoomScale.forBackground = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Panning
    
    @State private var steadyStatePanOffset: (forBackground: CGSize, forEmoji: CGSize, forUnselectedEmoji: CGSize) = (CGSize.zero,CGSize.zero,CGSize.zero)
    @GestureState private var gesturePanOffset: (forBackground: CGSize, forEmoji: CGSize, forUnselectedEmoji: CGSize) = (CGSize.zero,CGSize.zero,CGSize.zero)
    
    private var panOffset: CGSize {
        (steadyStatePanOffset.forBackground + gesturePanOffset.forBackground) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                if selectedEmojis.count == 0 {
                    gesturePanOffset.forBackground = latestDragGestureValue.translation / zoomScale
                }
            }
            .onEnded { finalDragGestureValue in
                if selectedEmojis.count == 0 {
                    steadyStatePanOffset.forBackground = steadyStatePanOffset.forBackground + (finalDragGestureValue.translation / zoomScale)
                }
            }
    }
    
    //Selectin/deselection of emojis
    
    @State private var selectedEmojis = Set<EmojiArtModel.Emoji>()
    
    private func toggleSelectionOfEmoji(emoji: EmojiArtModel.Emoji){
        selectedEmojis.toggleMatching(matching: emoji)
    }
    
    private func emojiTapGesture(emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                toggleSelectionOfEmoji(emoji: emoji)
            }
    }
    
    private func emojiIsSelected(emoji: EmojiArtModel.Emoji) -> Bool {
        if selectedEmojis.contains(where: {$0.id == emoji.id}) {
            return true
        }
        else {
            return false
        }
    }
    
    //Deselect all emoji
    
    private func backgroundTapGesture() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                selectedEmojis = []
            }
    }
    
    //Drag selected emojis and unselected emoji
    //And also changes made in panning
    
    @State private var unSelectedEmoji: EmojiArtModel.Emoji?
    
    private var panOffsetForUnselectedEmoji: CGSize {
        (steadyStatePanOffset.forBackground + gesturePanOffset.forBackground + gesturePanOffset.forUnselectedEmoji + steadyStatePanOffset.forUnselectedEmoji) * zoomScaleForEmoji
    }
    
    private var panOffsetForEmoji: CGSize {
        (steadyStatePanOffset.forBackground + gesturePanOffset.forBackground + gesturePanOffset.forEmoji + steadyStatePanOffset.forEmoji) * zoomScaleForEmoji
    }
    
    private func panGestureForSelection(emoji: EmojiArtModel.Emoji) -> some Gesture {
        DragGesture()
            .onChanged{ _ in
                if !selectedEmojis.contains(emoji) && selectedEmojis.count > 0{
                    unSelectedEmoji = emoji
                }
            }
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                if selectedEmojis.contains(emoji) {
                    gesturePanOffset.forEmoji = latestDragGestureValue.translation / zoomScaleForEmoji
                }
                else if selectedEmojis.count > 0{
                    gesturePanOffset.forUnselectedEmoji = latestDragGestureValue.translation / zoomScaleForEmoji
                }
            }
            .onEnded { finalDragGestureValue in
                if selectedEmojis.contains(emoji) {
                    steadyStatePanOffset.forEmoji = steadyStatePanOffset.forEmoji + (finalDragGestureValue.translation / zoomScaleForEmoji)
                    for emoji in selectedEmojis {
                        document.moveEmoji(emoji, by: (panOffsetForEmoji - panOffset) / zoomScaleForEmoji, undoManager: undoManager)
                        toggleSelectionOfEmoji(emoji: emoji)
                        if let emoji = document.getEmoji(emoji) {
                            toggleSelectionOfEmoji(emoji: emoji)
                        }
                    }
                    steadyStatePanOffset.forEmoji = .zero
                }
                else if selectedEmojis.count > 0{
                    steadyStatePanOffset.forUnselectedEmoji = steadyStatePanOffset.forUnselectedEmoji + (finalDragGestureValue.translation / zoomScaleForEmoji)
                    if let unSelectedEmoji = unSelectedEmoji {
                        document.moveEmoji(unSelectedEmoji, by: (panOffsetForUnselectedEmoji - panOffset) / zoomScaleForEmoji, undoManager: undoManager)
                    }
                    steadyStatePanOffset.forUnselectedEmoji = .zero
                    unSelectedEmoji = nil
                }
            }
    }
    
    //Pinch selected emojis
    //Changes made in zooming
    
    //Deleting emojis
    //Also onDrag and onDrop modifiers were added to emoji and palette
    
    private func deleteEmoji(providers: [NSItemProvider]) -> Bool{
        let found = providers.loadObjects(ofType: String.self) { string in
            if let id = string.first {
                document.removeEmojiById(String(id),undoManager: undoManager)
            }
        }
        return found
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView().environmentObject(EmojiArtDocument())
    }
}
