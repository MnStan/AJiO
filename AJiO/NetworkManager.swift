//
//  NetworkManager.swift
//  AJiO
//
//  Created by Maksymilian Stan on 17/05/2024.
//

import Foundation

class NetworkManager: ObservableObject {
    @Published var apiResponse: APIResponse? = nil
    @Published var dataArray: [DataElement] = []
    @Published var isFetching = false
    private var shouldFetchMore = true
    private var currentPage = 1
    @Published var totalItems: Int? = nil
    
    private var currentTask: Task<Void, Error>? = nil
    
    let baseURL = "https://api.nfz.gov.pl/app-itl-api/queues"
    
    enum FetchError: Error {
        case badRequest
        case badJSON
        case invalidURL
    }
    
    func fetchData(province: Int, benefit: String) async throws {
        guard !isFetching else { return }
        print("Fetching, page: ", currentPage)
        isFetching = true
        
        defer {
            isFetching = false
        }
        
        if currentPage == 1 {
            dataArray.removeAll()
        }
        
        guard var components = URLComponents(string: baseURL) else {
            throw FetchError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(currentPage)),
            URLQueryItem(name: "limit", value: "25"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "case", value: "1"),
            URLQueryItem(name: "province", value: "0" + String(province)),
            URLQueryItem(name: "benefit", value: benefit),
            URLQueryItem(name: "benefitForChildren", value: "false"),
            URLQueryItem(name: "api-version", value: "1.3")
        ]

        guard let url = components.url else {
            throw FetchError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let decodedData = try decoder.decode(APIResponse.self, from: data)
            currentTask = Task { @MainActor in
                if self.totalItems == nil {
                    self.totalItems = decodedData.meta.count
                }
                
                self.apiResponse = decodedData
                dataArray.append(contentsOf: decodedData.data)
                
                if let totalItems = self.totalItems, dataArray.count < totalItems {
                    currentPage += 1
                    try await self.fetchData(province: province, benefit: benefit)
                } else {
                    shouldFetchMore = false
                    currentPage = 1
                }
            }
        } catch {
            print("JSON error", error)
            throw FetchError.badJSON
        }
    }
    
    func cancelFetch() {
        isFetching = false
        dataArray.removeAll()
        currentPage = 1
    }
}
