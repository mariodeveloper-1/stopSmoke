//
//  LocalizationManager.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 23/07/2026.
//

import Foundation

/// Lingue supportate dall'applicazione.
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case italian = "it"
    case spanish = "es"
    case french = "fr"
    
    /// Rileva automaticamente la lingua corrente del dispositivo.
    /// Se la lingua del sistema non è tra quelle supportate, viene usato l'Inglese come lingua di default.
    static var current: AppLanguage {
        let preferredCode = Locale.current.language.languageCode?.identifier ?? "en"
        switch preferredCode {
        case "it": return .italian
        case "es": return .spanish
        case "fr": return .french
        default: return .english
        }
    }
}

/// Gestore centralizzato per la localizzazione multilingua dell'interfaccia (EN, IT, ES, FR).
struct Localization {
    
    static var language: AppLanguage {
        AppLanguage.current
    }
    
    // MARK: - TabBar & Navigazione
    static var tabStats: String {
        switch language {
        case .english: return "Statistics"
        case .italian: return "Statistiche"
        case .spanish: return "Estadísticas"
        case .french: return "Statistiques"
        }
    }
    
    static var tabDashboard: String {
        switch language {
        case .english: return "Dashboard"
        case .italian: return "Dashboard"
        case .spanish: return "Panel"
        case .french: return "Tableau"
        }
    }
    
    static var tabBody3D: String {
        switch language {
        case .english: return "Body 3D"
        case .italian: return "Salute 3D"
        case .spanish: return "Cuerpo 3D"
        case .french: return "Corps 3D"
        }
    }
    
    static var tabCoach: String {
        switch language {
        case .english: return "AI Coach"
        case .italian: return "Coach AI"
        case .spanish: return "Coach IA"
        case .french: return "Coach IA"
        }
    }
    
    // MARK: - Dashboard & Timer
    static var smokeFreeFor: String {
        switch language {
        case .english: return "SMOKE-FREE FOR"
        case .italian: return "SENZA FUMARE DA"
        case .spanish: return "SIN FUMAR DESDE"
        case .french: return "SANS FUMER DEPUIS"
        }
    }
    
    static var todaySummaryHeader: String {
        switch language {
        case .english: return "TODAY'S SUMMARY"
        case .italian: return "BILANCIO DI OGGI"
        case .spanish: return "BALANCE DE HOY"
        case .french: return "BILAN DU JOUR"
        }
    }
    
    static var smokedToday: String {
        switch language {
        case .english: return "Smoked today"
        case .italian: return "Fumate oggi"
        case .spanish: return "Fumados hoy"
        case .french: return "Fumées auj."
        }
    }
    
    static var avoidedToday: String {
        switch language {
        case .english: return "Avoided today"
        case .italian: return "Evitate oggi"
        case .spanish: return "Evitados hoy"
        case .french: return "Évitées auj."
        }
    }
    
    static var savedToday: String {
        switch language {
        case .english: return "Saved today"
        case .italian: return "Risparmiati oggi"
        case .spanish: return "Ahorrado hoy"
        case .french: return "Économisé auj."
        }
    }
    
    static var logCigaretteButton: String {
        switch language {
        case .english: return "LOG CIGARETTE"
        case .italian: return "REGISTRA SIGARETTA"
        case .spanish: return "REGISTRAR CIGARRILLO"
        case .french: return "ENREGISTRER CIGARETTE"
        }
    }
    
    // MARK: - Benefici Salute
    static func daySmokeFreeTitle(days: Int) -> String {
        switch language {
        case .english: return "DAY \(days) SMOKE-FREE"
        case .italian: return "GIORNO \(days) SENZA FUMO"
        case .spanish: return "DÍA \(days) SIN FUMAR"
        case .french: return "JOUR \(days) SANS FUMER"
        }
    }
    
