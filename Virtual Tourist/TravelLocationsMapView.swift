//
//  TravelLocationsMapView.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 06.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapView: UIViewController {

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
//            mapView.region.center = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "latitude"), longitude: UserDefaults.standard.double(forKey: "longitude"))
//            mapView.region.span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "latitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "longitudeDelta"))
        }
        
        
    }

    
    @IBAction func holdGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            print("hold end")
        }
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            print("latitude \(tappedCoordinate.latitude) longitude \(tappedCoordinate.longitude)")
        }
    }
}

