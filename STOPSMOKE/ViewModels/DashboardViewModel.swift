//
//  DashboardViewModel.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 19/07/2026.
//

import Foundation
import Observation

/// Struttura dati d'appoggio per popolare il grafico dell'andamento giornaliero.
struct DailyUsageChartData: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "E"
        return formatter.string(from: date).capitalized
    }
}

/// Dati per il grafico dell'andamento delle medie settimanali/mensili.
struct PeriodTrendData: Identifiable {
    let id = UUID()
    let periodName: String
    let averageDailyCount: Double
    let totalCount: Int
}

/// Dati per il grafico dell'intervallo medio tra sigarette.
struct IntervalTrendData: Identifiable {
    let id = UUID()
    let dayLabel: String
    let intervalHours: Double
}

/// ViewModel per la Dashboard principale. 
/// Collega il `SmokingService` alla vista ed elabora le informazioni in tempo reale (come il timer).
@Observable
class DashboardViewModel {
    
    /// Il servizio dati di riferimento.
    let service: SmokingService
    
    /// Stringa formattata che rappresenta il tempo trascorso dall'ultima sigaretta.
    /// Esempio: "02:15:30" o "1g 4h" se supera le 24 ore.
    var timeElapsedText: String = "--:--:--"
    
    /// Timer interno che aggiorna il conteggio ogni secondo.
    private var timer: Timer?
    
    /// Formatter per formattare intervalli di tempo inferiori alle 24 ore in formato HH:mm:ss.
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    /// Formatter per intervalli di tempo superiori alle 24 ore (es. "1g 4o").
    private let longTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    init(service: SmokingService) {
        self.service = service
        startTimer()
    }
    
    // MARK: - Nuove Proprietà Statistiche Avanzate
    
    /// Formatta l'intervallo medio tra una sigaretta e l'altra (es. "2h 15m" o "45 min").
    var averageTimeBetweenCigarettesText: String {
        guard let interval = service.averageTimeIntervalBetweenCigarettes() else {
            return "--"
        }
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    /// Media sigarette a settimana formattata.
    var weeklyAverageText: String {
        let avg = service.weeklyCigarettesAverage()
        return String(format: "%.1f", avg)
    }
    
    /// Media sigarette al mese formattata.
    var monthlyAverageText: String {
        let avg = service.monthlyCigarettesAverage()
        return String(format: "%.0f", avg)
    }
    
    /// Indica se sono trascorsi abbastanza giorni (almeno 7-14) per dati storici pluri-settimanali.
    var isLongTermDataAvailable: Bool {
        let daysActive = Calendar.current.dateComponents([.day], from: service.userProfile.startDate, to: Date()).day ?? 0
        return daysActive >= 7 || service.cigarettes.count >= 10
    }
    
    /// Dati per il grafico delle medie settimanali nelle ultime 4 settimane.
    var weeklyTrendsChartData: [PeriodTrendData] {
        let calendar = Calendar.current
        let now = Date()
        var result: [PeriodTrendData] = []
        
        for weekIndex in (0..<4).reversed() {
            guard let startDate = calendar.date(byAdding: .day, value: -(weekIndex + 1) * 7, to: now),
                  let endDate = calendar.date(byAdding: .day, value: -weekIndex * 7, to: now) else { continue }
            
            let count = service.cigarettes.filter { $0.date >= startDate && $0.date < endDate }.count
            let avgDaily = Double(count) / 7.0
            
            let label: String
            if weekIndex == 0 {
                label = Localization.language == .italian ? "Questa sett." : "This week"
            } else {
                label = Localization.language == .italian ? "\(weekIndex) sett. fa" : "\(weekIndex)w ago"
            }
            result.append(PeriodTrendData(periodName: label, averageDailyCount: avgDaily, totalCount: count))
        }
        
        return result
    }
    
    /// Dati per il grafico dell'intervallo medio tra sigarette negli ultimi 7 giorni.
    var intervalTrendChartData: [IntervalTrendData] {
        let calendar = Calendar.current
        let now = Date()
        var result: [IntervalTrendData] = []
        
        for dayIndex in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayIndex, to: now) else { continue }
            let dayCigarettes = service.cigarettes.filter { calendar.isDate($0.date, inSameDayAs: date) }.sorted { $0.date < $1.date }
            
            var intervals: [TimeInterval] = []
            if dayCigarettes.count >= 2 {
                for i in 1..<dayCigarettes.count {
                    let diff = dayCigarettes[i].date.timeIntervalSince(dayCigarettes[i-1].date)
                    if diff >= 300 && diff <= 57600 {
                        intervals.append(diff)
                    }
                }
            }
            
            let avgHours: Double
            if !intervals.isEmpty {
                avgHours = (intervals.reduce(0, +) / Double(intervals.count)) / 3600.0
            } else {
                avgHours = 0.0
            }
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: Locale.current.identifier)
            formatter.dateFormat = "E"
            let label = formatter.string(from: date).capitalized
            
