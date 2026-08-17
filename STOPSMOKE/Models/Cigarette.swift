//
//  Cigarette.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 18/07/2026.
//

import Foundation

/// Rappresenta l'umore dell'utente al momento del log.
enum Mood: String, Codable, CaseIterable, Identifiable {
    case stressed
    case bored
    case anxious
    case social
    case happy
    case angry
    
    var id: Self { self }
    
    /// Nome visualizzato e localizzato nell'interfaccia utente (EN, IT, ES, FR).
    var localizedName: String {
        switch AppLanguage.current {
        case .english:
            switch self {
            case .stressed: return "Stressed"
            case .bored: return "Bored"
            case .anxious: return "Anxious"
            case .social: return "Socializing"
            case .happy: return "Happy"
            case .angry: return "Angry"
            }
        case .italian:
            switch self {
            case .stressed: return "Stressato"
            case .bored: return "Annoiato"
            case .anxious: return "Ansioso"
            case .social: return "In compagnia"
            case .happy: return "Felice"
            case .angry: return "Arrabbiato"
            }
        case .spanish:
            switch self {
            case .stressed: return "Estresado"
            case .bored: return "Aburrido"
            case .anxious: return "Ansioso"
            case .social: return "En compañía"
            case .happy: return "Feliz"
            case .angry: return "Enojado"
            }
        case .french:
            switch self {
            case .stressed: return "Stressé"
            case .bored: return "Ennuyé"
            case .anxious: return "Anxieux"
            case .social: return "En société"
            case .happy: return "Heureux"
            case .angry: return "En colère"
            }
        }
    }
    
    /// Emoji associata all'umore per una UX ricca e visiva.
    var emoji: String {
        switch self {
        case .stressed: return "😰"
        case .bored: return "🥱"
        case .anxious: return "😬"
        case .social: return "👥"
        case .happy: return "😊"
        case .angry: return "😡"
        }
    }
}

/// Il modello core che rappresenta una singola sigaretta registrata.
struct Cigarette: Identifiable, Codable {
    let id: UUID // Identificatore unico per la sigaretta
    let date: Date // Data e ora della sigaretta
    let cravingIntensity: Int // Valore da 1 a 5
    let mood: Mood // Umore associato alla sigaretta
    let notes: String? // Note aggiuntive sulla sigaretta
    
    /// Costruttore con valori di default per facilitare la creazione di nuove istanze.
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        cravingIntensity: Int,
        mood: Mood,
        notes: String? = nil //o stringa o nulla (scelta libera dall'utente)
    ) {
        self.id = id
        self.date = date
        self.cravingIntensity = max(1, min(cravingIntensity, 5)) // Garantisce che il valore sia tra 1 e 5
        self.mood = mood
        self.notes = notes
    }
}
