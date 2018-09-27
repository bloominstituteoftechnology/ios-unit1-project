//
//  BookSearchController.swift
//  Book List
//
//  Created by Dillon McElhinney on 9/25/18.
//  Copyright © 2018 Dillon McElhinney. All rights reserved.
//

import Foundation

class BookSearchController {
    
    // MARK: - Properties
    private let baseURL = URL(string: "https://www.googleapis.com/books/v1")!
    private(set) var searchResults: [BookRepresentation] = []
    
    func resetResults() {
        searchResults = []
    }
    
    // MARK: - Networking
    /// Performs a search with the given search term
    func performSearch(with term: String, page: Int = 0, reset: Bool = true, completion: @escaping CompletionHandler = { _ in }) {
        let numberOfResults = 20
        let startIndex = (numberOfResults * page)
        let requestURL = baseURL.appendingPathComponent("volumes")
        
        let searchQuery = URLQueryItem(name: "q", value: term)
        let maxResultsQuery = URLQueryItem(name: "maxResults", value: "\(numberOfResults)")
        let startIndexQuery = URLQueryItem(name: "startIndex", value: "\(startIndex)")
        
        var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [searchQuery, maxResultsQuery, startIndexQuery]
        guard let url = components?.url else {
            NSLog("Error getting url from components.")
            completion(NSError())
            return
        }
        let request = URLRequest(url: url)
        
        GoogleBooksAuthorizationClient.shared.addAuthorization(to: request) { (request, error) in
            if let error = error {
                NSLog("Error adding authorization to GET search request: \(error)")
                completion(error)
                return
            }
            
            guard let request = request else { return }
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
                if let error = error {
                    NSLog("Error GETting search results: \(error)")
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    NSLog("No data was returned.")
                    completion(NSError())
                    return
                }
                
                do {
                    let results = try JSONDecoder().decode(BooksResults.self, from: data)
                    self.searchResults += results.items ?? []
                } catch {
                    NSLog("Error decoding search results: \(error)")
                }
                
                completion(nil)
                return
            }).resume()
        }
    }
    
}