            result.append(IntervalTrendData(dayLabel: label, intervalHours: avgHours))
        }
        
        return result
    }
    
    /// Restituisce il numero totale di sigarette fumate oggi.
    var cigarettesTodayCount: Int {
        service.cigarettesTodayCount
    }
    
    /// Restituisce le ultime 3 sigarette registrate oggi.
    var recentCigarettesToday: [Cigarette] {
        let todayCigarettes = service.cigarettes.filter { Calendar.current.isDateInToday($0.date) }
        return Array(todayCigarettes.prefix(3))
    }
    
    /// Calcola i giorni passati dall'ultima sigaretta fumata.
    /// Se non è mai stata registrata alcuna sigaretta, restituisce 1 (considerando che l'utente è al giorno 1 del percorso).
    var daysSinceLastCigarette: Int {
        guard let lastDate = service.lastCigaretteDate else {
            return 1
        }
        let now = Date()
        let components = Calendar.current.dateComponents([.day], from: lastDate, to: now)
        return (components.day ?? 0) + 1
    }
    
    /// Indica se i benefici di salute sono attivi o se sono stati resettati a causa di una sigaretta oggi.
    var isBenefitActive: Bool {
        cigarettesTodayCount == 0
    }
    
    /// Titolo della card dei benefici di salute.
    var motivationalBenefitTitle: String {
        if isBenefitActive {
            return Localization.daySmokeFreeTitle(days: daysSinceLastCigarette)
        } else {
            return Localization.benefitsResetTitle
        }
    }
    
    /// Restituisce il beneficio di salute corrispondente ai giorni trascorsi dall'ultima sigaretta.
    var motivationalBenefitText: String {
        if !isBenefitActive {
            return Localization.benefitsResetWarningText
        }
        return Localization.motivationalText(forDays: daysSinceLastCigarette)
    }
    
    /// Restituisce il numero di sigarette evitate formattato come stringa.
    var avoidedCigarettesText: String {
        "\(service.avoidedCigarettesCount())"
    }
    
    /// Restituisce il denaro totale risparmiato formattato come valuta locale (EUR).
    var savedMoneyText: String {
        service.savedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
    }
    
    /// Media giornaliera di sigarette dichiarata nel profilo.
    var dailyAverage: Int {
        service.userProfile.dailyAverage
    }
    
    /// Sigarette evitate nella giornata di oggi rispetto alla media giornaliera.
    var todayAvoidedCount: Int {
        service.todayAvoidedCigarettesCount()
    }
    
    /// Denaro risparmiato nella giornata di oggi formattato.
    var todaySavedMoneyText: String {
        service.todaySavedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
    }
    
    /// Riepilogo comparativo per la giornata di oggi.
    var todayComparisonSummaryText: String {
        Localization.todaySummaryText(
            count: cigarettesTodayCount,
            avg: dailyAverage,
            avoided: todayAvoidedCount,
            savedMoneyText: todaySavedMoneyText
        )
    }
    
    /// Restituisce i dati pronti per popolare il grafico degli ultimi 7 giorni
    var weeklyChartData: [DailyUsageChartData] {
        var data: [DailyUsageChartData] = []
        let calendar = Calendar.current
        let now = Date()
        
        // Generiamo i dati degli ultimi 7 giorni in ordine cronologico
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                // Filtriamo le sigarette fumate in quel giorno specifico
                let count = service.cigarettes.filter { cigarette in
                    calendar.isDate(cigarette.date, inSameDayAs: date)
                }.count
                data.append(DailyUsageChartData(date: date, count: count))
            }
        }
        return data
    }
    
    /// Registra una sigaretta e forza l'azzeramento del timer.
    func logCigarette(cravingIntensity: Int, mood: Mood, notes: String?) {
        service.addCigarette(cravingIntensity: cravingIntensity, mood: mood, notes: notes)
        updateTimer()
    }
    
    /// Avvia il timer di aggiornamento periodico.
    func startTimer() {
        // Evitiamo duplicazioni di timer invalidando quello esistente.
        timer?.invalidate()
        
        // Eseguiamo un primo aggiornamento immediato per non avere un ritardo di 1 secondo all'avvio.
        updateTimer()
        
        // Creiamo il timer che si ripete ogni secondo sul RunLoop principale.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    /// Ferma il timer per liberare memoria.
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Calcola la differenza di tempo e aggiorna la stringa visibile nella UI.
    private func updateTimer() {
        guard let lastDate = service.lastCigaretteDate else {
            timeElapsedText = "Nessuna"
            return
        }
        
        let now = Date()
        let interval = now.timeIntervalSince(lastDate)
        
        // Gestione di eventuali disallineamenti dell'orologio di sistema.
        if interval < 0 {
            timeElapsedText = "00:00:00"
            return
        }
        
        // Se è trascorso più di un giorno (86400 secondi), usiamo il formatter abbreviato (es. 1d 4h).
        if interval >= 86400 {
            timeElapsedText = longTimeFormatter.string(from: interval) ?? "1g+"
        } else {
            timeElapsedText = timeFormatter.string(from: interval) ?? "00:00:00"
        }
    }
    
    deinit {
        stopTimer()
    }
}
