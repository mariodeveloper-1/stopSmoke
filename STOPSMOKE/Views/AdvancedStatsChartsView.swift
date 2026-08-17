//
//  AdvancedStatsChartsView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 24/07/2026.
//

import SwiftUI
import Charts

/// Grafico e Card per il Tempo Medio Tra Sigarette
struct IntervalTrendChartView: View {
    let data: [IntervalTrendData]
    let averageText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Localization.intervalTrendHeader)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(1.0)
                    
                    Text(Localization.avgTimeBetweenCigarettesTitle)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                Spacer()
                
                // Badge valore medio
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                    Text(averageText)
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundStyle(.cyan)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.cyan.opacity(0.12))
                .cornerRadius(12)
            }
            
            let validPoints = data.filter { $0.intervalHours > 0 }
            
            if validPoints.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.4))
                    Text(Localization.dataCollectingNotice)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.white.opacity(0.01))
                .cornerRadius(12)
            } else {
                Chart {
                    ForEach(data) { item in
                        AreaMark(
                            x: .value("Giorno", item.dayLabel),
                            y: .value("Ore", item.intervalHours)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.35), Color.cyan.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Giorno", item.dayLabel),
                            y: .value("Ore", item.intervalHours)
                        )
                        .foregroundStyle(Color.cyan)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Giorno", item.dayLabel),
                            y: .value("Ore", item.intervalHours)
                        )
                        .foregroundStyle(Color.white)
                        .symbolSize(20)
                    }
                }
                .frame(height: 130)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(Int(hours))h")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(Color.white.opacity(0.4))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
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
}

/// Grafico per le Medie Settimanali e Mensili con confronto temporale
struct PeriodicAveragesChartView: View {
    let weeklyTrends: [PeriodTrendData]
    let weeklyAvgText: String
    let monthlyAvgText: String
    let isLongTermDataAvailable: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Localization.averagesTrendHeader)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(1.0)
                
                HStack {
                    Text(Localization.weeklyAverageTitle + " & " + Localization.monthlyAverageTitle)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            
            // Card con i valori attuali
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(Localization.weeklyAverageTitle)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(weeklyAvgText) \(Localization.perWeekUnit)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(.purple)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(Localization.monthlyAverageTitle)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(monthlyAvgText) \(Localization.perMonthUnit)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
            }
            
            // Grafico dell'andamento delle ultime 4 settimane
            if !isLongTermDataAvailable {
                // Banner informativo se l'utente ha scaricato l'app da pochi giorni
                HStack(spacing: 10) {
                    Image(systemName: "hourglass")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Localization.language == .italian ? "In fase di rilevamento medie" : "Gathering average trends")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(Localization.dataCollectingNotice)
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            } else {
                Chart {
                    ForEach(weeklyTrends) { item in
                        BarMark(
                            x: .value("Periodo", item.periodName),
                            y: .value("Media al Giorno", item.averageDailyCount)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.9), Color.red.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                        
                        RuleMark(y: .value("Target", 0))
                            .foregroundStyle(Color.white.opacity(0.2))
                    }
                }
                .frame(height: 130)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel {
                            if let count = value.as(Double.self) {
                                Text("\(Int(count))")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(Color.white.opacity(0.4))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
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
}
