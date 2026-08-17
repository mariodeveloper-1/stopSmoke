//
//  DashboardView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 19/07/2026.
//

import SwiftUI

struct DashboardView: View {
    // Riceviamo il ViewModel come stato osservabile
    @State var viewModel: DashboardViewModel
    
    // Stato per la visibilità della bottom sheet di log
    @State private var isShowingLogSheet = false
    
    var body: some View {
        ZStack {
            // Sfondo scuro premium con un gradiente radiale sottile per dare profondità
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            // Un cerchio sfocato sullo sfondo per un effetto "neon glow" moderno
            RadialGradient(
                colors: [Color.red.opacity(0.12), Color.clear],
                center: .center,
                startRadius: 10,
                endRadius: 350
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Header (Fisso in alto)
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                
                // 2. Area Centrale Scorrevole
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Sezione centrale: Il Timer
                        timerSection
                        
                        // Card Comparativa Giornaliera (Richiesta specifica: confronto media, sigarette in meno e soldi del giorno)
                        dailyComparisonCard
                        
                        // Sezione Dinamica: Benefici della salute
                        healthBenefitsCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)
                }
                
                // 3. Pulsante d'azione Rosso (Fisso in alto rispetto allo slider per evitare sovrapposizioni)
                buttonSection
                    .padding(.bottom, 90)
            }
            .sheet(isPresented: $isShowingLogSheet) {
                LogCigaretteView(
                    viewModel: LogCigaretteViewModel(),
                    service: viewModel.service
                )
            }
        }
    }
}

// MARK: - Componenti Grafici Secondari (Subviews)
private extension DashboardView {
    
    /// Header principale della dashboard
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("STOP SMOKE")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.red.opacity(0.8))
                    .tracking(2.0)
                
                Text("AI Smoking Coach")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            Spacer()
            
            // Un indicatore premium per indicare il piano attivo
            Text("FREE PLAN")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow)
                .cornerRadius(6)
        }
    }
    
    /// Sezione del timer principale
    var timerSection: some View {
        VStack(spacing: 8) {
            Text(Localization.smokeFreeFor)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(1.5)
            
            Text(viewModel.timeElapsedText)
                .font(.system(size: 52, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .contentTransition(.numericText()) // Animazione fluida sui cambi di cifre
                .shadow(color: Color.red.opacity(0.2), radius: 10, y: 5)
        }
        .padding(.vertical, 4)
    }
    
    /// Card del confronto giornaliero: sigarette fumate vs media, sigarette evitate oggi e soldi risparmiati oggi
    var dailyComparisonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                
                Text(Localization.todaySummaryHeader)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(1.0)
                
                Spacer()
            }
            
            // Testo descrittivo del confronto
            Text(viewModel.todayComparisonSummaryText)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineSpacing(4)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Griglia sintetica 3 valori
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("\(viewModel.cigarettesTodayCount)")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text(Localization.smokedToday)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 28)
                
                VStack(spacing: 4) {
                    Text("\(viewModel.todayAvoidedCount)")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text(Localization.avoidedToday)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 28)
                
                VStack(spacing: 4) {
                    Text(viewModel.todaySavedMoneyText)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                    Text(Localization.savedToday)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    /// Card motivazionale sui benefici della salute
    var healthBenefitsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isBenefitActive ? "heart.text.square.fill" : "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(viewModel.isBenefitActive ? .green : .orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.motivationalBenefitTitle)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(viewModel.isBenefitActive ? .green : .orange)
                    
                    Text(viewModel.isBenefitActive ? Localization.healthBenefitsSubtitle : Localization.streakResetSubtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            
            Text(viewModel.motivationalBenefitText)
                .font(.system(.footnote, design: .rounded))
                .fontWeight(viewModel.isBenefitActive ? .regular : .semibold)
                .foregroundStyle(viewModel.isBenefitActive ? Color.white.opacity(0.8) : Color(red: 1.0, green: 0.92, blue: 0.78))
                .lineSpacing(3)
        }
        .padding(16)
        .background(viewModel.isBenefitActive ? Color.green.opacity(0.06) : Color.orange.opacity(0.12))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(viewModel.isBenefitActive ? Color.green.opacity(0.18) : Color.orange.opacity(0.4), lineWidth: 1.2)
        )
    }
    
    /// Pulsante di logging rosso posizionato in basso
    var buttonSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                isShowingLogSheet = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 88, height: 88)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.20, blue: 0.20), Color(red: 0.75, green: 0.05, blue: 0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                        )
                    
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle()) // Animazione premium al tocco
            .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.cigarettesTodayCount) // Feedback nativo SwiftUI
            
            Text(Localization.logCigaretteButton)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.red.opacity(0.8))
                .tracking(1.0)
        }
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel(service: SmokingService.preview))
}

// Stile di bottone personalizzato per l'effetto scala ("molla") premium al tocco
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
