//
//  DiscoverGrid.swift
//  Nos
//
//  Created by Matthew Lorentz on 3/16/23.
//

import SwiftUI

struct DiscoverGrid: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: Router
    @FetchRequest(fetchRequest: Event.emptyDiscoverRequest()) var events: FetchedResults<Event>
    @ObservedObject var searchController: SearchController
    
    @Binding var columns: Int
    @State private var gridSize: CGSize = .zero {
        didSet {
            // Initialize columns based on width of the grid
            if columns == 0, gridSize.width > 0 {
                columns = Int(floor(gridSize.width / 172))
            }
        }
    }
    
    @Namespace private var animation

    init(predicate: NSPredicate, searchController: SearchController, columns: Binding<Int>) {
        let fetchRequest = Event.emptyDiscoverRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1000
        _events = FetchRequest(fetchRequest: fetchRequest)
        _columns = columns
        self.searchController = searchController
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                Group {
                    if searchController.query.isEmpty {
                        StaggeredGrid(list: events, columns: columns, spacing: 15) { note in
                            NoteButton(note: note, style: .golden)
                                .padding(.bottom, 5)
                                .matchedGeometryEffect(id: note.identifier, in: animation)
                                .id(note.id)
                        }
                        .doubleTapToPop(tab: .discover) { proxy in
                            if let firstNote = events.first {
                                proxy.scrollTo(firstNote.id)
                            }
                        }
                    } else {
                        // Search results
                        if searchController.authorSuggestions.isEmpty {
                            FullscreenProgressView(isPresented: .constant(true))
                        } else {
                            ScrollView {
                                LazyVStack {
                                    ForEach(searchController.authorSuggestions) { author in
                                        AuthorCard(author: author) { 
                                            router.push(author)
                                        }
                                        .padding(.horizontal, 15)
                                        .padding(.top, 10)
                                        .readabilityPadding()
                                    }
                                }
                                .padding(.top, 5)
                            }
                            .doubleTapToPop(tab: .discover) { proxy in
                                if let firstAuthor = searchController.authorSuggestions.first {
                                    proxy.scrollTo(firstAuthor.id)
                                }
                            }
                        }
                    }
                }
                .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
            .onPreferenceChange(SizePreferenceKey.self) { preference in
                gridSize = preference
            }
        }
    }
}
