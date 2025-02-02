//
//  LinearGradient+Planetary.swift
//  Planetary
//
//  Created by Matthew Lorentz on 7/20/22.
//  Copyright © 2022 Verse Communications Inc. All rights reserved.
//

import SwiftUI

extension LinearGradient {
    
    public static let horizontalAccent = LinearGradient(
        colors: [ Color(hex: "#F08508"), Color(hex: "#F43F75")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    public static let diagonalAccent = LinearGradient(
        colors: [ Color(hex: "#F08508"), Color(hex: "#F43F75")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let verticalAccent = LinearGradient(
        colors: [ Color(hex: "#F08508"), Color(hex: "#F43F75")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    public static let solidBlack = LinearGradient(
        colors: [Color.black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardGradient = LinearGradient(
        colors: [Color.cardBgTop, Color.cardBgBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let cardBackground = LinearGradient(
        colors: [.cardBgTop, .cardBgBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let storiesBackground = LinearGradient(
        colors: [.storiesBgTop, .storiesBgBottom],
        startPoint: .top,
        endPoint: .bottom
    )
    
    public static let gold = LinearGradient(
        colors: [Color(hex: "#FFC46B"), Color(hex: "#DE7C21")],
        startPoint: .top,
        endPoint: .bottom
    )
}