    static var healthBenefitsSubtitle: String {
        switch language {
        case .english: return "Health benefits"
        case .italian: return "Benefici per la tua salute"
        case .spanish: return "Beneficios para tu salud"
        case .french: return "Bénéfices pour votre santé"
        }
    }
    
    static var benefitsResetTitle: String {
        switch language {
        case .english: return "BENEFITS RESET"
        case .italian: return "AZZERAMENTO BENEFICI"
        case .spanish: return "REINICIO DE BENEFICIOS"
        case .french: return "RÉINITIALISATION DES BÉNÉFICES"
        }
    }
    
    static var streakResetSubtitle: String {
        switch language {
        case .english: return "Streak reset"
        case .italian: return "Striscia azzerata"
        case .spanish: return "Racha reiniciada"
        case .french: return "Série réinitialisée"
        }
    }
    
    static var benefitsResetWarningText: String {
        switch language {
        case .english:
            return "You logged a cigarette today. To unlock health benefits (blood pressure, lung cleansing & oxygenation) again, do not smoke for at least 24 hours!"
        case .italian:
            return "Hai registrato una sigaretta oggi. Per sbloccare nuovamente i benefici biologici (pressione, pulizia polmonare e ossigenazione), non fumare per almeno 24 ore!"
        case .spanish:
            return "Has registrado un cigarrillo hoy. Para volver a desbloquear los beneficios biológicos (presión arterial, limpieza pulmonar y oxigenación), ¡no fumes durante al menos 24 horas!"
        case .french:
            return "Vous avez enregistré une cigarette aujourd'hui. Pour débloquer à nouveau les bénéfices biologiques (pression artérielle, nettoyage pulmonaire et oxygénation), ne fumez pas pendant au moins 24 heures !"
        }
    }
    
    static func motivationalText(forDays days: Int) -> String {
        switch language {
        case .english:
            switch days {
            case 1: return "Blood pressure and heart rate return to normal. Carbon monoxide levels in blood drop by half."
            case 2: return "Lungs begin clearing out mucus and smoking debris. Taste and smell senses improve noticeably."
            case 3: return "Breathing becomes easier. Bronchial tubes relax and physical energy increases."
            case 4...7: return "Nicotine is completely eliminated from your body. Physical cravings begin to diminish significantly."
            default: return "Blood circulation has improved. Smoker's cough and physical fatigue decrease drastically."
            }
        case .italian:
            switch days {
            case 1: return "Pressione arteriosa e battito cardiaco tornano alla normalità. Il monossido di carbonio nel sangue si dimezza."
            case 2: return "I polmoni iniziano a depurarsi dai residui del fumo. Gusto e olfatto migliorano sensibilmente."
            case 3: return "La respirazione diventa più facile. I bronchi iniziano a rilassarsi e l'energia fisica aumenta."
            case 4...7: return "La nicotina è stata eliminata del tutto dal corpo. Il desiderio fisico (craving) inizia a calare."
            default: return "La circolazione sanguigna è migliorata. La tosse da fumo e la fatica fisica diminuiscono nettamente."
            }
        case .spanish:
            switch days {
            case 1: return "La presión arterial y el ritmo cardíaco vuelven a la normalidad. El monóxido de carbono en la sangre se reduce a la mitad."
            case 2: return "Los pulmones comienzan a limpiarse de residuos de humo. El gusto y el olfato mejoran notablemente."
            case 3: return "La respiración se vuelve más fácil. Los bronquios se relajan y la energía física aumenta."
            case 4...7: return "La nicotina se ha eliminado por completo del cuerpo. El deseo físico (craving) comienza a disminuir."
            default: return "La circulación sanguínea ha mejorado. La tos de fumador y la fatiga física disminuyen drásticamente."
            }
        case .french:
            switch days {
            case 1: return "La pression artérielle et la fréquence cardiaque redeviennent normales. Le monoxyde de carbone dans le sang diminue de moitié."
            case 2: return "Les poumons commencent à éliminer les résidus de fumée. Le goût et l'odorat s'améliorent nettement."
            case 3: return "La respiration devient plus facile. Les bronches se relâchent et l'énergie physique augmente."
            case 4...7: return "La nicotine est complètement éliminée de votre corps. L'envie physique commence à diminuer."
            default: return "La circulation sanguine s'est améliorée. La toux du fumeur et la fatigue physique diminuent fortement."
            }
        }
    }
    
