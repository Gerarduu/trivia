//
//  ScoresViewController.swift
//  trivia
//
//  Created by Gerard Riera Puig on 26/09/2019.
//  Copyright © 2019 Gerard Riera Puig. All rights reserved.
//

import UIKit
import CoreData

class ScoresViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Swift
        tableView.tableFooterView = UIView(frame: .zero)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let game = fetchedResultsController.object(at: indexPath)
        
        configureCell(cell, withGame: game)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let context = fetchedResultsController.managedObjectContext
            
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                
                try context.save()
            } catch {
                
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withGame game: Game) {
        
        cell.textLabel!.text = game.player1Stats!.description + " - " + game.player2Stats!.description
        cell.detailTextLabel?.textColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0) //Color of detail text
        cell.detailTextLabel!.text = game.date?.description //Detail text of the cell
    }
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Game> {
        
        if _fetchedResultsController != nil {
            
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        aFetchedResultsController.delegate = self
        
        _fetchedResultsController = aFetchedResultsController
        
        do {
            
            try _fetchedResultsController!.performFetch()
        } catch {
            
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Game>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            
            configureCell(tableView.cellForRow(at: indexPath!)!, withGame: anObject as! Game)
        case .move:
            
            configureCell(tableView.cellForRow(at: indexPath!)!, withGame: anObject as! Game)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
