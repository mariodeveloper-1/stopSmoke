//
//  CoachViewModel.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 23/07/2026.
//

import Foundation
import Observation

/// ViewModel che gestisce la logica di conversazione con l'AI Smoking Coach.
@Observable
class CoachViewModel {
    let service: SmokingService
    
    /// Storico dei messaggi della chat
    var messages: [ChatMessage] = []
    
    /// Testo attualmente digitato nell'input di chat
    var inputText: String = ""
    
    /// Stato di digitazione dell'AI (sta scrivendo...)
    var isTyping: Bool = false
    
    init(service: SmokingService) {
        self.service = service
        loadInitialGreeting()
    }
    
    /// Carica il messaggio di benvenuto personalizzato in base ai progressi reali dell'utente
    private func loadInitialGreeting() {
        let avoided = service.todayAvoidedCigarettesCount()
        let savedText = service.todaySavedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
        let count = service.cigarettesTodayCount
        let avg = service.userProfile.dailyAverage
        
        let greetingText: String
        switch AppLanguage.current {
        case .english:
            if count == 0 {
                greetingText = "Hello! I am your AI Smoking Coach 🧠.\n\nYou are doing great today! You haven't smoked any cigarettes yet compared to your average of \(avg). You've already saved \(savedText)!\n\nHow can I support you right now?"
            } else {
                greetingText = "Hello! I am your AI Smoking Coach 🧠.\n\nToday you logged \(count) \(count == 1 ? "cigarette" : "cigarettes"). Compared to your average of \(avg), you still avoided \(avoided) cigarettes and saved \(savedText)!\n\nIf you feel the urge to smoke or experience high stress, chat with me anytime."
            }
        case .italian:
            if count == 0 {
                greetingText = "Ciao! Sono il tuo AI Smoking Coach 🧠.\n\nStai andando alla grande oggi! Non hai ancora fumato alcuna sigaretta rispetto alla tua media di \(avg). Hai già risparmiato \(savedText)!\n\nCome posso aiutarti in questo momento?"
            } else {
                greetingText = "Ciao! Sono il tuo AI Smoking Coach 🧠.\n\nOggi hai registrato \(count) \(count == 1 ? "sigaretta" : "sigarette"). Rispetto alla tua media di \(avg), hai comunque evitato \(avoided) sigarette e risparmiato \(savedText)!\n\nSe senti il bisogno di fumare o provi forte stress, parlane subito con me."
            }
        case .spanish:
            if count == 0 {
                greetingText = "¡Hola! Soy tu Coach IA Antitabaco 🧠.\n\n¡Lo estás haciendo genial hoy! Aún no has fumado ningún cigarrillo en comparación con tu promedio de \(avg). ¡Ya has ahorrado \(savedText)!\n\n¿Cómo puedo ayudarte en este momento?"
            } else {
                greetingText = "¡Hola! Soy tu Coach IA Antitabaco 🧠.\n\nHoy has registrado \(count) \(count == 1 ? "cigarrillo" : "cigarrillos"). En comparación con tu promedio de \(avg), ¡has evitado \(avoided) cigarrillos y ahorrado \(savedText)!\n\nSi sientes ganas de fumar o mucho estrés, habla conmigo."
            }
        case .french:
            if count == 0 {
                greetingText = "Bonjour ! Je suis votre Coach IA Anti-Tabac 🧠.\n\nVous faites du super travail aujourd'hui ! Vous n'avez fumé aucune cigarette par rapport à votre moyenne de \(avg). Vous avez déjà économisé \(savedText) !\n\nComment puis-je vous aider en ce moment ?"
            } else {
                greetingText = "Bonjour ! Je suis votre Coach IA Anti-Tabac 🧠.\n\nAujourd'hui vous avez enregistré \(count) \(count == 1 ? "cigarette" : "cigarettes"). Par rapport à votre moyenne de \(avg), vous avez tout de même évité \(avoided) cigarettes et économisé \(savedText) !\n\nSi vous ressentez une envie ou du stress, parlez-en moi."
            }
        }
        
        messages.append(ChatMessage(sender: .coach, text: greetingText))
    }
    
