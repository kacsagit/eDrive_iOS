//
//  MapViewController.swift
//  eDrive
//
//  Created by Kata on 26/11/16.
//  Copyright © 2016 Kata. All rights reserved.
//
import MapKit
import UIKit
import CoreLocation
import CoreData

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            mylocation=locations.first!.coordinate
            
            if let annot = annotation{
                if annot.coordinate.latitude == mylocation!.latitude && annot.coordinate.latitude == mylocation!.longitude  {}
                else{
                    mapView.removeAnnotation(annotation!)
                    annotation = CustomPointAnnotation()
                    annotation?.imageName="location.png"
                    let centerCoordinate = CLLocationCoordinate2D(latitude: (locations.first?.coordinate.latitude)!, longitude:(locations.first?.coordinate.longitude)!)
                    annotation?.coordinate = centerCoordinate
                    annotation?.title = "Your Location"
                    mapView.addAnnotation(annotation!)
                }
            }
            else{
                annotation = CustomPointAnnotation()
                annotation?.imageName="location.png"
                let centerCoordinate = CLLocationCoordinate2D(latitude: (locations.first?.coordinate.latitude)!, longitude:(locations.first?.coordinate.longitude)!)
                annotation?.coordinate = centerCoordinate
                annotation?.title = "Your Location"
                mapView.addAnnotation(annotation!)
            }
        }
    }
    
    
    
    
}

class MapViewController: UIViewController , MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var mylocation : CLLocationCoordinate2D?
    var annotation : CustomPointAnnotation?
    var list = [Places]()
    var annotations = [CustomPointAnnotation]()
    let managedObjectContext = AppDelegate.managedContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
      /*   var fetchedResultsController: NSFetchedResultsController<Places>!
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
        
        fetchedResultsController.delegate = self */

        
        mapView.delegate=self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
        }
        
        fetch()
        
    }
    
    func fetch() {
        
        let managedObjectContext = AppDelegate.managedContext
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Places.creationDate), ascending: false)
        let fetchRequest: NSFetchRequest<Places> = Places.fetchRequest()
        // rendezés creationDate szerint, csökkenő sorrendben
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let list1 = try managedObjectContext.fetch(fetchRequest)
            list = list1
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
        if annotations.count != 0{
            mapView.removeAnnotations(annotations)
            
       }
        for item in list {
            annotations = [CustomPointAnnotation]()
            let lat = item.latitude
            let long = item.longitude
            let annot = CustomPointAnnotation()
            annot.imageName="ChargingBattery.png"
            let centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat),longitude: CLLocationDegrees(long))
            annot.coordinate = centerCoordinate
            annot.title = "Your Location"
            mapView.addAnnotation(annot)
            annotations.append(annot)
            
        }
        
        
        
        
    }
    
    
    func mapView(_ mapView: MKMapView,  viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
        }
        else {
            anView?.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        anView?.image = UIImage(named:cpa.imageName)
        
        return anView
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

/* extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            fetch()
        case .delete:
            fetch()
        case .update:
            fetch()
        case .move:
            print("move")
            
        }
    }
} */


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}