    static func todaySummaryText(count: Int, avg: Int, avoided: Int, savedMoneyText: String) -> String {
        switch language {
        case .english:
            if count == 0 {
                return "You haven't smoked any cigarettes today! Compared to your average of \(avg), you avoided \(avg) cigarettes and saved \(savedMoneyText)."
            } else if count < avg {
                return "Today you smoked \(count) \(count == 1 ? "cigarette" : "cigarettes") compared to your average of \(avg), so \(avoided) fewer and \(savedMoneyText) saved!"
            } else if count == avg {
                return "Today you are at \(count) cigarettes, right on your daily average of \(avg)."
            } else {
                let extra = count - avg
                return "Today you are at \(count) cigarettes (\(extra) more than your average of \(avg)). Don't be discouraged, your AI Coach is here to help!"
            }
        case .italian:
            if count == 0 {
                return "Oggi non hai fumato alcuna sigaretta! Rispetto alla tua media di \(avg), hai evitato \(avg) sigarette e risparmiato \(savedMoneyText)."
            } else if count < avg {
                return "Oggi hai fumato \(count) \(count == 1 ? "sigaretta" : "sigarette") rispetto alla tua media di \(avg), quindi \(avoided) in meno e \(savedMoneyText) risparmiati!"
            } else if count == avg {
                return "Oggi sei a quota \(count) sigarette, in linea con la tua media giornaliera di \(avg)."
            } else {
                let extra = count - avg
                return "Oggi sei a \(count) sigarette (\(extra) in più rispetto alla tua media di \(avg)). Non scoraggiarti, l'AI Coach è qui per aiutarti!"
            }
        case .spanish:
            if count == 0 {
                return "¡Hoy no has fumado ningún cigarrillo! En comparación con tu promedio de \(avg), evitaste \(avg) cigarrillos y ahorraste \(savedMoneyText)."
            } else if count < avg {
                return "Hoy fumaste \(count) \(count == 1 ? "cigarrillo" : "cigarrillos") en comparación con tu promedio de \(avg), ¡así que \(avoided) menos y \(savedMoneyText) ahorrados!"
            } else if count == avg {
                return "Hoy estás en \(count) cigarrillos, justo en tu promedio diario de \(avg)."
            } else {
                let extra = count - avg
                return "Hoy estás en \(count) cigarrillos (\(extra) más que tu promedio de \(avg)). ¡No te desanimes, tu Coach IA está aquí para ayudarte!"
            }
        case .french:
            if count == 0 {
                return "Vous n'avez fumé aucune cigarette aujourd'hui ! Par rapport à votre moyenne de \(avg), vous avez évité \(avg) cigarettes et économisé \(savedMoneyText)."
            } else if count < avg {
                return "Aujourd'hui, vous avez fumé \(count) \(count == 1 ? "cigarette" : "cigarettes") par rapport à votre moyenne de \(avg), soit \(avoided) de moins et \(savedMoneyText) économisés !"
            } else if count == avg {
                return "Aujourd'hui, vous êtes à \(count) cigarettes, exactement dans votre moyenne quotidienne de \(avg)."
            } else {
                let extra = count - avg
                return "Aujourd'hui, vous êtes à \(count) cigarettes (\(extra) de plus que votre moyenne de \(avg)). Ne vous découragez pas, votre Coach IA est là pour vous aider !"
            }
        }
    }
    
