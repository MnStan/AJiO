//
//  APIResults.swift
//  AJiO
//
//  Created by Maksymilian Stan on 17/05/2024.
//

import Foundation

// MARK: - Meta
struct Meta: Decodable {
    let context: String
    let count: Int
    let title: String
    let page: Int
    let url: String
    let limit: Int
    let provider: String
    let datePublished: String?
    let dateModified: String?
    let description: String
    let keywords: String
    let language: String
    let contentType: String?
    let isPartOf: String?
    let message: Message?
    
    static let defaultMeta = Meta(context: "Test", count: 0, title: "", page: 1, url: "", limit: 1, provider: "", datePublished: nil, dateModified: nil, description: "", keywords: "", language: "", contentType: "", isPartOf: "", message: Message.defaultMessage)
}

struct Message: Decodable {
    let type: String
    let content: String
    
    static let defaultMessage = Message(type: "", content: "")
}

// MARK: - Links
struct Links: Decodable {
    let first: String
    let prev: String?
    let current: String?
    let next: String?
    let last: String
    
    static let defaultLinks = Links(first: "", prev: nil, current: nil, next: nil, last: "")
}

// MARK: - Attributes
struct Attributes: Decodable {
    let `case`: Int
    let benefit: String?
    let manyPlaces: String?
    let provider: String?
    let providerCode: String?
    let regonProvider: String?
    let nipProvider: String?
    let terytProvider: String?
    let place: String?
    let address: String?
    let locality: String?
    let phone: String?
    let terytPlace: String?
    let registryNumber: String?
    let idResortPartVII: String?
    let idResortPartVIII: String?
    let benefitsForChildren: String?
    let covid19: String?
    let toilet: String?
    let ramp: String?
    let carPark: String?
    let elevator: String?
    let latitude: Double?
    let longitude: Double?
    let statistics: Statistics?
    let dates: Dates?
    let benefitsProvided: BenefitsProvided?
    
    static let defaultAttributes = Attributes(case: 1, benefit: "PORADNIA STOMATOLOGICZNA", manyPlaces: "N", provider: "IPL - LUCYNA CHANIECKA-ZIELIŃSKA", providerCode: "064/400267", regonProvider: "491882749", nipProvider: "7351029116", terytProvider: "1215052", place: "PORADNIA STOMATOLOGICZNA", address: "UL. OSIELEC 540", locality: "OSIELEC", phone: "+48 18 277 35 50", terytPlace: "1215052", registryNumber: "000000034125-L-51", idResortPartVII: "001", idResortPartVIII: "1800", benefitsForChildren: "null", covid19: "N", toilet: "Y", ramp: "Y", carPark: "Y", elevator: "N", latitude: 50.0, longitude: 50.0, statistics: Statistics.defaultStatistics, dates: Dates.defaultDates, benefitsProvided: nil)
}

// MARK: - Statistics
struct Statistics: Decodable {
    let providerData: ProviderData?
    let computedData: ComputedData?
    
    static let defaultStatistics = Statistics(providerData: ProviderData.defaultProviderData, computedData: nil)
}

// MARK: - ProviderData
struct ProviderData: Decodable {
    let awaiting: Int
    let removed: Int
    let averagePeriod: Int?
    let update: String
    
    static let defaultProviderData = ProviderData(awaiting: 10, removed: 5, averagePeriod: 5, update: "2024-04")
}

// MARK: - ComputedData
struct ComputedData: Decodable {
    let averagePeriod: Int?
    let update: String
}

// MARK: - BenefitsProvided
struct BenefitsProvided: Decodable {
    let typeOfBenefit: Int?
    let year: Int?
    let amount: Double?
    
    static let defaultBenefitsProvided = BenefitsProvided(typeOfBenefit: 5, year: 2024, amount: 24)
}

struct Dates: Decodable {
    let applicable: Bool?
    let date: String?
    let dateSituationAsAt: String?
    
    static let defaultDates = Dates(applicable: true, date: "2024-05-15", dateSituationAsAt: "2024-05-15")
}

// MARK: - Data Element
struct DataElement: Decodable, Identifiable {
    let type: String
    let id: String
    let attributes: Attributes
    
    static let defaultDataElement = DataElement(type: "", id: "", attributes: Attributes.defaultAttributes)
}

// MARK: - API Response Root
struct APIResponse: Decodable {
    let meta: Meta
    let links: Links
    let data: [DataElement]
    
    static let defaultResponse = APIResponse(meta: Meta.defaultMeta, links: Links.defaultLinks, data: [DataElement.defaultDataElement])
}

// MARK: - Benefit
struct Benefit: Decodable {
    let name: String
}

// MARK: - APIResponse
struct APIResponseBenefit: Decodable {
    let meta: Meta
    let links: Links
    let data: [String]
}
