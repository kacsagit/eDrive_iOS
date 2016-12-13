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
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let newLocation = locations.last else {
            return
        }
        
        
        if -newLocation.timestamp.timeIntervalSinceNow > 5.0 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if lastLocation?.coordinate.latitude == newLocation.coordinate.latitude && lastLocation?.coordinate.longitude == newLocation.coordinate.longitude{
            return
        }
        
       // if lastLocation == nil || lastLocation!.horizontalAccuracy < newLocation.horizontalAccuracy {
        
        
        if locations.last != nil {
            mylocation=newLocation.coordinate
            lastLocation = newLocation
            
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
            showRouteOnMap()
        }
    }
    
    
    
    
    
    
}

class MapViewController: UIViewController , MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    var mylocation : CLLocationCoordinate2D?
    var annotation : CustomPointAnnotation?
    var list = [Places]()
    var annotations = [CustomPointAnnotation]()
    let managedObjectContext = AppDelegate.managedContext
    var item : Places?
    var lastroute : MKPolyline?
    var newCoordinates: CLLocationCoordinate2D?
    
    @IBAction func Clear(_ sender: AnyObject) {
        if lastroute != nil {
            item = nil
            mapView.remove((lastroute)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        mapView.delegate=self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longpress(gestureRecognizer:)))
        
        lpgr.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(lpgr)
        
        NotificationCenter.default.addObserver(self, selector:  #selector(MapViewController.notif(_:)), name: NSNotification.Name("dbUpdated"), object: nil)
        
    }
    func notif(_ notification: NSNotification) {
        item = notification.object as! Places?
    
    }
    
    
    func longpress(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        print("long")
        
        
        let point = gestureRecognizer.location(in: self.view)
        newCoordinates = mapView.convert(point, toCoordinateFrom: mapView)
        
        
        self.performSegue(withIdentifier: "NamePlace", sender: self)
        
       /* let annot = CustomPointAnnotation()
        annot.imageName="ChargingBattery.png"
        annot.coordinate = newCoordinates!
        annot.title = "uj"
        mapView.addAnnotation(annot)*/

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NamePlace" {
            
            let lat = newCoordinates!.latitude
            let long = newCoordinates!.longitude
            
            let viewController = segue.destination as! AddItemViewController
            viewController.delegate = self
            viewController.latitude = String(lat)
            viewController.longitude = String(long)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetch()
        showRouteOnMap()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      // NotificationCenter.default.removeObserver(self, name:  NSNotification.Name("dbUpdated"), object: nil)
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
        annotations = [CustomPointAnnotation]()
        for item in list {
            let lat = item.latitude
            let long = item.longitude
            let annot = CustomPointAnnotation()
            annot.imageName="ChargingBattery.png"
            let centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat),longitude: CLLocationDegrees(long))
            annot.coordinate = centerCoordinate
            annot.title = item.name
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
    
    
    func showRouteOnMap() {
        if let destination=item {
            if annotation != nil {
            let destinationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(destination.latitude),longitude: CLLocationDegrees(destination.longitude))

        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: (annotation?.coordinate)!, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: (destinationCoordinate), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate{ [weak self] response, error in
            guard let unwrappedResponse = response else { return }
            
            if (unwrappedResponse.routes.count > 0) {
                if self?.lastroute != nil {
                    self?.mapView.remove((self?.lastroute!)!)
                }
                self?.mapView.add(unwrappedResponse.routes[0].polyline)
                self?.mapView.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
                self?.lastroute = unwrappedResponse.routes[0].polyline
            }
            }
        }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        return MKPolylineRenderer()
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

 extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    }
    
 /*   func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
    }*/
}


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

extension MapViewController: AddItemViewControllerDelegate{
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


