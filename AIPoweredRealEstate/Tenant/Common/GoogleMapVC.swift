//
//  GoogleMapVC.swift
//  AIPoweredRealEstate
//

import UIKit
import CoreLocation
import GoogleMaps

class GoogleMapVC: UIViewController {

    @IBOutlet weak var mainView: UIView!

    var map = GMSMapView()
    var lat: Double = 0.0
    var long: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationManager.shared.updatedLocation = { [weak self] location in
            guard let self else { return }
            self.lat = location.coordinate.latitude
            self.long = location.coordinate.longitude
            self.setMap(location: location)
        }
        LocationManager.shared.checkAuthorizationSts()
        
    }

    func setMap(location: CLLocation) {
       
        guard mainView != nil else { return }

        let camera = GMSCameraPosition(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15
        )
        
        let option = GMSMapViewOptions()
        
        option.camera = camera

        map.removeFromSuperview()
        map = GMSMapView(options: option)
        map.frame = mainView.bounds
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.addSubview(map)

        setMarker(location: location)
        
    }

    func setMarker(location: CLLocation) {
        let marker = GMSMarker()
        marker.position = location.coordinate
        marker.title = "Current Location"
        LocationManager.shared.getFullAddress(location: location) { fullAddress in
            marker.snippet = fullAddress
        }
        marker.icon = UIImage(systemName: "location.fill")
        marker.map = map
    }
    
}

/*
 "I'm looking for a 3-bedroom furnished apartment in Piantini or Naco with full power backup, under $1,500."

 */
