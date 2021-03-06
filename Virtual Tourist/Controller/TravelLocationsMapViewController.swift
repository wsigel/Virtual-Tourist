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
    var pins: [Pin] = []
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // check availability of api_key for flickr
        if Secret.apiKey == "" {
            let alertController = UIAlertController(title: "Missing api key", message: "Will abort execution due to missing flickr api key", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
                exit(-1)
            }))
            present(alertController, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
        mapView.delegate = self
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
            // add pins to map
            for pin in pins {
                let annotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    @IBAction func holdGesture(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .ended {
                let locationInView = sender.location(in: mapView)
                let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = tappedCoordinate
                annotation.title = "Long: \(tappedCoordinate.longitude) Lat: \(tappedCoordinate.latitude)"
                mapView.addAnnotation(annotation)
                mapView.deselectAnnotation(annotation, animated: true)
                let geoQuery = FlickrGeoQuery(longitude: tappedCoordinate.longitude, latitude: tappedCoordinate.latitude, page: 1)
                FlickrClient.searchForPhotos(geoQuery: geoQuery, completion: handlePinAction(response:coordinate:error:))
            }
    }
    
    func handlePinAction(response: PhotosResponse?, coordinate: CLLocationCoordinate2D?, error: Error?){
        if error == nil {
            guard let latitude = coordinate?.latitude, let longitude = coordinate?.longitude, let collection = response else {
                return
            }
            
            let newPin = Pin(context: dataController.viewContext)
            newPin.latitude = latitude
            newPin.longitude = longitude
            newPin.page = Int64(collection.photos.page)
            newPin.pages = Int64(collection.photos.pages)
            
            
            let photoCore = collection.photos.photo
            if photoCore.count > 0 {
                for individualPhoto in photoCore {
                    let photo = Photo(context: dataController.viewContext)
                    photo.id = individualPhoto.id
                    photo.secret = individualPhoto.secret
                    photo.farm = Int64(individualPhoto.farm)
                    photo.server = individualPhoto.server
                    newPin.addToPhotos(photo)
                }
            }
            try? dataController.viewContext.save()
        } else {
            fatalError("There was an error when searching for photos: \(error!)")
        }
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
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
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            let pin = getPinFor(coordinate: coordinate)
            vc.currentPin = pin
            vc.selectedCoordinate = coordinate
            vc.dataController = dataController
            mapView.deselectAnnotation(view.annotation, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getPinFor(coordinate: CLLocationCoordinate2D) -> Pin {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let latPredicate = NSPredicate(format: "latitude == \(coordinate.latitude)")
        let longPredicate = NSPredicate(format: "longitude == \(coordinate.longitude)")
        let coordinatesPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, longPredicate])
        
        fetchRequest.predicate = coordinatesPredicate
        fetchRequest.includesSubentities = true
        do {
             let pin = try dataController.viewContext.fetch(fetchRequest)
            return pin.first!
        } catch {
            fatalError("Could not retrieve Pin for coordinates \(error.localizedDescription)")
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
