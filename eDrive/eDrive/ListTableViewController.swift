//
//  ListTableViewController.swift
//  eDrive
//
//  Created by Kata on 24/11/16.
//  Copyright © 2016 Kata. All rights reserved.
//

import UIKit
import CoreData


extension ListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
              let cell = tableView.cellForRow(at: indexPath!)! as! ListTableViewCell
              configure(cell: cell, at: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
        myMapView.fetch()
    }
}


class ListTableViewController: UITableViewController {

    var fetchedResultsController: NSFetchedResultsController<Places>!
    
    let managedObjectContext = AppDelegate.managedContext
    
    let myMapView = MapViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // fetchNotebooks()
        let fetchRequest: NSFetchRequest<Places> = Places.fetchRequest()
        
        // rendezés creationDate szerint, csökkenő sorrendben
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Places.creationDate), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // egyszerre max 30 Note lekérdezése
        fetchRequest.fetchBatchSize = 30
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
  /*  func fetchNotebooks() {
        let managedObjectContext = AppDelegate.managedContext
        
        let fetchRequest: NSFetchRequest<Places> = Places.fetchRequest()
        
        do {
            let places = try managedObjectContext.fetch(fetchRequest)
            self.places = places
        } catch {
            print("Couldn't fetch!")
        }
    }*/


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        //return places.count
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        
        
            configure(cell: cell, at: indexPath)

        return cell
    }
    
    func configure(cell: ListTableViewCell, at indexPath: IndexPath) {
        let place = fetchedResultsController.object(at: indexPath)
        cell.placeName.text = place.name
        cell.latName.text=String(place.latitude)
        cell.longName.text=String(place.longitude)

    }

    
    
        
        
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
           
            let place = fetchedResultsController.object(at: indexPath)
            self.managedObjectContext.delete(place)
            
           // tableView.deleteRows(at: [indexPath], with: .fade)
        } /* else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }   */
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
            if segue.identifier == "AddItemSeque" {
                let vc = segue.destination as? AddItemViewController
                vc?.delegate = self
            }
        

    }
    

}


extension ListTableViewController: AddItemViewControllerDelegate{
    // Called when the user presses the Send button to issue sending the message
    func addItemViewControllerDidSend(_ viewController: AddItemViewController){

        let managedObjectContext = AppDelegate.managedContext
        
        let note = Places(context: managedObjectContext)
        note.name = viewController.placeText.text
        note.longitude = (viewController.longText.text! as NSString).floatValue
        note.latitude = (viewController.latText.text! as NSString).floatValue
        note.creationDate = NSDate()
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    // Called when the user presses the Cancel button to cancel the message composer
    func addItemViewControllerDidCancel(_ viewController: AddItemViewController){
    
    }
}






