//
//  StatsView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 23/07/2026.
//

import SwiftUI

/// Vista completa dedicata alle Statistiche (Scheda di Sinistra)
struct StatsView: View {
    @State var viewModel: DashboardViewModel
    
    // Stato per tracciare la sigaretta selezionata per il dettaglio completo
    @State private var selectedCigarette: Cigarette? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header Sezione Statistiche
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Localization.statsHeaderTag)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.red.opacity(0.8))
                                    .tracking(2.0)
                                
                                Text(Localization.statsTitle)
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                        
                        // Griglia 2x2 KPI Totali e Medie Avanzate
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                // KPI 1: Risparmi Totali (€)
                                kpiCard(
                                    icon: "eurosign.circle.fill",
                                    iconColor: .yellow,
                                    title: Localization.totalSavings,
                                    value: viewModel.savedMoneyText
                                )
                                
                                // KPI 2: Sigarette Evitate
                                kpiCard(
                                    icon: "leaf.fill",
                                    iconColor: Color(red: 0.18, green: 0.80, blue: 0.44),
                                    title: Localization.totalAvoided,
                                    value: viewModel.avoidedCigarettesText
                                )
                            }
                            
                            HStack(spacing: 12) {
                                // KPI 3: Tempo Medio Tra Sigarette
                                kpiCard(
                                    icon: "clock.badge.checkmark.fill",
                                    iconColor: .cyan,
                                    title: Localization.avgTimeBetweenCigarettesTitle,
                                    value: viewModel.averageTimeBetweenCigarettesText
                                )
                                
                                // KPI 4: Media Settimanale attuale
                                kpiCard(
                                    icon: "calendar.badge.clock",
                                    iconColor: .orange,
                                    title: Localization.weeklyAverageTitle,
                                    value: "\(viewModel.weeklyAverageText)"
                                )
                            }
                        }
                        
                        // Grafico 1: Storico Ultime 7 Giorni (Swift Charts)
                        WeeklyChartView(data: viewModel.weeklyChartData)
                        
                        // Grafico 2: Andamento del Tempo Medio Tra Sigarette
                        IntervalTrendChartView(
                            data: viewModel.intervalTrendChartData,
                            averageText: viewModel.averageTimeBetweenCigarettesText
                        )
                        
                        // Grafico 3: Evoluzione Medie Settimanali & Mensili
                        PeriodicAveragesChartView(
                            weeklyTrends: viewModel.weeklyTrendsChartData,
                            weeklyAvgText: viewModel.weeklyAverageText,
                            monthlyAvgText: viewModel.monthlyAverageText,
                            isLongTermDataAvailable: viewModel.isLongTermDataAvailable
                        )
                        
                        // Sezione Dettaglio Abitudini
                        VStack(alignment: .leading, spacing: 14) {
                            Text(Localization.habitProfile)
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .tracking(1.0)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text(Localization.previousDailyAverage)
                                        .foregroundStyle(.white.opacity(0.8))
                                    Spacer()
                                    Text("\(viewModel.dailyAverage)")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                                Divider().background(Color.white.opacity(0.1))
                                
                                HStack {
                                    Text(Localization.averagePackPrice)
                                        .foregroundStyle(.white.opacity(0.8))
                                    Spacer()
                                    Text("\(viewModel.service.userProfile.packPrice.formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR")))")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.yellow)
                                }
                                Divider().background(Color.white.opacity(0.1))
                                
                                HStack {
                                    Text(Localization.totalSmokeFreeDays)
                                        .foregroundStyle(.white.opacity(0.8))
                                    Spacer()
                                    Text("\(viewModel.daysSinceLastCigarette)")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.green)
                                }
                            }
                            .font(.system(.footnote, design: .rounded))
                            .padding()
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                        
                        // Sezione Ultime registrazioni di oggi
                        if viewModel.cigarettesTodayCount > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.recentLogsToday)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .tracking(1.0)
                                
                                VStack(spacing: 8) {
                                    ForEach(viewModel.recentCigarettesToday) { cigarette in
                                        Button(action: {
                                            selectedCigarette = cigarette
                                        }) {
                                            HStack(spacing: 12) {
                                                Text(cigarette.mood.emoji)
                                                    .font(.title3)
                                                    .frame(width: 36, height: 36)
                                                    .background(Color.white.opacity(0.04))
                                                    .cornerRadius(10)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    HStack {
                                                        Text(cigarette.mood.localizedName)
                                                            .font(.system(.subheadline, design: .rounded))
                                                            .fontWeight(.bold)
                                                            .foregroundStyle(.white)
                                                        Spacer()
                                                        HStack(spacing: 4) {
                                                            Text(cigarette.date.formatted(.dateTime.hour().minute()))
                                                                .font(.system(.caption2, design: .monospaced))
                                                                .foregroundStyle(.secondary)
                                                            Image(systemName: "chevron.right")
                                                                .font(.system(size: 10, weight: .bold))
                                                                .foregroundStyle(.white.opacity(0.3))
                                                        }
                                                    }
                                                    
                                                    HStack(spacing: 6) {
                                                        Text("Craving:")
                                                            .font(.system(size: 10, design: .rounded))
                                                            .foregroundStyle(.secondary)
                                                        
                                                        HStack(spacing: 2) {
                                                            ForEach(1...5, id: \.self) { index in
                                                                Circle()
                                                                    .fill(index <= cigarette.cravingIntensity ? Color.red : Color.white.opacity(0.15))
                                                                    .frame(width: 5, height: 5)
                                                            }
                                                        }
                                                        
                                                        if let notes = cigarette.notes {
                                                            Text("•  \"\(notes)\"")
                                                                .font(.system(size: 10, design: .rounded))
                                                                .foregroundStyle(.secondary)
                                                                .lineLimit(1)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 12)
                                            .background(Color.white.opacity(0.03))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .sheet(item: $selectedCigarette) { cigarette in
                CigaretteDetailSheet(cigarette: cigarette)
            }
        }
    }
    
    // MARK: - Helper Views
    private func kpiCard(icon: String, iconColor: Color, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    StatsView(viewModel: DashboardViewModel(service: SmokingService.preview))
}