    // MARK: - Statistiche (StatsView)
    static var statsHeaderTag: String {
        switch language {
        case .english: return "ANALYSIS & PROGRESS"
        case .italian: return "ANALISI & PROGRESSI"
        case .spanish: return "ANÁLISIS Y PROGRESO"
        case .french: return "ANALYSE & PROGRÈS"
        }
    }
    
    static var statsTitle: String {
        switch language {
        case .english: return "Your Statistics"
        case .italian: return "Le Tue Statistiche"
        case .spanish: return "Tus Estadísticas"
        case .french: return "Vos Statistiques"
        }
    }
    
    static var totalSavings: String {
        switch language {
        case .english: return "TOTAL SAVINGS"
        case .italian: return "RISPARMIO TOTALE"
        case .spanish: return "AHORRO TOTAL"
        case .french: return "ÉCONOMIES TOTALES"
        }
    }
    
    static var totalAvoided: String {
        switch language {
        case .english: return "TOTAL AVOIDED"
        case .italian: return "EVITATE TOTALI"
        case .spanish: return "TOTAL EVITADOS"
        case .french: return "TOTAL ÉVITÉES"
        }
    }
    
    static var habitProfile: String {
        switch language {
        case .english: return "HABIT PROFILE"
        case .italian: return "PROFILO ABITUDINI"
        case .spanish: return "PERFIL DE HÁBITOS"
        case .french: return "PROFIL D'HABITUDE"
        }
    }
    
    static var previousDailyAverage: String {
        switch language {
        case .english: return "Previous daily average"
        case .italian: return "Media giornaliera precedente"
        case .spanish: return "Promedio diario anterior"
        case .french: return "Moyenne quotidienne précédente"
        }
    }
    
    static var averagePackPrice: String {
        switch language {
        case .english: return "Average pack price"
        case .italian: return "Costo medio pacchetto"
        case .spanish: return "Precio medio por paquete"
        case .french: return "Prix moyen du paquet"
        }
    }
    
    static var totalSmokeFreeDays: String {
        switch language {
        case .english: return "Total smoke-free days"
        case .italian: return "Giorni totali di percorso"
        case .spanish: return "Días totales de proceso"
        case .french: return "Jours totaux de parcours"
        }
    }
    
    static var recentLogsToday: String {
        switch language {
        case .english: return "TODAY'S RECENT LOGS"
        case .italian: return "ULTIME REGISTRAZIONI DI OGGI"
        case .spanish: return "REGISTROS RECIENTES DE HOY"
        case .french: return "ENREGISTREMENTS RÉCENTS DU JOUR"
        }
    }
    
    // MARK: - Coach AI (CoachView)
    static var coachHeaderTag: String {
        switch language {
        case .english: return "AI SMOKING COACH"
        case .italian: return "AI SMOKING COACH"
        case .spanish: return "COACH IA ANTITABACO"
        case .french: return "COACH IA ANTI-TABAC"
        }
    }
    
    static var coachHeaderTitle: String {
        switch language {
        case .english: return "Your Digital Mentor"
        case .italian: return "Il Tuo Mentor Digitale"
        case .spanish: return "Tu Mentor Digital"
        case .french: return "Votre Mentor Numérique"
        }
    }
    
    static var onlineStatus: String {
        switch language {
        case .english: return "ONLINE"
        case .italian: return "ATTIVO"
        case .spanish: return "EN LÍNEA"
        case .french: return "EN LIGNE"
        }
    }
    
    static var coachInputPlaceholder: String {
        switch language {
        case .english: return "Type a message to the Coach..."
        case .italian: return "Scrivi un messaggio al Coach..."
        case .spanish: return "Escribe un mensaje al Coach..."
        case .french: return "Écrivez un message au Coach..."
        }
    }
    
    static var quickPillCraving: String {
        switch language {
        case .english: return "🌋 Strong craving!"
        case .italian: return "🌋 Ho forte craving!"
        case .spanish: return "🌋 ¡Tengo mucho deseo!"
        case .french: return "🌋 Forte envie !"
        }
    }
    
