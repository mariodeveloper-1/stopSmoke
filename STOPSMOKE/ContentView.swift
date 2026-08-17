//
//  ContentView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 18/07/2026.
//

import SwiftUI

struct ContentView: View {
    // Sorgente unica della verità per lo stato dell'applicazione
    @State private var smokingService = SmokingService()
    
    var body: some View {
        // Carichiamo la TabBar principale a 3 schede (Statistiche | Dashboard | Coach AI)
        MainTabView(service: smokingService)
    }
}

#Preview {
    ContentView()
}
