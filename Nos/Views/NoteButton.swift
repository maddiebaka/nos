//
//  Notebutton.swift
//  Nos
//
//  Created by Jason Cheatham on 2/16/23.
//

import Foundation
import SwiftUI
import CoreData
import Dependencies

/// This view displays the a button with the information we have for a note suitable for being used in a list
/// or grid.
///
/// The button opens the ThreadView for the note when tapped.
struct NoteButton: View {

    @ObservedObject var note: Event
    var style = CardStyle.compact
    var showFullMessage = false
    var hideOutOfNetwork = true
    var showReplyCount = true
    var displayRootMessage = false
    var isTapEnabled = true
    private let replyAction: ((Event) -> Void)?
    private let tapAction: ((Event) -> Void)?

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var relayService: RelayService
    @Dependency(\.persistenceController) private var persistenceController
    
    @State private var subscriptionIDs = [RelaySubscription.ID]()

    init(
        note: Event, 
        style: CardStyle = CardStyle.compact, 
        showFullMessage: Bool = false, 
        hideOutOfNetwork: Bool = true, 
        showReplyCount: Bool = true, 
        displayRootMessage: Bool = false,
        isTapEnabled: Bool = true,
        replyAction: ((Event) -> Void)? = nil,
        tapAction: ((Event) -> Void)? = nil
    ) {
        self.note = note
        self.style = style
        self.showFullMessage = showFullMessage
        self.hideOutOfNetwork = hideOutOfNetwork
        self.showReplyCount = showReplyCount
        self.displayRootMessage = displayRootMessage
        self.isTapEnabled = isTapEnabled
        self.replyAction = replyAction
        self.tapAction = tapAction
    }

    /// The note displayed in the note card. Could be different from `note` i.e. in the case of a repost.
    var displayedNote: Event {
        if note.kind == EventKind.repost.rawValue,
            let repostedNote = note.repostedNote() {
            return repostedNote
        } else {
            return note
        }
    }

    var body: some View {
        VStack {
            if note.kind == EventKind.repost.rawValue, let author = note.author {
                let repost = note
                Button(action: { 
                    router.push(author)
                }, label: { 
                    HStack(alignment: .center) {
                        AuthorLabel(author: author)
                        Image.repostSymbol
                        if let elapsedTime = repost.createdAt?.distanceString() {
                            Text(elapsedTime)
                                .lineLimit(1)
                                .font(.body)
                                .foregroundColor(.secondaryTxt)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .readabilityPadding()
                    .onAppear {
                        Task(priority: .userInitiated) {
                            await subscriptionIDs += Event.requestAuthorsMetadataIfNeeded(
                                noteID: note.identifier,
                                using: relayService,
                                in: persistenceController.backgroundViewContext
                            )
                        }
                    }
                    .onDisappear {
                        Task(priority: .userInitiated) {
                            await relayService.decrementSubscriptionCount(for: subscriptionIDs)
                            subscriptionIDs.removeAll()
                        }
                    }
                })
            }
            
            let buttonLabel = NoteCard(
                note: displayedNote,
                style: style,
                showFullMessage: showFullMessage,
                hideOutOfNetwork: hideOutOfNetwork,
                showReplyCount: showReplyCount,
                replyAction: replyAction
            )

            let button = Button {
                if let tapAction {
                    tapAction(displayedNote)
                } else {
                    if let referencedNote = displayedNote.referencedNote() {
                        router.push(referencedNote)
                    } else {
                        router.push(displayedNote)
                    }
                }
            } label: {
                buttonLabel
            }
            .buttonStyle(CardButtonStyle(style: style))

            let buttonOrLabel = Group {
                if isTapEnabled {
                    button
                } else {
                    buttonLabel
                        .mimicCardButtonStyle()
                }
            }

            switch style {
            case .compact:
                let compactButtonOrLabel = buttonOrLabel
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .readabilityPadding()
                
                if displayRootMessage, 
                    note.kind != EventKind.repost.rawValue,
                    let root = note.rootNote() ?? note.referencedNote() {
                    
                    ThreadRootView(
                        root: root, 
                        tapAction: { root in router.push(root) },
                        reply: { compactButtonOrLabel }
                    )
                } else {
                    compactButtonOrLabel
                }
            case .golden:
                buttonOrLabel
            }
        }
    }
}

struct NoteButton_Previews: PreviewProvider {
    
    static var previewData = PreviewData()
    static var previews: some View {
        ScrollView {
            VStack {
                NoteButton(note: previewData.repost, hideOutOfNetwork: false)
                NoteButton(note: previewData.shortNote)
                NoteButton(note: previewData.longNote)
                NoteButton(note: previewData.reply, hideOutOfNetwork: false, displayRootMessage: true)
                NoteButton(note: previewData.doubleImageNote)
            }
        }
        .background(Color.appBg)
        .inject(previewData: previewData)
    }
}
