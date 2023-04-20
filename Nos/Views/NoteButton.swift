//
//  Notebutton.swift
//  Nos
//
//  Created by Jason Cheatham on 2/16/23.
//

import Foundation
import SwiftUI
import CoreData

/// This view displays the a button with the information we have for a note suitable for being used in a list
/// or grid.
///
/// The button opens the ThreadView for the note when tapped.
struct NoteButton: View {

    @State var note: Event?
    var noteID: HexadecimalString
    var style = CardStyle.compact
    var showFullMessage = false
    var hideOutOfNetwork = true
    var allowsPush = true
    var showReplyCount = true
    var isInThreadView = false

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var relayService: RelayService

    init(
        note: Event, 
        style: CardStyle = CardStyle.compact, 
        showFullMessage: Bool = false, 
        hideOutOfNetwork: Bool = true, 
        allowsPush: Bool = true, 
        showReplyCount: Bool = true, 
        isInThreadView: Bool = false
    ) {
        self.note = note
        self.noteID = note.identifier!
        self.style = style
        self.showFullMessage = showFullMessage
        self.hideOutOfNetwork = hideOutOfNetwork
        self.allowsPush = allowsPush
        self.showReplyCount = showReplyCount
        self.isInThreadView = isInThreadView
    }

    init(
        noteID: HexadecimalString, 
        style: CardStyle = CardStyle.compact, 
        showFullMessage: Bool = false, 
        hideOutOfNetwork: Bool = true, 
        allowsPush: Bool = true, 
        showReplyCount: Bool = true, 
        isInThreadView: Bool = false
    ) {
        self.noteID = noteID
        self.style = style
        self.showFullMessage = showFullMessage
        self.hideOutOfNetwork = hideOutOfNetwork
        self.allowsPush = allowsPush
        self.showReplyCount = showReplyCount
        self.isInThreadView = isInThreadView
    }

    var body: some View {
        Group {
            if let note {
                Button {
                    if allowsPush {
                        if !isInThreadView, let referencedNote = note.referencedNote() {
                            router.push(referencedNote)
                        } else {
                            router.push(note)
                        }
                    }
                } label: {
                    NoteCard(
                        note: note,
                        style: style,
                        showFullMessage: showFullMessage,
                        hideOutOfNetwork: hideOutOfNetwork,
                        showReplyCount: showReplyCount
                    )
                }
                .buttonStyle(CardButtonStyle())
            } else {
                Color.clear
                    .frame(minHeight: 800)
            }
        }
    }
}

struct NoteButton_Previews: PreviewProvider {
   
    static var persistenceController = PersistenceController.preview
    static var previewContext = persistenceController.container.viewContext
    static var router = Router()
    static var shortNote: Event {
        let note = Event(context: previewContext)
        note.content = "Hello, world!"
        return note
    }
    
    static var longNote: Event {
        let note = Event(context: previewContext)
        note.content = .loremIpsum(5)
        let author = Author(context: previewContext)
        // TODO: derive from private key
        author.hexadecimalPublicKey = "32730e9dfcab797caf8380d096e548d9ef98f3af3000542f9271a91a9e3b0001"
        note.author = author
        return note
    }
    
    static var previews: some View {
        Group {
            NoteButton(note: shortNote)
            NoteButton(note: shortNote, style: .golden)
            NoteButton(note: longNote)
                .preferredColorScheme(.dark)
        }
        .environmentObject(router)
    }
}
