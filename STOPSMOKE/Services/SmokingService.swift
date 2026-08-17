//
//  SmokingService.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 19/07/2026.
//

import Foundation
import Observation

/// Servizio che gestisce i dati delle sigarette (Single Source of Truth).
/// Utilizza la macro `@Observable` per notificare automaticamente le viste SwiftUI al variare dei dati.
@Observable
class SmokingService {
    
    /// Array di sigarette registrate.
    /// Accessibile in lettura da tutta l'app, ma modificabile solo internamente per garantire l'integrità dei dati.
    private(set) var cigarettes: [Cigarette] = []
    
    /// Profilo di abitudini e data di inizio del percorso dell'utente (parte dal giorno dell'installazione).
    var userProfile = UserProfile(
        dailyAverage: 15,
        packPrice: 6.00,
        packSize: 20,
        startDate: Date()
    )
    
    init(initialCigarettes: [Cigarette] = []) {
        self.cigarettes = initialCigarettes
    }
    
    /// Calcola il numero di sigarette evitate dall'inizio del percorso.
    func avoidedCigarettesCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        // Calcola i giorni totali di percorso (minimo 1)
        let components = calendar.dateComponents([.day], from: userProfile.startDate, to: now)
        let days = max(1, (components.day ?? 0) + 1)
        
        // Calcolo teorico di quante sigarette avrebbe fumato l'utente
        let theoreticalCigarettes = days * userProfile.dailyAverage
        
        // Conta quante ne ha effettivamente fumate (registrate nell'app dopo la data di inizio)
        let loggedCigarettes = cigarettes.filter { $0.date >= userProfile.startDate }.count
        
        // La differenza è il risparmio in sigarette (non può essere inferiore a zero)
        return max(0, theoreticalCigarettes - loggedCigarettes)
    }
    
    /// Calcola il totale del denaro risparmiato in base alle sigarette evitate.
    func savedMoney() -> Double {
        let avoided = avoidedCigarettesCount()
        let singleCigaretteCost = userProfile.packPrice / Double(userProfile.packSize)
        return Double(avoided) * singleCigaretteCost
    }
    
    /// Calcola le sigarette evitate NELLA GIORNATA DI OGGI rispetto alla media giornaliera.
    func todayAvoidedCigarettesCount() -> Int {
        let avoided = userProfile.dailyAverage - cigarettesTodayCount
        return max(0, avoided)
    }
    
    /// Calcola il denaro risparmiato NELLA GIORNATA DI OGGI.
    func todaySavedMoney() -> Double {
        let singleCigaretteCost = userProfile.packPrice / Double(userProfile.packSize)
        return Double(todayAvoidedCigarettesCount()) * singleCigaretteCost
    }
    
    /// Registra una nuova sigaretta.
    /// - Parameters:
    ///   - cravingIntensity: Intensità del desiderio (1-5).
    ///   - mood: Umore associato.
    ///   - notes: Note facoltative scritte dall'utente.
    func addCigarette(cravingIntensity: Int, mood: Mood, notes: String?) {
        let newCigarette = Cigarette(
            cravingIntensity: cravingIntensity,
            mood: mood,
            notes: notes
        )
        cigarettes.append(newCigarette)
        
        // Ordiniamo le sigarette per data decrescente (la più recente per prima)
        // per facilitare i calcoli successivi.
        cigarettes.sort { $0.date > $1.date }
    }
    
    /// Calcola il numero totale di sigarette fumate nella giornata di oggi.
    var cigarettesTodayCount: Int {
        cigarettes.filter { Calendar.current.isDateInToday($0.date) }.count
    }
    
    /// Data e ora dell'ultima sigaretta registrata.
    var lastCigaretteDate: Date? {
        // Poiché abbiamo ordinato l'array in ordine decrescente, la prima è la più recente.
        cigarettes.first?.date
    }
    
    // MARK: - Nuove Statistiche Avanzate (Intervallo & Medie)
    
    /// Calcola il tempo medio trascorso tra una sigaretta e l'altra (in secondi).
    /// Calcolato sulla differenza di orario tra registrazioni consecutive nello stesso giorno o percorso.
    func averageTimeIntervalBetweenCigarettes() -> TimeInterval? {
        guard cigarettes.count >= 2 else { return nil }
        
        // Ordina in ordine cronologico crescente (dal passato al presente)
        let sorted = cigarettes.sorted { $0.date < $1.date }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sorted.count {
            let diff = sorted[i].date.timeIntervalSince(sorted[i-1].date)
            // Consideriamo intervalli validi tra 5 minuti e 16 ore per evitare distorsioni da nottate
            if diff >= 300 && diff <= 57600 {
                intervals.append(diff)
            }
        }
        
        guard !intervals.isEmpty else { return nil }
        let total = intervals.reduce(0, +)
        return total / Double(intervals.count)
    }
    
    /// Calcola la media di sigarette fumate a settimana nelle ultime 4 settimane.
    func weeklyCigarettesAverage() -> Double {
        let calendar = Calendar.current
        let now = Date()
        guard let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: now) else { return 0 }
        
        let count = cigarettes.filter { $0.date >= fourWeeksAgo }.count
        // Se l'utente ha registrato da meno di 28 giorni, dividi per le settimane effettive trascorse
        let daysActive = max(1, calendar.dateComponents([.day], from: userProfile.startDate, to: now).day ?? 1)
        let weeksActive = max(1.0, Double(daysActive) / 7.0)
        
        return Double(count) / weeksActive
    }
    
    /// Calcola la media di sigarette fumate al mese.
    func monthlyCigarettesAverage() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let daysActive = max(1, calendar.dateComponents([.day], from: userProfile.startDate, to: now).day ?? 1)
        let monthsActive = max(1.0, Double(daysActive) / 30.0)
        
        let totalCount = cigarettes.count
        return Double(totalCount) / monthsActive
    }
}

