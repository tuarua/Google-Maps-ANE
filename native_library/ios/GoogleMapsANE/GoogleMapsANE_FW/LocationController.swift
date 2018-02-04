/*
 *  Copyright 2018 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

import GoogleMaps
import FreSwift

internal class LocationController: NSObject, FreSwiftController, CLLocationManagerDelegate {
    var context: FreContextSwift!
    var TAG: String? = "LocationController"
    private var locationManager = CLLocationManager()
    private var permissionsGranted: Bool = false
    
    convenience init(context: FreContextSwift) {
        self.init()
        self.context = context
    }
    
    func requestPermissions() {
        let requiredKey = "NSLocationAlwaysUsageDescription"
        var pListDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            pListDict = NSDictionary(contentsOfFile: path)
        }
        var hasRequiredInfoAddition = false
        if let dict = pListDict {
            for key in dict.allKeys {
                if let k = key as? String, k == requiredKey {
                    hasRequiredInfoAddition = true
                    break
                }
            }
        }
        if hasRequiredInfoAddition {
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
        } else {
            warning("Please add \(requiredKey) to InfoAdditions in your AIR manifest")
        }
    }
    
    func showUserLocation() {
        if permissionsGranted {
            locationManager.requestLocation()
        } else {
            warning("No permissions to locate user")
        }
    }
    
    func reverseGeocodeLocation(coordinate: CLLocationCoordinate2D) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            if let error = error {
                self.sendEvent(name: Constants.ON_ADDRESS_LOOKUP_ERROR, value: error.localizedDescription)
                return
            }
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            
            var props: [String: Any] = Dictionary()
            props["latitude"] = location.coordinate.latitude
            props["longitude"] = location.coordinate.longitude
            props["formattedAddress"] = ""
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                props["formattedAddress"] = formattedAddress.joined(separator: ", ")
            }
            props["name"] = addressDict["Name"] as? String
            props["street"] = addressDict["Thoroughfare"] as? String
            props["city"] = addressDict["City"] as? String
            props["zip"] = addressDict["ZIP"] as? String
            props["country"] = addressDict["Country"] as? String
            
            let json = JSON(props)
            self.sendEvent(name: Constants.ON_ADDRESS_LOOKUP, value: json.description)
        })
    }
    
    func forwardGeocodeLocation(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: {placemarks, error in
            if let error = error {
                self.sendEvent(name: Constants.ON_ADDRESS_LOOKUP_ERROR, value: error.localizedDescription)
                return
            }
            guard let location = placemarks?[0].location, let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            
            var props: [String: Any] = Dictionary()
            props["latitude"] = location.coordinate.latitude
            props["longitude"] = location.coordinate.longitude
            props["formattedAddress"] = ""
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                props["formattedAddress"] = formattedAddress.joined(separator: ", ")
            }
            props["name"] = addressDict["Name"] as? String
            props["street"] = addressDict["Thoroughfare"] as? String
            props["city"] = addressDict["City"] as? String
            props["zip"] = addressDict["ZIP"] as? String
            props["country"] = addressDict["Country"] as? String
            
            let json = JSON(props)
            self.sendEvent(name: Constants.ON_ADDRESS_LOOKUP, value: json.description)
            
        })
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        var props: [String: Any] = Dictionary()
        props["latitude"] = location.coordinate.latitude
        props["longitude"] = location.coordinate.longitude
        let json = JSON(props)
        sendEvent(name: Constants.LOCATION_UPDATED, value: json.description)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var props: [String: Any] = Dictionary()
        props["status"] = status.rawValue
        switch status {
        case .restricted:
            props["status"] = Constants.PERMISSION_RESTRICTED
        case .notDetermined:
            props["status"] = Constants.PERMISSION_NOT_DETERMINED
        case .denied:
            props["status"] = Constants.PERMISSION_DENIED
        case .authorizedAlways:
            props["status"] = Constants.PERMISSION_ALWAYS
            permissionsGranted = true
        case .authorizedWhenInUse:
            props["status"] = Constants.PERMISSION_WHEN_IN_USE
            permissionsGranted = true
        }
        
        if permissionsGranted {
            manager.startUpdatingLocation()
            manager.distanceFilter = 50
        }
        
        let json = JSON(props)
        sendEvent(name: Constants.ON_PERMISSION_STATUS, value: json.description)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        trace("locationManager:didFailWithError", error.localizedDescription) //TODO
    }
}