    /// Invia un messaggio digitato dall'utente e genera la risposta intelligente dell'AI
    func sendMessage(text: String? = nil) {
        let messageToSend = (text ?? inputText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageToSend.isEmpty else { return }
        
        // 1. Aggiungiamo il messaggio dell'utente
        let userMsg = ChatMessage(sender: .user, text: messageToSend)
        messages.append(userMsg)
        
        if text == nil {
            inputText = ""
        }
        
        // 2. Simuliamo l'elaborazione dell'AI Coach
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isTyping = false
            let responseText = self.generateAIResponse(to: messageToSend)
            self.messages.append(ChatMessage(sender: .coach, text: responseText))
        }
    }
    
    /// Genera la risposta dell'AI analizzando il testo dell'utente e lo stato dell'app
    private func generateAIResponse(to input: String) -> String {
        let lower = input.lowercased()
        let avoided = service.todayAvoidedCigarettesCount()
        let savedMoneyText = service.todaySavedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
        
        switch AppLanguage.current {
        case .english:
            if lower.contains("craving") || lower.contains("desire") || lower.contains("urge") || lower.contains("strong") {
                return "I recognize this moment: it's a craving! 🌋 It usually lasts only 3-5 minutes.\n\n💡 **What to do right now:**\n1. Sip a glass of cold water.\n2. Take 3 deep breaths: inhale for 4s, hold for 4s, exhale for 6s.\n3. Remember: today you already avoided \(avoided) cigarettes and saved \(savedMoneyText). Protect your progress!"
            } else if lower.contains("stress") || lower.contains("anxious") || lower.contains("angry") {
                return "Stress is a powerful trigger 🤯. Smoking gives a false 5-minute relief followed by guilt.\n\nTake a 2-minute break away from your screen, stretch your shoulders and take deep breaths."
            } else if lower.contains("progress") || lower.contains("saved") || lower.contains("stats") || lower.contains("today") {
                let totalSaved = service.savedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
                let totalAvoided = service.avoidedCigarettesCount()
                return "Here is your overall summary 📊:\n\n• Total cigarettes avoided: **\(totalAvoided)**\n• Total money saved: **\(totalSaved)**\n• Today: **\(avoided) fewer cigarettes** than your average!\n\nYou are doing an amazing job for your health and wallet."
            } else {
                return "I'm listening. Remember every urge you overcome rewires your brain. Today you've already avoided \(avoided) cigarettes. Take a quick walk or drink water!"
            }
        case .italian:
            if lower.contains("desiderio") || lower.contains("voglia") || lower.contains("craving") || lower.contains("forte") {
                return "Riconosco questo momento: è il craving! 🌋 Dura in media solo 3-5 minuti.\n\n💡 **Cosa fare adesso:**\n1. Bevi a sorsi un bicchiere d'acqua fredda.\n2. Fai 3 respiri profondi: inspira per 4 secondi, trattiene per 4, espira per 6.\n3. Ricorda: oggi hai già evitato \(avoided) sigarette e risparmiato \(savedMoneyText). Non regalare questo progresso alla nicotina!"
            } else if lower.contains("stress") || lower.contains("arrabbiat") || lower.contains("ansia") {
                return "Lo stress è uno dei trigger più potenti 🤯. Fumare ti darebbe una falsa sensazione di sollievo per 5 minuti, per poi farti sentire in colpa.\n\nFai una pausa di 2 minuti lontano dal computer o dalla situazione di stress, e distendi le spalle."
            } else if lower.contains("come sto") || lower.contains("progresso") || lower.contains("risparmio") || lower.contains("statistiche") {
                let totalSaved = service.savedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
                let totalAvoided = service.avoidedCigarettesCount()
                return "Ecco il tuo bilancio complessivo 📊:\n\n• Sigarette evitate dall'inizio: **\(totalAvoided)**\n• Soldi risparmiati in totale: **\(totalSaved)**\n• Oggi: **\(avoided) sigarette in meno** rispetto alla tua media!\n\nStai facendo un lavoro straordinario per la tua salute e le tue finanze."
            } else {
                return "Ti ascolto. Ricorda che ogni momento in cui resisti al desiderio stai ricalibrando i ricettori del tuo cervello. Oggi hai già evitato \(avoided) sigarette. Se senti il bisogno di distrarti, prova a fare qualche passo o a bere dell'acqua!"
            }
        case .spanish:
            if lower.contains("deseo") || lower.contains("ganas") || lower.contains("craving") || lower.contains("fuerte") {
                return "Reconozco este momento: ¡es el deseo! 🌋 Dura solo 3-5 minutos.\n\n💡 **Qué hacer ahora:**\n1. Bebe un vaso de agua fría a sorbos.\n2. Toma 3 respiraciones profundas: inhala 4s, mantén 4s, exhala 6s.\n3. Recuerda: hoy ya evitaste \(avoided) cigarrillos y ahorraste \(savedMoneyText). ¡Protege tu progreso!"
            } else if lower.contains("estrés") || lower.contains("estres") || lower.contains("ansiedad") {
                return "El estrés es un desencadenante poderoso 🤯. Fumar te daría un falso alivio de 5 minutos seguido de culpa.\n\nTómate una pausa de 2 minutos y estira los hombros."
            } else if lower.contains("progreso") || lower.contains("ahorro") || lower.contains("estadísticas") || lower.contains("hoy") {
                let totalSaved = service.savedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
                let totalAvoided = service.avoidedCigarettesCount()
                return "Aquí está tu balance general 📊:\n\n• Cigarrillos evitados en total: **\(totalAvoided)**\n• Dinero ahorrado en total: **\(totalSaved)**\n• Hoy: **\(avoided) cigarrillos menos** que tu promedio.\n\nEstás haciendo un trabajo increíble."
            } else {
                return "Te escucho. Recuerda que cada deseo superado reconfigura tu cerebro. Hoy ya evitaste \(avoided) cigarrillos. ¡Camina unos pasos o bebe agua!"
            }
        case .french:
            if lower.contains("envie") || lower.contains("besoin") || lower.contains("craving") || lower.contains("forte") {
                return "Je reconnais ce moment : c'est l'envie ! 🌋 Cela ne dure que 3 à 5 minutes.\n\n💡 **Que faire maintenant :**\n1. Buvez un verre d'eau froide à petites gorgées.\n2. Prenez 3 inspirations profondes : inspirez 4s, bloquez 4s, expirez 6s.\n3. Rappelez-vous : aujourd'hui vous avez évité \(avoided) cigarettes et économisé \(savedMoneyText) !"
            } else if lower.contains("stress") || lower.contains("anxiété") || lower.contains("colère") {
                return "Le stress est un déclencheur puissant 🤯. Fumer donnerait un faux soulagement de 5 minutes suivi de culpabilité.\n\nFaites une pause de 2 minutes loin de l'écran et détendez vos épaules."
            } else if lower.contains("progrès") || lower.contains("économie") || lower.contains("statistiques") || lower.contains("aujourd'hui") {
                let totalSaved = service.savedMoney().formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
                let totalAvoided = service.avoidedCigarettesCount()
                return "Voici votre bilan global 📊 :\n\n• Cigarettes évitées au total : **\(totalAvoided)**\n• Économies totales : **\(totalSaved)**\n• Aujourd'hui : **\(avoided) cigarettes en moins** par rapport à votre moyenne.\n\nVous faites un travail formidable !"
            } else {
                return "Je vous écoute. Chaque envie surmontée réorganise les récepteurs de votre cerveau. Aujourd'hui vous avez évité \(avoided) cigarettes. Marchez un peu ou buvez de l'eau !"
            }
        }
    }
}
