//
//  Router.swift
//  Nos
//
//  Created by Jason Cheatham on 2/21/23.
//

import SwiftUI
import CoreData
import Logger

// Manages the app's navigation state.
class Router: ObservableObject {
    
    @Published var homeFeedPath = NavigationPath()
    @Published var discoverPath = NavigationPath()
    @Published var notificationsPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    @Published var sideMenuPath = NavigationPath()
    @Published var selectedTab = AppView.Destination.home
    
    var currentPath: Binding<NavigationPath> {
        if sideMenuOpened {
            return Binding(get: { self.sideMenuPath }, set: { self.sideMenuPath = $0 })
        }
        
        switch selectedTab {
        case .home:
            return Binding(get: { self.homeFeedPath }, set: { self.homeFeedPath = $0 })
        case .discover:
            return Binding(get: { self.discoverPath }, set: { self.discoverPath = $0 })
        case .newNote:
            return Binding(get: { self.homeFeedPath }, set: { self.homeFeedPath = $0 })
        case .notifications:
            return Binding(get: { self.notificationsPath }, set: { self.notificationsPath = $0 })
        case .profile:
            return Binding(get: { self.profilePath }, set: { self.profilePath = $0 })
        }
    }
    
    @Published var userNpubPublicKey = ""
    
    @Published private(set) var sideMenuOpened = false

    /// Set when a profile is viewed
    @Published var viewedAuthor: Author?

    func toggleSideMenu() {
        withAnimation(.easeIn(duration: 0.2)) {
            sideMenuOpened.toggle()
        }
    }
    
    func closeSideMenu() {
        withAnimation(.easeIn(duration: 0.2)) {
            sideMenuOpened = false
        }
    }
    
    /// Pushes the given destination item onto the current NavigationPath.
    @MainActor func push<D: Hashable>(_ destination: D) {
        currentPath.wrappedValue.append(destination)
    }
    
    func pop() {
        currentPath.wrappedValue.removeLast()
    }
}

extension Router {
    
    @MainActor func open(url: URL, with context: NSManagedObjectContext) {
        let link = url.absoluteString
        let identifier = String(link[link.index(after: link.startIndex)...])
        // handle mentions. mention link will be prefixed with "@" followed by
        // the hex format pubkey of the mentioned author
        do {
            if link.hasPrefix("@") {
                push(try Author.findOrCreate(by: identifier, context: context))
            } else if link.hasPrefix("%") {
                push(try Event.findOrCreateStubBy(id: identifier, context: context))
            } else if url.scheme == "http" || url.scheme == "https" {
                push(url)
            } else {
                UIApplication.shared.open(url)
            }
        } catch {
            Log.optional(error)
        }
    }
}
