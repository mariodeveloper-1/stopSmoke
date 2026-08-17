//
//  LogCigaretteViewModel.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 19/07/2026.
//

import Foundation
import Observation

/// ViewModel per la schermata di inserimento sigaretta.
/// Gestisce lo stato temporaneo dell'input inserito dall'utente prima del salvataggio.
@Observable
class LogCigaretteViewModel {
    
    /// Intensità del desiderio (valore iniziale di default: 3 su 5).
    var cravingIntensity: Int = 3
    
    /// Umore associato (valore iniziale di default: .stressed).
    var selectedMood: Mood = .stressed
    
    /// Testo libero del diario inserito dall'utente.
    var notesText: String = ""
    
    /// Salva la sigaretta registrata nel servizio centrale.
    /// - Parameter service: Il servizio di persistenza o gestione dati in cui salvare.
    func save(in service: SmokingService) {
        // Rimuoviamo gli spazi vuoti e gli a capo all'inizio/fine del testo
        let trimmedNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Se l'utente non ha scritto nulla, salviamo nil invece di una stringa vuota
        let notesToSave = trimmedNotes.isEmpty ? nil : trimmedNotes
        
        // Salvataggio nel servizio centrale
        service.addCigarette(
            cravingIntensity: cravingIntensity,
            mood: selectedMood,
            notes: notesToSave
        )
        
        // Pulizia dello stato del ViewModel per il log successivo
        reset()
    }
    
    /// Resetta il ViewModel allo stato iniziale per evitare sovrapposizioni di dati futuri.
    func reset() {
        cravingIntensity = 3
        selectedMood = .stressed
        notesText = ""
    }
}
