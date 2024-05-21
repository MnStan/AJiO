//
//  Voivodeship.swift
//  AJiO
//
//  Created by Maksymilian Stan on 18/05/2024.
//

import Foundation

enum Voivodeship: String, CaseIterable {
    case dolnoslaskie = "01"
    case kujawskopomorskie = "02"
    case lubelskie = "03"
    case lubuskie = "04"
    case lodzkie = "05"
    case malopolskie = "06"
    case mazowieckie = "07"
    case opolskie = "08"
    case podkarpackie = "09"
    case podlaskie = "10"
    case pomorskie = "11"
    case slaskie = "12"
    case swietokrzyskie = "13"
    case warminskomazurskie = "14"
    case wielkopolskie = "15"
    case zachodniopomorskie = "16"
    
    var name: String {
        get {
            switch self {
            case .dolnoslaskie:
                "dolnoslaskie"
            case .kujawskopomorskie:
                "kujawskopomorskie"
            case .lubelskie:
                "lubelskie"
            case .lubuskie:
                "lubuskie"
            case .lodzkie:
                "lodzkie"
            case .malopolskie:
                "malopolskie"
            case .mazowieckie:
                "mazowieckie"
            case .opolskie:
                "opolskie"
            case .podkarpackie:
                "podkarpackie"
            case .podlaskie:
                "podlaskie"
            case .pomorskie:
                "pomorskie"
            case .slaskie:
                "slaskie"
            case .swietokrzyskie:
                "swietokrzyskie"
            case .warminskomazurskie:
                "warminskomazurskie"
            case .wielkopolskie:
                "wielkopolskie"
            case .zachodniopomorskie:
                "zachodniopomorskie"
            }
        }
    }
}
