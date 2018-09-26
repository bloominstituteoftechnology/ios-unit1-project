//
//  BookshelfController.swift
//  Books
//
//  Created by Daniela Parra on 9/25/18.
//  Copyright © 2018 Daniela Parra. All rights reserved.
//

import Foundation
import CoreData

class BookshelfController {

    // MARK: - CRUD Methods
    
    func createBookshelf(bookshelfRepresentation: BookshelfRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let bookshelf = Bookshelf(bookshelfRepresentation: bookshelfRepresentation, context: context)
        
        if bookshelfRepresentation.volumeCount != 0 {
            performRequestForTheirVolumes(bookshelfRep: bookshelfRepresentation, bookshelf: bookshelf, context: context)
        }
        
        do {
            try context.save()
        } catch {
            NSLog("Error saving newly created volume: \(error)")
        }
        //save to Persistent Store
    }
    
    // MARK: - Networking (Books API)
    
    //Add volume to a bookshelf.
    
    //Update volume in a bookshelf.
    
    //Delete volume from a bookshelf.
    
    //Move volume to another bookshelf.
    
    
    //Get all bookshelves from user's profile.
    func fetchAllBookshelves(completion: @escaping (Error?) -> Void = { _ in }) {
        
        let requestURL = bookshelvesBaseURL
        let request = URLRequest(url: requestURL)
        
        GoogleBooksAuthorizationClient.shared.addAuthorization(to: request) { (request, error) in
            if let error = error {
                NSLog("Error adding authorization to request: \(error)")
                return
            }
            guard let request = request else { return }
            
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    NSLog("Error fetching data for bookshelves: \(error)")
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    NSLog("No data returned from data task")
                    completion(NSError())
                    return
                }

                do {
                    let searchResults = try JSONDecoder().decode(BookshelfResults.self, from: data)
                    self.bookshelfRepresentations = searchResults.items
                    print(self.bookshelfRepresentations)
                    
                    for bookshelfRep in self.bookshelfRepresentations {
                        self.createBookshelf(bookshelfRepresentation: bookshelfRep)
                    }
                } catch {
                    NSLog("Error decoding data: \(error)")
                    completion(error)
                    return
                }
                completion(nil)
            }.resume()
        }
    }
    
    // MARK: - Core Data Persistence
    
    //Fetch all bookshelves.
    
    //Put book in bookshelf.
    
    //Delete book from bookshelf.
    
    private func performRequestForTheirVolumes(bookshelfRep: BookshelfRepresentation, bookshelf: Bookshelf, context: NSManagedObjectContext) {
        
        let requestURL = betterBaseURL.appendingPathComponent(String(bookshelfRep.id)).appendingPathComponent("volumes")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data for volumes of bookshelves: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                return
            }
            
            do {
                let volumeResults = try JSONDecoder().decode(VolumeSearchResults.self, from: data)
                let volumeReps = volumeResults.items
                for volumeRep in volumeReps {
                    self.volumeController.createVolume(from: volumeRep, bookshelf: bookshelf, context: context)
                }
                
            } catch {
                NSLog("Error decoding data: \(error)")
                return
            }
        }.resume()
    }
    
    var bookshelfRepresentations: [BookshelfRepresentation] = []
    let volumeController = VolumeController()
    
    private let userId = "111772930908716729442"
    private let bookshelvesBaseURL = URL(string: "https://www.googleapis.com/books/v1/mylibrary/bookshelves")!
    private let betterBaseURL = URL(string: "https://www.googleapis.com/books/v1/mylibrary/bookshelves")!
}
