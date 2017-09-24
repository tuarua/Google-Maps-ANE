/*
 *  Copyright 2017 Tua Rua Ltd.
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

import Foundation
import CoreImage
import GoogleMaps
import FreSwift

public class SwiftController: NSObject, FreSwiftMainController, CLLocationManagerDelegate {
    public var TAG: String? = "SwiftController"
    public var context: FreContextSwift!
    public var functionsToSet: FREFunctionMap = [:]
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var userLocation: CLLocation?
    private var mapControllerGMS: GMSMapController?
    private var mapControllerMK: MKMapController?

    private var asListeners: Array<String> = []
    private var listenersAddedToMapC: Bool = false
    private var isAdded: Bool = false

    public enum MapProvider: Int {
        case google
        case apple
    }

    private var mapProvider: MapProvider = MapProvider.google

    // Must have this function. It exposes the methods to our entry ObjC.
    @objc public func getFunctions(prefix: String) -> Array<String> {

        functionsToSet["\(prefix)isSupported"] = isSupported
        functionsToSet["\(prefix)init"] = initController
        functionsToSet["\(prefix)initMap"] = initMap
        functionsToSet["\(prefix)addMarker"] = addMarker
        functionsToSet["\(prefix)updateMarker"] = updateMarker
        functionsToSet["\(prefix)removeMarker"] = removeMarker
        functionsToSet["\(prefix)clear"] = clear
        functionsToSet["\(prefix)setViewPort"] = setViewPort
        functionsToSet["\(prefix)setVisible"] = setVisible
        functionsToSet["\(prefix)moveCamera"] = moveCamera
        functionsToSet["\(prefix)setStyle"] = setStyle
        functionsToSet["\(prefix)setMapType"] = setMapType
        functionsToSet["\(prefix)requestLocation"] = requestLocation
        functionsToSet["\(prefix)addEventListener"] = addEventListener
        functionsToSet["\(prefix)removeEventListener"] = removeEventListener
        functionsToSet["\(prefix)zoomIn"] = zoomIn
        functionsToSet["\(prefix)zoomOut"] = zoomOut
        functionsToSet["\(prefix)zoomTo"] = zoomTo
        functionsToSet["\(prefix)setAnimationDuration"] = setAnimationDuration
        functionsToSet["\(prefix)addCircle"] = addCircle
        functionsToSet["\(prefix)showInfoWindow"] = showInfoWindow
        functionsToSet["\(prefix)hideInfoWindow"] = hideInfoWindow
        functionsToSet["\(prefix)setBounds"] = setBounds

        var arr: Array<String> = []
        for key in functionsToSet.keys {
            arr.append(key)
        }
        return arr
    }

    func addEventListener(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let type = String(argv[0]) else {
            return ArgCountError(message: "addEventListener").getError(#file, #line, #column)
        }

        if mapControllerMK == nil && mapControllerGMS == nil {
            asListeners.append(type)
        } else {
            if !listenersAddedToMapC {
                for asListener in asListeners {
                    asListeners.append(asListener)
                }
            }
            listenersAddedToMapC = true
        }

        mapControllerMK?.addEventListener(type: type)
        mapControllerGMS?.addEventListener(type: type)
        return nil
    }

    func removeEventListener(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let type = String(argv[0]) else {
            return ArgCountError(message: "removeEventListener").getError(#file, #line, #column)
        }
        if mapControllerMK == nil && mapControllerGMS == nil {
            asListeners = asListeners.filter({ $0 != type })
        } else {
            if !listenersAddedToMapC {
                for asListener in asListeners {
                    asListeners = asListeners.filter({ $0 != asListener })
                }
            }
        }

        mapControllerMK?.removeEventListener(type: type)
        mapControllerGMS?.removeEventListener(type: type)
        return nil
    }

    func showInfoWindow(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("showInfoWindow is Android only")
        return nil
    }

    func hideInfoWindow(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("hideInfoWindow is Android only")
        return nil
    }

    func addCircle(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0
          else {
            return ArgCountError(message: "addCircle").getError(#file, #line, #column)
        }

        if mapProvider == .apple, let mvc = mapControllerMK,
           let circle = CustomMKCircle.init(argv[0]) {
            mvc.addCircle(circle: circle)
        } else if let mvc = mapControllerGMS, let circle = GMSCircle.init(argv[0]) {
            mvc.addCircle(circle: circle)
        }

        return nil
    }

    func removeCircle(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }


    func setBounds(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 2,
              let southWest = CLLocationCoordinate2D.init(argv[0]),
              let northEast = CLLocationCoordinate2D.init(argv[1]),
              let animates = Bool(argv[2]) else {
            return ArgCountError(message: "setBounds").getError(#file, #line, #column)
        }
        mapControllerMK?.setBounds(bounds: GMSCoordinateBounds.init(coordinate: southWest, coordinate: northEast), animates: animates)
        mapControllerGMS?.setBounds(bounds: GMSCoordinateBounds.init(coordinate: southWest, coordinate: northEast), animates: animates)
        return nil
    }

    func zoomIn(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let animates = Bool(argv[0]) else {
            return ArgCountError(message: "zoomIn").getError(#file, #line, #column)
        }
        mapControllerMK?.zoomIn(animates: animates)
        mapControllerGMS?.zoomIn(animates: animates)
        return nil
    }

    func zoomOut(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let animates = Bool(argv[0]) else {
            return ArgCountError(message: "zoomOut").getError(#file, #line, #column)
        }
        mapControllerMK?.zoomOut(animates: animates)
        mapControllerGMS?.zoomOut(animates: animates)
        return nil
    }

    func zoomTo(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
              let zoomLevel = CGFloat(argv[1]),
              let animates = Bool(argv[0]) else {
            return ArgCountError(message: "zoomTo").getError(#file, #line, #column)
        }

        mapControllerMK?.zoomTo(zoomLevel: zoomLevel, animates: animates)
        mapControllerGMS?.zoomTo(zoomLevel: zoomLevel, animates: animates)
        return nil
    }

    func setAnimationDuration(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("We cannot set animation duration on iOS")
        return nil
    }

    func isSupported(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return true.toFREObject()
    }

    func initController(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
              let key = String(argv[0]),
              let mapProvider = Int(argv[1]) else {
            return ArgCountError(message: "initController").getError(#file, #line, #column)
        }
        self.mapProvider = mapProvider == 0 ? .google : .apple
        if self.mapProvider == .google {
            return GMSServices.provideAPIKey(key).toFREObject()
        } else {
            return true.toFREObject()
        }
    }

    func initMap(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 3,
              let inFRE3 = argv[3], // settings:Settings
              let viewPort = CGRect(argv[0]),
              let zoomLevel = CGFloat(argv[2]),
              let coordinate = CLLocationCoordinate2D.init(argv[1])
          else {
            return ArgCountError(message: "initMap").getError(#file, #line, #column)
        }

        var settings: Settings?
        if let settingsDict = Dictionary.init(inFRE3) {
            settings = Settings.init(dictionary: settingsDict)
        }

        if self.mapProvider == .google {
            mapControllerGMS = GMSMapController.init(context: context, coordinate: coordinate, zoomLevel: zoomLevel, frame: viewPort, settings: settings)
        } else {
            mapControllerMK = MKMapController.init(context: context, coordinate: coordinate, zoomLevel: zoomLevel, frame: viewPort, settings: settings)
        }
        return nil
    }


    func addMarker(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let inFRE0 = argv[0] //marker:Marker
          else {
            return ArgCountError(message: "addMarker").getError(#file, #line, #column)
        }
        let markerOptions = MarkerOptions.init(freObject: inFRE0)

        if self.mapProvider == .google {
            let addedMarker = mapControllerGMS?.addMarker(markerOptions: markerOptions)
            if let userData = addedMarker?.userData as? String {
                return userData.toFREObject()
            }
        } else {
            let addedMarker = mapControllerMK?.addMarker(markerOptions: markerOptions)
            if let userData = addedMarker?.userData as? String {
                return userData.toFREObject()
            }
        }

        return nil

    }

    func updateMarker(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let identifier = String(argv[0]), //marker:Marker
              let inFRE1 = argv[1]
          else {
            return ArgCountError(message: "updateMarker").getError(#file, #line, #column)
        }
        let markerOptions = MarkerOptions.init(freObject: inFRE1)
        mapControllerMK?.updateMarker(identifier: identifier, markerOptions: markerOptions)
        mapControllerGMS?.updateMarker(identifier: identifier, markerOptions: markerOptions)
        return nil
    }

    func removeMarker(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let identifier = String(argv[0])
          else {
            return ArgCountError(message: "removeMarker").getError(#file, #line, #column)
        }
        mapControllerMK?.removeMarker(identifier: identifier)
        mapControllerGMS?.removeMarker(identifier: identifier)
        return nil
    }

    func clear(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        mapControllerMK?.clear()
        mapControllerGMS?.clear()
        return nil
    }

    func setViewPort(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let viewPort = CGRect(argv[0])
          else {
            return ArgCountError(message: "setViewPort").getError(#file, #line, #column)
        }
        mapControllerMK?.setViewPort(frame: viewPort)
        mapControllerGMS?.setViewPort(frame: viewPort)
        return nil
    }

    func moveCamera(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 4,
              let animates = Bool(argv[4])
          else {
            return ArgCountError(message: "moveCamera").getError(#file, #line, #column)
        }

        let centerAt: CLLocationCoordinate2D? = CLLocationCoordinate2D.init(argv[0])
        let zoom: Float? = Float(argv[1])
        let tilt: Double? = Double(argv[2])
        let bearing: Double? = Double(argv[3])
        mapControllerMK?.moveCamera(centerAt: centerAt, tilt: tilt, bearing: bearing, animates: animates)
        mapControllerGMS?.moveCamera(centerAt: centerAt, zoom: zoom, tilt: tilt, bearing: bearing, animates: animates)
        return nil
    }

    func setStyle(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let json = String(argv[0])
          else {
            return ArgCountError(message: "setStyle").getError(#file, #line, #column)
        }
        mapControllerGMS?.setStyle(json: json)
        return nil
    }


    func setMapType(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let type = Int(argv[0])
          else {
            return ArgCountError(message: "setMapType").getError(#file, #line, #column)
        }
        mapControllerMK?.setMapType(type: UInt(type))
        mapControllerGMS?.setMapType(type: UInt(type))
        return nil
    }


    func setVisible(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let visible = Bool(argv[0])
          else {
            return ArgCountError(message: "setVisible").getError(#file, #line, #column)
        }
        
        if mapControllerMK == nil && mapControllerGMS == nil {
            return nil
        }
        
        if !isAdded {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                switch mapProvider {
                case .apple:
                    rootViewController.view.addSubview((mapControllerMK?.view)!)
                    
                    break
                case .google:
                    rootViewController.view.addSubview((mapControllerGMS?.view)!)
                    
                    break
                }

                isAdded = true
            }
        }
        
        mapControllerMK?.view.isHidden = !visible
        mapControllerGMS?.view.isHidden = !visible

        return nil
    }

    public func requestLocation(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        return nil
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        var props: Dictionary<String, Any> = Dictionary()
        props["latitude"] = location.coordinate.latitude
        props["longitude"] = location.coordinate.longitude
        let json = JSON(props)
        sendEvent(name: Constants.LOCATION_UPDATED, value: json.description)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var props: Dictionary<String, Any> = Dictionary()
        props["status"] = status.rawValue
        switch status {
        case .restricted:
            props["status"] = Constants.AUTHORIZATION_STATUS_DENIED //TODO restricted
        case .notDetermined: fallthrough
        case .denied:
            props["status"] = Constants.AUTHORIZATION_STATUS_DENIED
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            props["status"] = Constants.AUTHORIZATION_STATUS_ALWAYS
            locationManager.requestLocation()
            mapControllerMK?.showsUserLocation = true
            mapControllerGMS?.mapView.isMyLocationEnabled = true
            if let loc = userLocation?.coordinate {
                mapControllerMK?.moveCamera(centerAt: loc, tilt: nil, bearing: nil, animates: true)
                mapControllerGMS?.moveCamera(centerAt: loc, zoom: nil, tilt: nil, bearing: nil, animates: true)
            }
        }
        let json = JSON(props)
        sendEvent(name: Constants.AUTHORIZATION_STATUS, value: json.description)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        trace("locationManager:didFailWithError", error.localizedDescription) //TODO
    }


    // Must have this function. It exposes the methods to our entry ObjC.
    @objc public func callSwiftFunction(name: String, ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let fm = functionsToSet[name] {
            return fm(ctx, argc, argv)
        }
        return nil
    }

    @objc public func setFREContext(ctx: FREContext) {
        self.context = FreContextSwift.init(freContext: ctx)
    }

    @objc public func onLoad() {
    }


}
