//
//  CigaretteDetailSheet.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 23/07/2026.
//

import SwiftUI

/// Bottom sheet per visualizzare il dettaglio completo di una sigaretta registrata.
struct CigaretteDetailSheet: View {
    let cigarette: Cigarette
    @Environment(\.dismiss) private var dismiss
    
    // Descrizione dell'intensità del craving
    private var cravingText: String {
        switch cigarette.cravingIntensity {
        case 1: return "Lieve (1/5)"
        case 2: return "Moderato (2/5)"
        case 3: return "Forte (3/5)"
        case 4: return "Molto Forte (4/5)"
        case 5: return "Insopportabile (5/5)"
        default: return "\(cigarette.cravingIntensity)/5"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header Umore & Emoji
                        VStack(spacing: 12) {
                            Text(cigarette.mood.emoji)
                                .font(.system(size: 64))
                                .padding()
                                .background(Color.white.opacity(0.04))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                                )
                            
                            VStack(spacing: 4) {
                                Text(cigarette.mood.localizedName)
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text(cigarette.date.formatted(date: .complete, time: .shortened))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 12)
                        
                        // Sezione Intensità Craving
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("INTENSITÀ DESIDERIO")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .tracking(1.0)
                                Spacer()
                                Text(cravingText)
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(cigarette.cravingIntensity >= 4 ? .red : .yellow)
                            }
                            
                            HStack(spacing: 6) {
                                ForEach(1...5, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(index <= cigarette.cravingIntensity ? Color.red : Color.white.opacity(0.12))
                                        .frame(height: 8)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                        
                        // Sezione Note del Diario
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DIARIO & NOTE")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .tracking(1.0)
                            
                            if let notes = cigarette.notes, !notes.isEmpty {
                                Text("\"\(notes)\"")
                                    .font(.system(.body, design: .rounded))
                                    .italic()
                                    .foregroundStyle(.white.opacity(0.9))
                                    .lineSpacing(4)
                            } else {
                                Text("Nessuna nota scritta per questa registrazione.")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .italic()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                        
                        // Card AI Insight Coach
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.red)
                                Text("ANALISI COACH AI")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(.red)
                                    .tracking(1.0)
                            }
                            
                            Text("Registrata per stato d'animo '\(cigarette.mood.localizedName)' con craving livello \(cigarette.cravingIntensity). Riconoscere i momenti di vulnerabilità è il primo passo per disinnescare l'automatismo.")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Dettaglio Registrazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    CigaretteDetailSheet(
        cigarette: Cigarette(
            cravingIntensity: 4,
            mood: .stressed,
            notes: "Fumata dopo una riunione difficile."
        )
    )
}