    static var quickPillProgress: String {
        switch language {
        case .english: return "📊 My progress today"
        case .italian: return "📊 I miei progressi di oggi"
        case .spanish: return "📊 Mi progreso de hoy"
        case .french: return "📊 Mes progrès aujourd'hui"
        }
    }
    
    static var quickPillStress: String {
        switch language {
        case .english: return "🤯 Very stressed"
        case .italian: return "🤯 Sono molto stressato"
        case .spanish: return "🤯 Muy estresado/a"
        case .french: return "🤯 Très stressé(e)"
        }
    }
    
    // MARK: - Nuove Statistiche Avanzate e Grafici Medie
    static var avgTimeBetweenCigarettesTitle: String {
        switch language {
        case .english: return "Avg Time Between Cigarettes"
        case .italian: return "Tempo Medio Tra Sigarette"
        case .spanish: return "Tiempo Medio Entre Cigarrillos"
        case .french: return "Temps Moyen Entre Cigarettes"
        }
    }
    
    static var weeklyAverageTitle: String {
        switch language {
        case .english: return "Weekly Average"
        case .italian: return "Media Settimanale"
        case .spanish: return "Promedio Semanal"
        case .french: return "Moyenne Hebdomadaire"
        }
    }
    
    static var monthlyAverageTitle: String {
        switch language {
        case .english: return "Monthly Average"
        case .italian: return "Media Mensile"
        case .spanish: return "Promedio Mensual"
        case .french: return "Moyenne Mensuelle"
        }
    }
    
    static var dataCollectingNotice: String {
        switch language {
        case .english: return "Data collection active (requires a few weeks)"
        case .italian: return "Accumulo dati attivo (richiede qualche settimana)"
        case .spanish: return "Recopilando datos (requiere varias semanas)"
        case .french: return "Collecte en cours (nécessite quelques semaines)"
        }
    }
    
    static var intervalTrendHeader: String {
        switch language {
        case .english: return "TIME INTERVAL TREND"
        case .italian: return "ANDAMENTO INTERVALLO DI TEMPO"
        case .spanish: return "TENDENCIA DEL INTERVALO"
        case .french: return "TENDANCE DE L'INTERVALLE"
        }
    }
    
    static var averagesTrendHeader: String {
        switch language {
        case .english: return "WEEKLY & MONTHLY TRENDS"
        case .italian: return "EVOLUZIONE MEDIE SETTIMANALI & MENSILI"
        case .spanish: return "TENDENCIA SEMANAL Y MENSUAL"
        case .french: return "ÉVOLUTION HEBDO ET MENSUELLE"
        }
    }
    
    static var intervalTrendIncreasingText: String {
        switch language {
        case .english: return "Interval is increasing (Great progress! 🎉)"
        case .italian: return "Tempo tra sigarette in aumento (Ottimo! 🎉)"
        case .spanish: return "El tiempo entre cigarrillos aumenta (¡Excelente! 🎉)"
        case .french: return "Temps entre les cigarettes en hausse (Super ! 🎉)"
        }
    }
    
    static var intervalTrendDecreasingText: String {
        switch language {
        case .english: return "Interval is decreasing (Stay focused 💪)"
        case .italian: return "Tempo tra sigarette in calo (Rimani concentrato 💪)"
        case .spanish: return "El tiempo entre cigarrillos disminuye (Sigue enfocado/a 💪)"
        case .french: return "Temps entre les cigarettes en baisse (Reste concentré(e) 💪)"
        }
    }
    
    static var perWeekUnit: String {
        switch language {
        case .english: return "cigs/week"
        case .italian: return "sig/sett"
        case .spanish: return "cig/sem"
        case .french: return "cig/sem"
        }
    }
    
    static var perMonthUnit: String {
        switch language {
        case .english: return "cigs/month"
        case .italian: return "sig/mese"
        case .spanish: return "cig/mes"
        case .french: return "cig/mois"
        }
    }
}

