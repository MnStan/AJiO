//
//  NetworkManager.swift
//  AJiO
//
//  Created by Maksymilian Stan on 17/05/2024.
//

import Foundation

@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    @Published var dataArray: [DataElement] = []
    @Published var isFetching = false
    @Published var totalItems: Int? = nil
    
    private var shouldFetchMore = true
    private var currentPage = 1
    private let maxRequestsPerSecond = 10
    private var requestCount = 0
    private var requestStartTime: Date?
    
    let baseURL = "https://api.nfz.gov.pl/app-itl-api/queues"
    
    enum FetchError: Error {
        case badRequest
        case badJSON
        case invalidURL
    }
    
    func fetchData(province: String, benefit: String) async throws {
        guard !isFetching else { return }
        isFetching = true
        
        defer {
            isFetching = false
        }
        
        if currentPage == 1 {
            dataArray.removeAll()
            totalItems = nil
        }
        
        guard var components = URLComponents(string: baseURL) else {
            throw FetchError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: String(currentPage)),
            URLQueryItem(name: "limit", value: "25"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "case", value: "1"),
            URLQueryItem(name: "province", value: province),
            URLQueryItem(name: "benefit", value: benefit),
            URLQueryItem(name: "benefitForChildren", value: "false"),
            URLQueryItem(name: "api-version", value: "1.3")
        ]
        
        guard let url = components.url else {
            throw FetchError.invalidURL
        }
        
        if let startTime = requestStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 1 {
                if requestCount >= maxRequestsPerSecond {
                    let waitTime = 1 - elapsed
                    try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                    requestCount = 0
                    requestStartTime = Date()
                }
            } else {
                requestCount = 0
                requestStartTime = Date()
            }
        } else {
            requestStartTime = Date()
        }
        
        requestCount += 1
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromKebabCase
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let decodedData = try decoder.decode(APIResponse.self, from: data)
            Task { @MainActor in
                if self.totalItems == nil {
                    self.totalItems = decodedData.meta.count
                }
                
                self.dataArray.append(contentsOf: decodedData.data)
                
                if let totalItems = self.totalItems, dataArray.count < totalItems {
                    currentPage += 1
                    try await self.fetchData(province: province, benefit: benefit)
                } else {
                    shouldFetchMore = false
                    currentPage = 1
                }
            }
        } catch {
            throw FetchError.badJSON
        }
    }
    
    func cancelFetch() {
        print("Cancel fetch called")
        isFetching = false
        dataArray.removeAll()
        currentPage = 1
        totalItems = nil
    }
}
