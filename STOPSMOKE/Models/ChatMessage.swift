//
//  ChatMessage.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 23/07/2026.
//

import Foundation

/// Rappresenta un singolo messaggio all'interno della chat con l'AI Coach.
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let sender: MessageSender
    let text: String
    let date: Date
    
    enum MessageSender: String, Codable {
        case user
        case coach
    }
    
    init(id: UUID = UUID(), sender: MessageSender, text: String, date: Date = Date()) {
        self.id = id
        self.sender = sender
        self.text = text
        self.date = date
    }
}