// MARK: - Preview Support
extension SmokingService {
    /// Istanza mock pre-popolata da utilizzare nelle Preview di SwiftUI con 4 settimane di dati storici.
    static var preview: SmokingService {
        var mockCigarettes: [Cigarette] = []
        let calendar = Calendar.current
        let now = Date()
        
        // Simula 4 settimane di dati progressivi per mostrare l'andamento in calo
        // Settimana 4 fa (28-21 giorni fa): 12 sig/giorno
        // Settimana 3 fa (21-14 giorni fa): 9 sig/giorno
        // Settimana 2 fa (14-7 giorni fa): 6 sig/giorno
        // Settimana 1 fa (ultimi 7 giorni): 3 sig/giorno
        
        for dayAgo in 1...28 {
            guard let date = calendar.date(byAdding: .day, value: -dayAgo, to: now) else { continue }
            let dailyCount: Int
            if dayAgo > 21 { dailyCount = 12 }
            else if dayAgo > 14 { dailyCount = 9 }
            else if dayAgo > 7 { dailyCount = 6 }
            else { dailyCount = 3 }
            
            for hourOffset in stride(from: 8, to: 8 + (dailyCount * 1), by: 1) {
                if let cigDate = calendar.date(byAdding: .hour, value: hourOffset, to: date) {
                    mockCigarettes.append(
                        Cigarette(
                            date: cigDate,
                            cravingIntensity: Int.random(in: 2...4),
                            mood: Mood.allCases.randomElement() ?? .stressed,
                            notes: hourOffset % 3 == 0 ? "Sigaretta di controllo" : nil
                        )
                    )
                }
            }
        }
        
        let service = SmokingService(initialCigarettes: mockCigarettes)
        // Data di inizio 30 giorni fa per sbloccare le statistiche settimanali e mensili
        service.userProfile = UserProfile(
            dailyAverage: 15,
            packPrice: 6.00,
            packSize: 20,
            startDate: calendar.date(byAdding: .day, value: -30, to: now) ?? now
        )
        return service
    }
}
