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
    private var settings: Settings?
    private var asListeners: [String] = []
    private var listenersAddedToMapC: Bool = false
    private var isAdded: Bool = false
    private var permissionsGranted: Bool = false

    public enum MapProvider: Int {
        case google
        case apple
    }

    private var mapProvider: MapProvider = MapProvider.google

    // Must have this function. It exposes the methods to our entry ObjC.
    @objc public func getFunctions(prefix: String) -> [String] {

        functionsToSet["\(prefix)isSupported"] = isSupported
        functionsToSet["\(prefix)init"] = initController
        functionsToSet["\(prefix)initMap"] = initMap
        functionsToSet["\(prefix)addMarker"] = addMarker
        functionsToSet["\(prefix)setMarkerProp"] = setMarkerProp
        functionsToSet["\(prefix)removeMarker"] = removeMarker
        functionsToSet["\(prefix)addGroundOverlay"] = addGroundOverlay
        functionsToSet["\(prefix)setGroundOverlayProp"] = setGroundOverlayProp
        functionsToSet["\(prefix)removeGroundOverlay"] = removeGroundOverlay
        functionsToSet["\(prefix)addCircle"] = addCircle
        functionsToSet["\(prefix)setCircleProp"] = setCircleProp
        functionsToSet["\(prefix)removeCircle"] = removeCircle
        functionsToSet["\(prefix)addPolyline"] = addPolyline
        functionsToSet["\(prefix)setPolylineProp"] = setPolylineProp
        functionsToSet["\(prefix)removePolyline"] = removePolyline
        functionsToSet["\(prefix)addPolygon"] = addPolygon
        functionsToSet["\(prefix)setPolygonProp"] = setPolygonProp
        functionsToSet["\(prefix)removePolygon"] = removePolygon
        functionsToSet["\(prefix)clear"] = clear
        functionsToSet["\(prefix)setViewPort"] = setViewPort
        functionsToSet["\(prefix)setVisible"] = setVisible
        functionsToSet["\(prefix)moveCamera"] = moveCamera
        functionsToSet["\(prefix)setStyle"] = setStyle
        functionsToSet["\(prefix)setMapType"] = setMapType
        functionsToSet["\(prefix)showUserLocation"] = showUserLocation
        functionsToSet["\(prefix)addEventListener"] = addEventListener
        functionsToSet["\(prefix)removeEventListener"] = removeEventListener
        functionsToSet["\(prefix)zoomIn"] = zoomIn
        functionsToSet["\(prefix)zoomOut"] = zoomOut
        functionsToSet["\(prefix)zoomTo"] = zoomTo
        functionsToSet["\(prefix)scrollBy"] = scrollBy
        functionsToSet["\(prefix)setAnimationDuration"] = setAnimationDuration
        functionsToSet["\(prefix)showInfoWindow"] = showInfoWindow
        functionsToSet["\(prefix)hideInfoWindow"] = hideInfoWindow
        functionsToSet["\(prefix)setBounds"] = setBounds
        functionsToSet["\(prefix)requestPermissions"] = requestPermissions
        functionsToSet["\(prefix)capture"] = capture
        functionsToSet["\(prefix)getCapture"] = getCapture
        
        var arr: [String] = []
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
    func capture(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 3,
            let xFre = Int(argv[0]),
            let yFre = Int(argv[1]),
            let wFre = Int(argv[2]),
            let hFre = Int(argv[3]) else {
                return ArgCountError(message: "capture").getError(#file, #line, #column)
        }

        let x = xFre * Int(UIScreen.main.scale)
        let y = yFre * Int(UIScreen.main.scale)
        let w = wFre * Int(UIScreen.main.scale)
        let h = hFre * Int(UIScreen.main.scale)
        
        mapControllerGMS?.capture(captureDimensions: CGRect.init(x: x, y: y, width: w, height: h))
        mapControllerMK?.capture(captureDimensions: CGRect.init(x: x, y: y, width: w, height: h))
        
        return nil
    }
    
    func getCapture(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let capGMS = mapControllerGMS?.getCapture(), let cgiGMS = capGMS.0 {
            return getCaptureImage(cgImage: cgiGMS, captureDimensions: capGMS.1)
        } else if let capMK = mapControllerMK?.getCapture(), let cgiMK = capMK.0 {
            return getCaptureImage(cgImage: cgiMK, captureDimensions: capMK.1)
        }
        return nil
    }
    
    private func getCaptureImage(cgImage: CGImage, captureDimensions: CGRect) -> FREObject? {
        do {
            if let freObject = try FREObject.init(className: "flash.display.BitmapData",
                                                  args: cgImage.width, cgImage.height, false),
                let destBmd = try FREObject.init(className: "flash.display.BitmapData",
                                                 args: captureDimensions.width, captureDimensions.height, false) {
                
                let asBitmapData = FreBitmapDataSwift.init(freObject: freObject)
                defer {
                    asBitmapData.releaseData()
                }
                do {
                    try asBitmapData.acquire()
                    try asBitmapData.setPixels(cgImage: cgImage)
                    asBitmapData.releaseData()
                    
                    let rect = FreRectangleSwift.init(value: captureDimensions)
                    let pt = FrePointSwift.init(value: CGPoint.zero)
                    if let bmd = asBitmapData.rawValue, let sourceRect = rect.rawValue, let destPoint = pt.rawValue {
                        _ = try destBmd.call(method: "copyPixels", args: bmd, sourceRect, destPoint)
                        return destBmd
                    }
                } catch let e as FreError {
                    return e.getError(#file, #line, #column)
                } catch {}
            }
        } catch let e as FreError {
            return e.getError(#file, #line, #column)
        } catch {
        }
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
        if mapProvider == .apple,
            let mvc = mapControllerMK,
            let circle = CustomMKCircle.init(argv[0]) {
            mvc.addCircle(circle: circle)
            return circle.identifier.toFREObject()
        } else if let mvc = mapControllerGMS, let circle = GMSCircle.init(argv[0]) {
            mvc.addCircle(circle: circle)
            if let id = circle.userData as? String {
                return id.toFREObject()
            }
        }

        return nil
    }
    
    func setCircleProp(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0]),
            let name = String(argv[1]),
            let freValue = argv[2]
            else {
                return ArgCountError(message: "setCircleProp").getError(#file, #line, #column)
        }
        mapControllerMK?.setCircleProp(id: id, name: name, value: freValue)
        mapControllerGMS?.setCircleProp(id: id, name: name, value: freValue)
        return nil
    }

    func removeCircle(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else {
                return ArgCountError(message: "removeCircle").getError(#file, #line, #column)
        }
        mapControllerMK?.removeCircle(id: id)
        mapControllerGMS?.removeCircle(id: id)
        return nil
    }
    
    func addGroundOverlay(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("Ground overlays are available on Android only")
        return nil
    }
    func setGroundOverlayProp(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("Ground overlays are available on Android only")
        return nil
    }
    func removeGroundOverlay(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("Ground overlays are available on Android only")
        return nil
    }
    
    func addPolyline(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0
            else {
                return ArgCountError(message: "addPolyline").getError(#file, #line, #column)
        }
        if mapProvider == .apple,
            let mvc = mapControllerMK,
            let polyline = CustomMKPolyline.init(argv[0]) {
            mvc.addPolyline(polyline: polyline)
            return polyline.identifier.toFREObject()
        } else if let mvc = mapControllerGMS, let polyline = GMSPolyline.init(argv[0]) {
            mvc.addPolyline(polyline: polyline)
            if let id = polyline.userData as? String {
                return id.toFREObject()
            }
        }
        return nil
    }
    func setPolylineProp(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0]),
            let name = String(argv[1]),
            let freValue = argv[2]
            else {
                return ArgCountError(message: "setPolylineProp").getError(#file, #line, #column)
        }
        mapControllerMK?.setPolylineProp(id: id, name: name, value: freValue) //TODO
        mapControllerGMS?.setPolylineProp(id: id, name: name, value: freValue)
        return nil
    }
    func removePolyline(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else {
                return ArgCountError(message: "removePolyline").getError(#file, #line, #column)
        }
        mapControllerMK?.removePolyline(id: id)
        mapControllerGMS?.removePolyline(id: id)
        return nil
    }
    
    func addPolygon(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0
            else {
                return ArgCountError(message: "addPolygon").getError(#file, #line, #column)
        }
        if mapProvider == .apple,
            let mvc = mapControllerMK,
            let polygon = CustomMKPolygon.init(argv[0]) {
            mvc.addPolygon(polygon: polygon)
            return polygon.identifier.toFREObject()
        } else if let mvc = mapControllerGMS, let polygon = GMSPolygon.init(argv[0]) {
            mvc.addPolygon(polygon: polygon)
            if let id = polygon.userData as? String {
                return id.toFREObject()
            }
        }
        return nil
    }
    func setPolygonProp(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0]),
            let name = String(argv[1]),
            let freValue = argv[2]
            else {
                return ArgCountError(message: "setPolygonProp").getError(#file, #line, #column)
        }
        mapControllerMK?.setPolygonProp(id: id, name: name, value: freValue) //TODO
        mapControllerGMS?.setPolygonProp(id: id, name: name, value: freValue)
        return nil
    }
    func removePolygon(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else {
                return ArgCountError(message: "removePolygon").getError(#file, #line, #column)
        }
        //mapControllerMK?.removePolygon(id: id) //TODO
        mapControllerGMS?.removePolygon(id: id)
        return nil
    }

    func setBounds(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 2,
              let southWest = CLLocationCoordinate2D.init(argv[0]),
              let northEast = CLLocationCoordinate2D.init(argv[1]),
              let animates = Bool(argv[2]) else {
            return ArgCountError(message: "setBounds").getError(#file, #line, #column)
        }
        mapControllerMK?.setBounds(bounds: GMSCoordinateBounds.init(coordinate: southWest, coordinate: northEast),
                                   animates: animates)
        mapControllerGMS?.setBounds(bounds: GMSCoordinateBounds.init(coordinate: southWest, coordinate: northEast),
                                    animates: animates)
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

    func scrollBy(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("scrollBy not available on iOS")
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

        if let settingsDict = Dictionary.init(inFRE3) {
            settings = Settings.init(dictionary: settingsDict)
        }

        if self.mapProvider == .google {
            mapControllerGMS = GMSMapController.init(context: context, coordinate: coordinate,
                                                     zoomLevel: zoomLevel, frame: viewPort, settings: settings)
        } else {
            mapControllerMK = MKMapController.init(context: context, coordinate: coordinate,
                                                   zoomLevel: zoomLevel, frame: viewPort, settings: settings)
        }
        return nil
    }

    func addMarker(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let inFRE0 = argv[0] //marker:Marker
          else {
            return ArgCountError(message: "addMarker").getError(#file, #line, #column)
        }
        if self.mapProvider == .google {
            if let marker = GMSMarker.init(inFRE0) {
                mapControllerGMS?.addMarker(marker: marker)
                if let id = marker.userData as? String {
                    return id.toFREObject()
                }
            }
        } else {
            if let marker = CustomMKAnnotation.init(inFRE0) {
                mapControllerMK?.addMarker(marker: marker)
                if let userData = marker.userData as? String {
                    return userData.toFREObject()
                }
            }
        }

        return nil

    }

    func setMarkerProp(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0]),
            let name = String(argv[1]),
            let freValue = argv[2]
          else {
            return ArgCountError(message: "updateMarker").getError(#file, #line, #column)
        }
        mapControllerMK?.setMarkerProp(id: id, name: name, value: freValue)
        mapControllerGMS?.setMarkerProp(id: id, name: name, value: freValue)
        return nil
    }

    func removeMarker(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let id = String(argv[0])
          else {
            return ArgCountError(message: "removeMarker").getError(#file, #line, #column)
        }
        mapControllerMK?.removeMarker(id: id)
        mapControllerGMS?.removeMarker(id: id)
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
                case .google:
                    rootViewController.view.addSubview((mapControllerGMS?.view)!)
                }
                isAdded = true
            }
        }
        
        mapControllerMK?.view.isHidden = !visible
        mapControllerGMS?.view.isHidden = !visible

        return nil
    }

    public func requestPermissions(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
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
        
        return nil
    }
    
    public func showUserLocation(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if permissionsGranted {
            locationManager.requestLocation()
            if let sttngs = settings {
                mapControllerMK?.showsUserLocation = sttngs.myLocationEnabled
                mapControllerGMS?.mapView.settings.myLocationButton = sttngs.myLocationButtonEnabled
                mapControllerGMS?.mapView.isMyLocationEnabled = sttngs.myLocationEnabled
            }
            
            if let loc = userLocation?.coordinate {
                mapControllerMK?.moveCamera(centerAt: loc, tilt: nil, bearing: nil, animates: true)
                mapControllerGMS?.moveCamera(centerAt: loc, zoom: nil, tilt: nil, bearing: nil, animates: true)
            }
        } else {
            warning("No permissions to locate user")
        }
        return nil
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
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 50
        }
        
        let json = JSON(props)
        sendEvent(name: Constants.ON_PERMISSION_STATUS, value: json.description)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        trace("locationManager:didFailWithError", error.localizedDescription) //TODO
    }

    @objc public func dispose() {
        mapControllerMK?.dispose()
        mapControllerGMS?.dispose()
        
        mapControllerMK = nil
        mapControllerGMS = nil
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
