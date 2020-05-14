//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 06.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    let travelLocationsMapViewDelegate: TravelLocationsMapViewDelegate = TravelLocationsMapViewDelegate()
    var pins: [Pin] = []
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        travelLocationsMapViewDelegate.parent = self
        mapView.delegate = travelLocationsMapViewDelegate
        
        // restore settings for region & zoom level
        if UserDefaults.standard.bool(forKey: "didStoreLocation") {
            let center = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "latitude"), longitude: UserDefaults.standard.double(forKey: "longitude"))
            let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "latitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "longitudeDelta"))
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
        
        // load pins from data store
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            // to do: add pins to map
            for pin in pins {
                let annotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                
                annotation.coordinate = coordinate
                annotation.title = pin.location
                mapView.addAnnotation(annotation)
            }
        }
        
    }

    func savePin(coordinate: CLLocationCoordinate2D){
        let newPin = Pin(context: dataController.viewContext)
        newPin.longitude = coordinate.longitude
        newPin.latitude = coordinate.latitude
        newPin.location = "Long: \(coordinate.longitude) Lat: \(coordinate.latitude)"
        // put error handling here
        try? dataController.viewContext.save()
    }
    
    
    @IBAction func holdGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            if sender.state == .ended {
                let locationInView = sender.location(in: mapView)
                let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = tappedCoordinate
                annotation.title = "Long: \(tappedCoordinate.longitude) Lat: \(tappedCoordinate.latitude)"
                mapView.addAnnotation(annotation)
                // add retrieval here
                //savePin(coordinate: tappedCoordinate)
            }
        }
    }
}

