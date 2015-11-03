//
//  LGMapViewController.swift
//  LGWeChatKit
//
//  Created by jamy on 10/29/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import MapKit

protocol LGMapViewControllerDelegate {
    func mapViewController(controller: LGMapViewController, didSelectLocationSnapeShort image: UIImage)
    func mapViewController(controller: LGMapViewController, didCancel error: NSError?)
}

class LGMapViewController: UIViewController {

    var tableView: UITableView!
    var mapView: MKMapView!
    var geocoder: CLGeocoder!
    var localSearch: MKLocalSearch!
    var myAnnotation: placeAnnotation!
    var locationManager: CLLocationManager!
    
    var mapItems = [MKMapItem]()
    
    var selectMapItem: MKMapItem?
    var delegate: LGMapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()

        tableView = UITableView(frame: view.bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIndentifier)
        
        mapView = MKMapView()
        
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
        
        view.addSubview(tableView)
        view.addSubview(mapView)
        // Do any additional setup after loading the view.
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 64))
        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.5, constant: -32))
        
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: 0))
        
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        myAnnotation = placeAnnotation(coordinate: CLLocationCoordinate2DMake(31.203694, 121.545212), title: "", subtitle: "")
        mapView.addAnnotation(myAnnotation)
        
        geocoder = CLGeocoder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let item = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: "dismissView")
        self.navigationItem.leftBarButtonItem = item
        
        let send = UIBarButtonItem(title: "发送", style: .Plain, target: self, action: "send")
        self.navigationItem.rightBarButtonItem = send
    }
    
    func dismissView() {
        self.delegate?.mapViewController(self, didCancel: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func send() {
        let option = MKMapSnapshotOptions()
        if mapItems.count > 0 {
            if selectMapItem != nil {
                option.region.center = (selectMapItem?.placemark.coordinate)!
            } else {
                option.region.center = ((mapItems.first! as MKMapItem).placemark.coordinate)
            }
            option.region = mapView.region
        }
        let snape = MKMapSnapshotter(options: option)
        snape.startWithCompletionHandler { (snapeShort, error) -> Void in
            if error == nil {
                self.delegate?.mapViewController(self, didSelectLocationSnapeShort: (snapeShort?.image)!)
                self.dismissView()
            }
        }
    }
}

private let reuseIndentifier = "mapViewCell"
extension LGMapViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIndentifier, forIndexPath: indexPath)
        
        let mapItem = mapItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let mapItem = mapItems[indexPath.row]
        let placeMark = mapItem.placemark
        selectMapItem = mapItem
        mapView.setCenterCoordinate(placeMark.coordinate, animated: true)
       
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}


extension LGMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("get location")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView?
        if annotation .isKindOfClass(placeAnnotation.self) {
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView!.animatesDrop = true
                annotationView!.canShowCallout = true
            }
            return annotationView!
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let point = CGPointMake(mapView.center.x, mapView.center.y - 64)
        let centerCoordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
        mapView.removeAnnotation(myAnnotation)
        myAnnotation = placeAnnotation(coordinate: centerCoordinate, title: "", subtitle: "")
        mapView.addAnnotation(myAnnotation)
        
        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placeMarks, error) -> Void in
            if placeMarks?.count > 0 {
                self.startSearch(centerCoordinate, name: (placeMarks?.first?.name)!)
            }
        }
    }
    
    func startSearch(coordinate: CLLocationCoordinate2D, name: String) {
        if localSearch != nil {
            if localSearch.searching {
                localSearch.cancel()
            }
        }
        
        let span = MKCoordinateSpanMake(0.412872, 0.709862)
        let newRegion = MKCoordinateRegion(center: coordinate, span: span)
        let request = MKLocalSearchRequest()
        request.region = newRegion
        request.naturalLanguageQuery = name
        let complectionHandle: MKLocalSearchCompletionHandler = { (response, error) -> Void in
            if error == nil {
                for mapitem in (response?.mapItems)! {
                    NSLog("%@", mapitem.name!)
                }
                self.mapItems = (response?.mapItems)!
                self.tableView.reloadData()
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        if localSearch != nil {
            localSearch = nil
        }
        localSearch = MKLocalSearch(request: request)
        localSearch.startWithCompletionHandler(complectionHandle)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
}


