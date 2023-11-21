//
//  DoubleTapToPopModifier.swift
//  Nos
//
//  Created by Martin Dutra on 21/8/23.
//

import Combine
import SwiftUI

/// Detects double taps on a tab item and pops the opened screens to return the user to the root view
struct DoubleTapToPopModifier: ViewModifier {

    var tab: AppDestination
    var onRoot: (@MainActor () -> Void)?

    @EnvironmentObject private var router: Router
    @State private var cancellable: AnyCancellable?

    func body(content: Content) -> some View {
        content.task {
            if cancellable == nil {
                cancellable = router.consecutiveTaps(on: tab)
                    .sink {
                        let path = router.path(for: tab)
                        if path.wrappedValue.isEmpty {
                            if let onRoot {
                                onRoot()
                            }
                        } else {
                            path.wrappedValue.removeLast(path.wrappedValue.count)
                        }
                    }
            }
        }
    }
}

extension View {
    @ViewBuilder func doubleTapToPop(
        tab: AppDestination,
        enabled: Bool = true,
        onRoot: (@MainActor () -> Void)? = nil
    ) -> some View {
        if enabled {
            self.modifier(DoubleTapToPopModifier(tab: tab, onRoot: onRoot))
        } else {
            self
        }
    }
}
