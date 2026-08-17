//
//  MainTabView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 23/07/2026.
//

import SwiftUI

/// TabBar principale dell'applicazione con effetto "Liquid Glass".
/// Gestisce la navigazione inferiore a 3 schede con uno slider di vetro liquido animato:
/// 1. Statistiche (Sinistra)
/// 2. Dashboard con Timer & Benefici Giornalieri (Centro)
/// 3. Coach AI Chat (Destra)
struct MainTabView: View {
    @State var service: SmokingService
    
    // Indice della scheda selezionata: 0 = Statistiche, 1 = Dashboard (Default al centro), 2 = Salute 3D, 3 = Coach AI
    @State private var selectedTab: Int = 1
    
    // Namespace per l'animazione di scorrimento del vetro liquido tra le schede
    @Namespace private var liquidGlassNamespace
    
    // ViewModels derivati dalla sorgente unica della verità
    @State private var dashboardViewModel: DashboardViewModel
    @State private var coachViewModel: CoachViewModel
    
    init(service: SmokingService) {
        self._service = State(initialValue: service)
        self._dashboardViewModel = State(initialValue: DashboardViewModel(service: service))
        self._coachViewModel = State(initialValue: CoachViewModel(service: service))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Slider / Pagine swipeable ultra-fluide (120 FPS iOS 18)
            TabView(selection: $selectedTab) {
                StatsView(viewModel: dashboardViewModel)
                    .tag(0)
                
                DashboardView(viewModel: dashboardViewModel)
                    .tag(1)
                
                Health3DView(viewModel: dashboardViewModel)
                    .tag(2)
                
                CoachView(viewModel: coachViewModel)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Pagine scorrevoli a gesto orizzontale
            .ignoresSafeArea()
            
            // Barra di Navigazione Inferiore Personalizzata ("Slider Liquid Glass")
            liquidGlassBottomBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Subview Barra di Navigazione Inferiore Liquid Glass
private extension MainTabView {
    var liquidGlassBottomBar: some View {
        HStack(spacing: 4) {
            // Scheda 1: STATISTICHE
            LiquidGlassTabButton(
                title: Localization.tabStats,
                icon: "chart.bar.fill",
                tabIndex: 0,
                selectedTab: $selectedTab,
                namespace: liquidGlassNamespace
            )
            
            // Scheda 2: DASHBOARD / TIMER
            LiquidGlassTabButton(
                title: Localization.tabDashboard,
                icon: "timer",
                tabIndex: 1,
                selectedTab: $selectedTab,
                namespace: liquidGlassNamespace
            )
            
            // Scheda 3: SALUTE 3D
            LiquidGlassTabButton(
                title: Localization.tabBody3D,
                icon: "figure.stand",
                tabIndex: 2,
                selectedTab: $selectedTab,
                namespace: liquidGlassNamespace
            )
            
            // Scheda 4: COACH AI
            LiquidGlassTabButton(
                title: Localization.tabCoach,
                icon: "brain.head.profile",
                tabIndex: 3,
                selectedTab: $selectedTab,
                namespace: liquidGlassNamespace
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Sfondo contenitore scuro con riflessi vitrei
                Color(red: 0.07, green: 0.07, blue: 0.10).opacity(0.85)
                BlurView(style: .systemUltraThinMaterialDark)
            }
        )
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04), Color.red.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Pulsante con Capsula Scorrevole Liquid Glass
private struct LiquidGlassTabButton: View {
    let title: String
    let icon: String
    let tabIndex: Int
    @Binding var selectedTab: Int
    var namespace: Namespace.ID
    
    var isSelected: Bool {
        selectedTab == tabIndex
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.snappy(duration: 0.25, extraBounce: 0.1)) {
                selectedTab = tabIndex
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(
                        isSelected
                        ? LinearGradient(colors: [.white, Color(red: 1.0, green: 0.35, blue: 0.35)], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.white.opacity(0.4), .white.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                    .shadow(color: isSelected ? Color.red.opacity(0.7) : Color.clear, radius: 8, x: 0, y: 0)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    // Capsula "Liquid Glass" animata che scivola da un tab all'altro
                    ZStack {
                        // Sfondo vitreo semi-trasparente rosso liquido
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(0.30),
                                        Color.white.opacity(0.08),
                                        Color.red.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Bordo lucido brillante stile vetro curvo
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(0.9),
                                        Color.white.opacity(0.35),
                                        Color.red.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 4)
                    .matchedGeometryEffect(id: "liquidGlassCapsule", in: namespace)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// Visual Effect Blur helper per un look satinato stile Apple Glass
private struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    MainTabView(service: SmokingService.preview)
}
