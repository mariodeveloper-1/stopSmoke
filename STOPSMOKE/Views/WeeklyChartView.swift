//
//  WeeklyChartView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 19/07/2026.
//

import SwiftUI
import Charts

/// Vista del grafico settimanale. Mostra l'andamento del fumo negli ultimi 7 giorni.
struct WeeklyChartView: View {
    /// Dati calcolati dal ViewModel per popolare il grafico
    let data: [DailyUsageChartData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("STORICO ULTIMI 7 GIORNI")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1.0)
            
            if data.map({ $0.count }).reduce(0, +) == 0 {
                // Se non ci sono sigarette negli ultimi 7 giorni, mostriamo un incoraggiamento
                VStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(.yellow)
                    
                    Text("Nessuna sigaretta fumata in questa settimana!")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.white.opacity(0.01))
                .cornerRadius(12)
            } else {
                Chart {
                    ForEach(data) { item in
                        BarMark(
                            x: .value("Giorno", item.dayLabel),
                            y: .value("Sigarette", item.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red.opacity(0.8), Color.red.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(4)
                    }
                }
                .frame(height: 120)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.4))
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
