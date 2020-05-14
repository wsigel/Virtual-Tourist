//
//  TravelLocationsMapViewDelegate.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 06.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class TravelLocationsMapViewDelegate: NSObject, MKMapViewDelegate {
    
    var parent: TravelLocationsMapViewController?
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
////        if !AppDelegate.isNetworkAvailable() {
////            ErrorAlertController.showAlertController(parent: parent, title: "Network Connectivity", message: "Unable to open URL: no network available")
////            return
////        }
//        if control == view.rightCalloutAccessoryView {
//            let app = UIApplication.shared
//            if let toOpen = view.annotation?.subtitle! {
//                if toOpen != "" {
//                    app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
//                }
//            }
//
//
//            //parent!.performSegue(withIdentifier: "showCollection", sender: nil)
//            //print("callout tapped")
//
//        }
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate {
            let flowLayout = UICollectionViewLayout()
            let controller2Present = TravelLocationsCollectionViewController(collectionViewLayout: flowLayout)
            
            controller2Present.selectedCoordinate = coordinate
            
            controller2Present.dataController = parent?.dataController
            parent?.present(controller2Present, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(true, forKey: "didStoreLocation")
        let newRegion = mapView.region
        let newCenter = newRegion.center
        let newSpan = newRegion.span
        UserDefaults.standard.set(newCenter.latitude, forKey: "latitude")
        UserDefaults.standard.set(newCenter.longitude, forKey: "longitude")
        UserDefaults.standard.set(newSpan.latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.set(newSpan.longitudeDelta, forKey: "longitudeDelta")
    }
    
}
