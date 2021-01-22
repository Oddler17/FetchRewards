//
//  APIService.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import Foundation

/*
 Also errors are not handled correctly in the whole code.
 
 */
enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
    case cantReadFromFile = "Error reading from file"
    case fileDoesNotExist = "File does not exist"
}

/*
 Protocols should be not only here.
 Here I just show how protocols-based code should be implemented.
 I skipped it in most other places just to save time for now.
 */
protocol APIServiceProtocol {
    func loadNextPageData(currentLastPage: Int?, completionHandler: @escaping (Data) -> ())
}

class APIService: APIServiceProtocol {
    
    /*
     In our case we use only one URL.
     Otherwise there should be separate file with enums of parts of the url
     Which is some kind of service to create final url based on it's parts
     */
    private struct Constants {
        static let baseUrl = "https://api.seatgeek.com/2"
        static let eventsEndpoint = "/events"
        static let clientIdParameterName = "client_id"
        static let clientId = "MjE1MTA2MTl8MTYxMTE2NjIzMi4yMDA2OTA3"
        static let questionMarkSeparator = "?"
        static let equalToSeparator = "="
        static let andSeparator = "&"
        static let pageParameter = "page"
        static let defaultPageNumber = 1
    }
    
    private var isLoading = false
    
    func loadNextPageData(currentLastPage: Int? = Constants.defaultPageNumber, completionHandler: @escaping (Data) -> ()) {
        if !shouldLoadMoreData() {
            print("Error: Currently loading...")
            return
        }
        isLoading = true

        let baseString = Constants.baseUrl + Constants.eventsEndpoint
        let clientIdParameterString = Constants.clientIdParameterName + Constants.equalToSeparator + Constants.clientId
        let pageParameterString = Constants.pageParameter + Constants.equalToSeparator + String(currentLastPage ?? Constants.defaultPageNumber)
        let urlString = baseString + Constants.questionMarkSeparator + clientIdParameterString + Constants.andSeparator + pageParameterString
        
        guard let url = URL(string: urlString) else {
            print("Error: URL String is not correct URL")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard error == nil else {
                print("Error: \(String(describing: error?.localizedDescription))")
                self?.isLoading = false
                return
            }
            guard let data = data else {
                print("Error: No data found")
                self?.isLoading = false
                return
            }
            self?.isLoading = false
            completionHandler(data)
        }
        task.resume()
    }
    
    /*
     Technically we need to check also if we already downloaded all possible articles (based on the "total" number in "meta")
     Will not do it to simplify the code, also this number is very large.
     This method created to be extended in the future (possibly)
     */
    private func shouldLoadMoreData() -> Bool {
        return !isLoading
    }
}

