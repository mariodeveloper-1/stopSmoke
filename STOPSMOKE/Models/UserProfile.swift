//
//  UserProfile.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 19/07/2026.
//

import Foundation

/// Rappresenta il profilo e le abitudini passate dell'utente per effettuare i calcoli di risparmio.
struct UserProfile: Codable {
    /// Media di sigarette fumate al giorno prima di smettere.
    var dailyAverage: Int
    
    /// Costo medio di un pacchetto di sigarette.
    var packPrice: Double
    
    /// Numero di sigarette contenute in un pacchetto (di solito 20).
    var packSize: Int
    
    /// Data di inizio del percorso per smettere di fumare.
    var startDate: Date
    
    /// Inizializzatore con valori di default realistici.
    init(
        dailyAverage: Int = 15,
        packPrice: Double = 6.00,
        packSize: Int = 20,
        startDate: Date = Date()
    ) {
        self.dailyAverage = max(1, dailyAverage)
        self.packPrice = max(0.0, packPrice)
        self.packSize = max(1, packSize)
        self.startDate = startDate
    }
}
