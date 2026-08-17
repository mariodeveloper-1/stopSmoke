//
//  LogCigaretteView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 19/07/2026.
//

import SwiftUI

struct LogCigaretteView: View {
    // Riceviamo il ViewModel come stato modificabile per i binding
    @Bindable var viewModel: LogCigaretteViewModel
    
    // Il servizio dati in cui andremo a salvare la sigaretta
    let service: SmokingService
    
    // Environment di sistema per poter chiudere questa schermata (Bottom Sheet)
    @Environment(\.dismiss) private var dismiss
    
    // Definizione della griglia degli umori: 3 colonne flessibili
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Testo descrittivo dinamico basato sul livello di craving selezionato
    private var cravingDescription: String {
        switch viewModel.cravingIntensity {
        case 1: return "Lieve 😴 (Un pensiero passeggero)"
        case 2: return "Moderato 😬 (Desiderio gestibile)"
        case 3: return "Forte 🔥 (Difficile distrarsi)"
        case 4: return "Molto Forte 🥵 (Richiede grande forza di volontà)"
        case 5: return "Insopportabile 🌋 (Craving estremo)"
        default: return "Medio"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Sfondo scuro coerente con la Dashboard
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // SEZIONE 1: Intensità del Craving
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quanto è forte il desiderio?")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 8) {
                                Text(cravingDescription)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(viewModel.cravingIntensity >= 4 ? .red : .yellow)
                                
                                Slider(
                                    value: Binding(
                                        get: { Double(viewModel.cravingIntensity) },
                                        set: { viewModel.cravingIntensity = Int($0) }
                                    ),
                                    in: 1...5,
                                    step: 1
                                )
                                .tint(.red)
                                
                                HStack {
                                    Text("Lieve")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("Estremo")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                        
                        // SEZIONE 2: Selezione dell'Umore
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Qual è il tuo stato d'animo?")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(Mood.allCases) { mood in
                                    Button(action: {
                                        viewModel.selectedMood = mood
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(mood.emoji)
                                                .font(.system(size: 32))
                                            
                                            Text(mood.localizedName)
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .foregroundStyle(viewModel.selectedMood == mood ? .white : .secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            viewModel.selectedMood == mood
                                            ? Color.red.opacity(0.15)
                                            : Color.white.opacity(0.04)
                                        )
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    viewModel.selectedMood == mood ? Color.red : Color.white.opacity(0.06),
                                                    lineWidth: viewModel.selectedMood == mood ? 2 : 1
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        
                        // SEZIONE 3: Diario (Note Libere)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Diario (Cosa è successo?)")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                            
                            TextField("Scrivi qui la situazione, dove sei o cosa provi... (opzionale)", text: $viewModel.notesText, axis: .vertical)
                                .font(.system(.body, design: .rounded))
                                .lineLimit(3...6)
                                .padding()
                                .foregroundStyle(.white)
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        }
                        
                        // SEZIONE 4: Pulsante Salva in basso
                        Button(action: {
                            viewModel.save(in: service)
                            dismiss()
                        }) {
                            Text("Salva Sigaretta")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.red, Color(red: 0.8, green: 0.0, blue: 0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, y: 4)
                        }
                        .padding(.top, 16)
                        
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Nuovo Inserimento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annulla") {
                        viewModel.reset()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    LogCigaretteView(
        viewModel: LogCigaretteViewModel(),
        service: SmokingService.preview
    )
}
