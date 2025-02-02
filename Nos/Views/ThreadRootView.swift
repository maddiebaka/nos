//
//  ThreadRootView.swift
//  Nos - This is the root note card for threads.
//
//  Created by Rabble on 10/16/23.
//

import SwiftUI

struct ThreadRootView<Reply: View>: View {
    var root: Event
    var tapAction: ((Event) -> Void)?
    var reply: Reply
    
    var thread: [Event] = []
    
    @EnvironmentObject private var router: Router
    
    init(root: Event, tapAction: ((Event) -> Void)?, @ViewBuilder reply: () -> Reply) {
        self.root = root
        self.tapAction = tapAction
        self.reply = reply()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            NoteButton(note: root, showFullMessage: false, hideOutOfNetwork: false, tapAction: tapAction)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .opacity(0.7)
                .frame(height: 100, alignment: .top)
                .clipped()

            reply
                .offset(y: 100)
                .padding(
                    EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 0)
                )
        }
    }
}

struct ThreadRootView_Previews: PreviewProvider {
    static var previewData = PreviewData()
    
    static var previews: some View {
        ScrollView {
            VStack {
                ThreadRootView(
                    root: previewData.longNote, 
                    tapAction: { _ in },
                    reply: { EmptyView() } 
                )
            }
        }
        .background(Color.appBg)
        .inject(previewData: previewData)
    }
}
