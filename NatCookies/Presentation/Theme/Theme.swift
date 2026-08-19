//
//  Theme.swift
//  NatCookies
//

import SwiftUI

extension Color {
    static let natCream = Color(red: 250/255, green: 246/255, blue: 240/255)
    static let natEspresso = Color(red: 74/255, green: 46/255, blue: 27/255)
    static let natGold = Color(red: 212/255, green: 163/255, blue: 115/255)
    static let natPeach = Color(red: 232/255, green: 200/255, blue: 166/255)
    static let natSage = Color(red: 124/255, green: 154/255, blue: 122/255)
    static let natRose = Color(red: 201/255, green: 125/255, blue: 125/255)
    static let natMutedText = Color(red: 120/255, green: 100/255, blue: 90/255)
}

struct NatCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.natEspresso.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func natCard() -> some View {
        self.modifier(NatCardStyle())
    }
}
