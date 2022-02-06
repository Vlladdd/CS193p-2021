//
//  EmojiArtDocument.swift
//  Shared
//
//  Created by Vlad Nechyporenko on 06.02.2022.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "com.VladNechyporenko.emojiart")
}

class EmojiArtDocument: ReferenceFileDocument
{
    
    static var readableContentTypes = [UTType.emojiart]
    static var writableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        }
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    typealias Snapshot = Data
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
//            autosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
//    private var timer: Timer?
//
//    private func autosave() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
//            if let url = Autosave.url {
//                self.save(at: url)
//            }
//        }
//    }
    
//    private struct Autosave {
//        static var filename = "Autosave.emojiart"
//        static var url: URL? {
//            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//            return url?.appendingPathComponent(filename)
//        }
//    }
    
//    private func save(at url: URL){
//        let thisFunction = "\(String(describing: self)).\(#function)"
//        do {
//            let data = try emojiArt.json()
//            print("\(thisFunction) succesfully parsed to json : \(String(data: data, encoding: .utf8) ?? "nil")")
//            try data.write(to: url)
//            print("\(thisFunction) succesfully write data")
//        } catch let encodingError where encodingError is EncodingError{
//            print("\(thisFunction) cant encode to json because of \(encodingError.localizedDescription)")
//        } catch {
//            print("\(thisFunction) have some error: \(error)")
//        }
//    }
    
    init() {
//        if let url = Autosave.url, let data = try? EmojiArtModel(url: url){
//            emojiArt = data
//            fetchBackgroundImageDataIfNecessary()
//        }
//        else {
        emojiArt = EmojiArtModel()
//        }
        //        emojiArt.addEmoji("😀", at: (-200, -100), size: 80)
        //        emojiArt.addEmoji("😷", at: (50, 100), size: 40)
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    
    // MARK: - Background
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map{(data, urlResponse) in UIImage(data: data)}
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            backgroundImageFetchCancellable = publisher
                .sink(
                    receiveCompletion: {  result in
                        switch result {
                        case .finished:
                            print("success!")
                        case .failure(let error):
                            print("failed: error = : \(error)")
                        }
                    }, receiveValue: { [weak self] image in
                        self?.backgroundImage = image
                        self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                    }
                )
//                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
            
            
            //            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil {
//                            self?.backgroundImage = UIImage(data: imageData!)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set background", with: undoManager) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Add emoji \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func removeEmojiById(_ id: String, undoManager: UndoManager?) {
        let emoji = emojiArt.emojis.first(where: {$0.id == Int(id)})
        undoablyPerform(operation: "Remove emoji \(emoji?.text ?? "")", with: undoManager) {
            let id = Int(id)
            if id != nil {
                emojiArt.removeEmojiById(id!)
            }
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
        undoablyPerform(operation: "Move emoji \(emoji.text)", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func getEmoji(_ emoji: EmojiArtModel.Emoji) -> EmojiArtModel.Emoji? {
        if let index = emojiArt.emojis.index(matching: emoji) {
            return emojiArt.emojis[index]
        }
        return nil
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Scale emoji \(emoji.text)", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    
    //MARK: - Undo
    
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) {myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}
