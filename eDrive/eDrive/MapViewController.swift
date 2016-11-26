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
            print("location\(locations.first!.coordinate.latitude)")
            mylocation=locations.first!.coordinate
            
            if let annot = annotation{
                if annot.coordinate.latitude == mylocation!.latitude && annot.coordinate.latitude == mylocation!.longitude  {}
                else{
                    mapView.removeAnnotation(annotation!)
                    annotation = CustomPointAnnotation()
                    annotation?.imageName="ChargingBattery.png"
                    let centerCoordinate = CLLocationCoordinate2D(latitude: (locations.first?.coordinate.latitude)!, longitude:(locations.first?.coordinate.longitude)!)
                    annotation?.coordinate = centerCoordinate
                    annotation?.title = "Your Location"
                    mapView.addAnnotation(annotation!)
                }
            }
            else{
                annotation = CustomPointAnnotation()
                annotation?.imageName="ChargingBattery.png"
                let centerCoordinate = CLLocationCoordinate2D(latitude: (locations.first?.coordinate.latitude)!, longitude:(locations.first?.coordinate.longitude)!)
                annotation?.coordinate = centerCoordinate
                annotation?.title = "Your Location"
                mapView.addAnnotation(annotation!)
            }
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        print("delegate called")
        
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
    
}

class MapViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var mylocation : CLLocationCoordinate2D?
    var annotation : CustomPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
        }
        
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

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}
