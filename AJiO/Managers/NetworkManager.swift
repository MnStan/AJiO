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
    @Published var tempDataArray: [DataElement] = []
    @Published var nearVoivodeshipsDataArray: [DataElement] = []
    @Published var isFetching = false
    @Published var isFetchingNearVoivodeships = false
    @Published var totalItems: Int? = nil
    @Published var totalItemsNearVoivodeships: Int? = nil
    @Published var shouldFetchMore = true
    
    private var currentPage = 1
    private let maxRequestsPerSecond = 10
    private var requestCount = 0
    private var requestStartTime: Date?
    private var voivodeshipArray: [String] = Array(LocationManager.shared.nearVoivodeships).filter { $0 != (LocationManager.shared.state ?? "") }
    private var currentIndex = 0
    
    let baseURL = "https://api.nfz.gov.pl/app-itl-api/queues"
    
    enum FetchError: Error {
        case badRequest
        case badJSON
        case invalidURL
        case fetchError
    }
    
    func fetchData(province: String, benefit: String, isUserVoivodeship: Bool = true, nextPageForNear: Int = 1, totalItemsForCurrentVoivodeship: Int? = nil, completionHandler: ((Bool) -> Void)? = nil) async throws {
        guard !isFetching else { return }
        isFetching = true
        
        defer {
            isFetching = false
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
                    try await Task.sleep(nanoseconds: UInt64(waitTime * 2_000_000_000))
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
                if isUserVoivodeship {
                    if self.totalItems == nil {
                        self.totalItems = decodedData.meta.count
                    }
                    
                    self.dataArray.append(contentsOf: decodedData.data)
                    
                    if let totalItems = self.totalItems, dataArray.count < totalItems {
                        currentPage += 1
                        do {
                            try await self.fetchData(province: province, benefit: benefit)
                        } catch {
                            throw FetchError.fetchError
                        }
                    } else {
                        currentPage = 1
                        fetchNextVoivodeship(benefit: benefit)
                    }
                } else {
                    var totalItemsNear: Int? = nil
                    if totalItemsForCurrentVoivodeship == nil {
                        totalItemsNear = decodedData.meta.count
                    }
                    
                    self.nearVoivodeshipsDataArray.append(contentsOf: decodedData.data.filter { newElement in
                        !self.nearVoivodeshipsDataArray.contains { $0.id == newElement.id }
                    })
                    
                    if let totalItems = totalItemsNear, nearVoivodeshipsDataArray.count < totalItems {
                        let nextPage = nextPageForNear + 1
                        do {
                            try await self.fetchData(province: province, benefit: benefit, isUserVoivodeship: false, nextPageForNear: nextPage, totalItemsForCurrentVoivodeship: totalItemsNear, completionHandler: completionHandler)
                        } catch {
                            throw FetchError.fetchError
                        }
                    } else {
                        totalItemsNearVoivodeships = nil
                        if let handler = completionHandler {
                            handler(true)
                        }
                    }
                }
            }
        } catch {
            throw FetchError.badJSON
        }
    }
    
    func fetchNearVoivodeships(province: String, benefit: String, completionHandler: ((Bool) -> Void)? = nil) {
        let completionHandlerForFetchData: (Bool) -> Void = { [weak self] isDone in
            guard let self else { return }
            if let completion = completionHandler {
                completion(true)
            }
            fetchNextVoivodeship(benefit: benefit)
        }
        
        Task {
                guard let voivodeShipNumber = LocationManager.shared.getVoivodeshipCode(state: province) else { return }
            do {
                try await fetchData(province: voivodeShipNumber, benefit: benefit, isUserVoivodeship: false, completionHandler: completionHandlerForFetchData)
            } catch {
                throw FetchError.fetchError
            }
        }
    }
    
    func fetchNextVoivodeship(benefit: String) {
        if shouldFetchMore || currentIndex < LocationManager.shared.nearVoivodeshipsArray.count - 1 {
            let province = LocationManager.shared.nearVoivodeshipsArray[currentIndex]
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                guard let self else { return }
                self.fetchNearVoivodeships(province: province, benefit: benefit) { [weak self] isDone in
                    guard let self else { return }
                    if currentIndex < LocationManager.shared.nearVoivodeshipsArray.count - 1 {
                        currentIndex += 1
                    } else {
                        shouldFetchMore = false
                    }
                }
            }
        }
    }
    
    func cancelFetch() {
        isFetching = false
        dataArray.removeAll()
        nearVoivodeshipsDataArray.removeAll()
        currentPage = 1
        totalItems = nil
        totalItemsNearVoivodeships = nil
    }
}
