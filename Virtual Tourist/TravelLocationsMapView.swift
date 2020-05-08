//
//  TravelLocationsMapView.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 06.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapView: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    let travelLocationsMapViewDelegate: TravelLocationsMapViewDelegate = TravelLocationsMapViewDelegate()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = travelLocationsMapViewDelegate
        
        
        if UserDefaults.standard.bool(forKey: "didStoreLocation") {
            let center = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "latitude"), longitude: UserDefaults.standard.double(forKey: "longitude"))
            let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "latitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "longitudeDelta"))
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
        
        
    }

    
    
    @IBAction func holdGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            if sender.state == .ended {
                let locationInView = sender.location(in: mapView)
                let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                let location = CLLocation(latitude: tappedCoordinate.latitude, longitude: tappedCoordinate.longitude)
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location, completionHandler: handleReverseGeocoding(placemarks:error:))
            }
        }
    }
    
    func handleReverseGeocoding(placemarks: [CLPlacemark]?, error: Error?) -> Void {
        if error != nil {
            // error message goes here
        }
        
        guard let placemarks = placemarks else {
            return
        }
        if placemarks.count >= 1 {
            if let placemark = placemarks.first {
                let cityAndCountry = placemark.locality! + ", " + placemark.country!
                let annotation = MKPointAnnotation()
                annotation.coordinate = placemark.location!.coordinate
                annotation.title = cityAndCountry
                mapView.addAnnotation(annotation)
            }
        }
    }
    
}

