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
    
    static let defaultAttributes = Attributes(case: 1, benefit: "", manyPlaces: "", provider: "", providerCode: "", regonProvider: "", nipProvider: "", terytProvider: "", place: "", address: "", locality: "", phone: "", terytPlace: "", registryNumber: "", idResortPartVII: "", idResortPartVIII: "", benefitsForChildren: "", covid19: "", toilet: "", ramp: "", carPark: "", elevator: "", latitude: 50.0, longitude: 50.0, statistics: nil, dates: nil, benefitsProvided: nil)
}

// MARK: - Statistics
struct Statistics: Decodable {
    let providerData: ProviderData?
    let computedData: ComputedData?
    
    static let defaultStatistics = Statistics(providerData: nil, computedData: nil)
}

// MARK: - ProviderData
struct ProviderData: Decodable {
    let awaiting: Int
    let removed: Int
    let averagePeriod: Int?
    let update: String
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
}

struct Dates: Decodable {
    let applicable: Bool?
    let date: Date?
    let dateSituationAsAt: Date?
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
