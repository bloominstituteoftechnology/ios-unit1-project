//
//  BookshelvesTableViewController.swift
//  Books
//
//  Created by Linh Bouniol on 8/21/18.
//  Copyright © 2018 Linh Bouniol. All rights reserved.
//

import UIKit
import CoreData

class BookshelvesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    let bookController = BookController()
    
    @IBAction func addBookshelf(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Bookshelf", message: nil, preferredStyle: .alert)
        alert.addTextField { (titleTextField) in
            titleTextField.placeholder = "Bookshelf Name:"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            guard let name = alert.textFields![0].text, name.count > 0 else { return }
            
            self.bookController.createBookshelf(with: name)
            
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Bookshelf> = {
        // Create fetchRequest from Entry object
        let fetchRequest: NSFetchRequest<Bookshelf> = Bookshelf.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Get CoreDataStack's mainContext
        let moc = CoreDataStack.shared.mainContext
        
        // Initialize NSFetchedResultsController
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: moc,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        // Set this VC as frc's delegate
        frc.delegate = self
        
        try! frc.performFetch()
        
        return frc
    }()
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        // NSFetchedResultsChangeType has four types: insert, delete, move, update
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            //            tableView.moveRow(at: oldIndexPath, to:  newIndexPath)
            // Doesn't work any more?
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookshelfCell", for: indexPath)

        let bookshelf = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = bookshelf.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookshelf = fetchedResultsController.object(at: indexPath)
            bookController.delete(bookshelf: bookshelf)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let booksTVC = segue.destination as? BooksTableViewController {
            booksTVC.bookController = bookController
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            booksTVC.bookshelf = fetchedResultsController.object(at: indexPath)
            
//            if segue.identifier == "ShowBookshelfDetail" {
//                guard let indexPath = tableView.indexPathForSelectedRow else { return }
//                booksTVC.bookshelf = fetchedResultsController.object(at: indexPath)
//            }
        }
    }
}
