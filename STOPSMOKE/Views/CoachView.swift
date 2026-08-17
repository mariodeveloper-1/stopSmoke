//
//  CoachView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 23/07/2026.
//

import SwiftUI

/// Interfaccia di chat per l'AI Smoking Coach (Scheda di Destra)
struct CoachView: View {
    @State var viewModel: CoachViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Coach
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.title3)
                                .foregroundStyle(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Localization.coachHeaderTag)
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                                .tracking(1.0)
                            
                            Text(Localization.coachHeaderTitle)
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        // Badge Online
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text(Localization.onlineStatus)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    
                    Divider()
                        .background(Color.white.opacity(0.08))
                    
                    // Lista dei messaggi
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if viewModel.isTyping {
                                    HStack {
                                        Text("...")
                                            .font(.system(.caption, design: .rounded))
                                            .italic()
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            if let lastId = viewModel.messages.last?.id {
                                withAnimation {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Quick Action Buttons (Suggerimenti rapidi)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            QuickActionButton(title: Localization.quickPillCraving) {
                                viewModel.sendMessage(text: Localization.quickPillCraving)
                            }
                            QuickActionButton(title: Localization.quickPillProgress) {
                                viewModel.sendMessage(text: Localization.quickPillProgress)
                            }
                            QuickActionButton(title: Localization.quickPillStress) {
                                viewModel.sendMessage(text: Localization.quickPillStress)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    
                    // Campo di input messaggio
                    HStack(spacing: 12) {
                        TextField(Localization.coachInputPlaceholder, text: $viewModel.inputText)
                            .font(.system(.body, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .foregroundStyle(.white)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(24)
                            .onSubmit {
                                viewModel.sendMessage()
                            }
                        
                        Button(action: {
                            viewModel.sendMessage()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.2) : Color.red)
                        }
                        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.08, green: 0.08, blue: 0.12))
                }
            }
        }
    }
}

// MARK: - Subviews per la Chat
private struct MessageBubble: View {
    let message: ChatMessage
    
    var isUser: Bool {
        message.sender == .user
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        isUser
                        ? LinearGradient(colors: [Color.red, Color(red: 0.8, green: 0.1, blue: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(20)
                
                Text(message.date.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
            }
            .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
            
            if !isUser { Spacer() }
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.06))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

#Preview {
    CoachView(viewModel: CoachViewModel(service: SmokingService.preview))
}
