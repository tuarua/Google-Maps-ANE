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

import Foundation
import CoreImage
import GoogleMaps
import FreSwift

public class SwiftController: NSObject {
    public static var TAG = "SwiftController"
    public var context: FreContextSwift!
    public var functionsToSet: FREFunctionMap = [:]
    private var locationController: LocationController!
    private var settings: Settings?
    private var asListeners: [String] = []
    private var listenersAddedToMapC = false
    private var isAdded = false
    private var mapProvider: MapProvider = MapProvider.google
    internal var mapControllerGMS: GMSMapController?
    internal var mapControllerMK: MKMapController?
    
    func addEventListener(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let type = String(argv[0])
            else { return FreArgError().getError()
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
            let type = String(argv[0])
            else { return FreArgError().getError()
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
            let hFre = Int(argv[3])
            else { return FreArgError().getError()
        }

        let x = xFre * Int(UIScreen.main.scale)
        let y = yFre * Int(UIScreen.main.scale)
        let w = wFre * Int(UIScreen.main.scale)
        let h = hFre * Int(UIScreen.main.scale)
        
        mapControllerGMS?.capture(captureDimensions: CGRect(x: x, y: y, width: w, height: h))
        mapControllerMK?.capture(captureDimensions: CGRect(x: x, y: y, width: w, height: h))
        
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
        if let freObject = FREObject(className: "flash.display.BitmapData",
                                              args: cgImage.width, cgImage.height, false),
            let destBmd = FREObject(className: "flash.display.BitmapData",
                                             args: captureDimensions.width, captureDimensions.height, false) {
            
            let asBitmapData = FreBitmapDataSwift(freObject: freObject)
            asBitmapData.acquire()
            asBitmapData.setPixels(cgImage)
            asBitmapData.releaseData()
            
            if let bmd = asBitmapData.rawValue,
                let sourceRect = captureDimensions.toFREObject(),
                let destPoint = CGPoint.zero.toFREObject() {
                destBmd.call(method: "copyPixels", args: bmd, sourceRect, destPoint)
                return destBmd
            }
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
            else { return FreArgError().getError()
        }
        if mapProvider == .apple,
            let mvc = mapControllerMK,
            let circle = CustomMKCircle(argv[0]) {
            mvc.addCircle(circle: circle)
            return circle.identifier.toFREObject()
        } else if let mvc = mapControllerGMS, let circle = GMSCircle(argv[0]) {
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
            else { return FreArgError().getError()
        }
        mapControllerMK?.setCircleProp(id: id, name: name, value: freValue)
        mapControllerGMS?.setCircleProp(id: id, name: name, value: freValue)
        return nil
    }

    func removeCircle(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerMK?.removeCircle(id: id)
        mapControllerGMS?.removeCircle(id: id)
        return nil
    }
    
    func addGroundOverlay(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0
            else { return FreArgError().getError()
        }
        if mapProvider == .apple {
            warning("Ground overlays are available on GoogleMaps only")
        } else if let mvc = mapControllerGMS, let groundOverlay = GMSGroundOverlay(argv[0]) {
            mvc.addGroundOverlay(groundOverlay: groundOverlay)
            if let id = groundOverlay.userData as? String {
                return id.toFREObject()
            }
        }
        return nil
    }
    func setGroundOverlayProp(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0]),
            let name = String(argv[1]),
            let freValue = argv[2]
            else { return FreArgError().getError()
        }
        mapControllerGMS?.setGroundOverlay(id: id, name: name, value: freValue)
        return nil
    }
    func removeGroundOverlay(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerGMS?.removeGroundOverlay(id: id)
        return nil
    }
    
    func addPolyline(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0
            else { return FreArgError().getError()
        }
        if mapProvider == .apple,
            let mvc = mapControllerMK,
            let polyline = CustomMKPolyline(argv[0]) {
            mvc.addPolyline(polyline: polyline)
            return polyline.identifier.toFREObject()
        } else if let mvc = mapControllerGMS, let polyline = GMSPolyline(argv[0]) {
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
            else { return FreArgError().getError()
        }
        mapControllerMK?.setPolylineProp(id: id, name: name, value: freValue)
        mapControllerGMS?.setPolylineProp(id: id, name: name, value: freValue)
        return nil
    }
    func removePolyline(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerMK?.removePolyline(id: id)
        mapControllerGMS?.removePolyline(id: id)
        return nil
    }
    
    func addPolygon(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0
            else { return FreArgError().getError()
        }
        if mapProvider == .apple,
            let mvc = mapControllerMK,
            let polygon = CustomMKPolygon(argv[0]) {
            mvc.addPolygon(polygon: polygon)
            return polygon.identifier.toFREObject()
        } else if let mvc = mapControllerGMS, let polygon = GMSPolygon(argv[0]) {
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
            else { return FreArgError().getError()
        }
        mapControllerMK?.setPolygonProp(id: id, name: name, value: freValue)
        mapControllerGMS?.setPolygonProp(id: id, name: name, value: freValue)
        return nil
    }
    func removePolygon(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerMK?.removePolygon(id: id)
        mapControllerGMS?.removePolygon(id: id)
        return nil
    }

    func setBounds(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
              let bounds = GMSCoordinateBounds(argv[0]),
              let animates = Bool(argv[1])
            else { return FreArgError().getError()
        }
        mapControllerMK?.setBounds(bounds: bounds, animates: animates)
        mapControllerGMS?.setBounds(bounds: bounds, animates: animates)
        return nil
    }

    func zoomIn(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let animates = Bool(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerMK?.zoomIn(animates: animates)
        mapControllerGMS?.zoomIn(animates: animates)
        return nil
    }

    func zoomOut(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let animates = Bool(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerMK?.zoomOut(animates: animates)
        mapControllerGMS?.zoomOut(animates: animates)
        return nil
    }

    func zoomTo(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
            let zoomLevel = CGFloat(argv[1]),
            let animates = Bool(argv[0])
            else { return FreArgError().getError()
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
            let mapProvider = Int(argv[1])
            else { return FreArgError().getError()
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
            let coordinate = CLLocationCoordinate2D(argv[1])
            else { return FreArgError().getError()
        }

        settings = Settings(freObject: inFRE3)
        locationController = LocationController(context: context)
        
        if self.mapProvider == .google {
            mapControllerGMS = GMSMapController(context: context, coordinate: coordinate,
                                                     zoomLevel: zoomLevel, frame: viewPort, settings: settings)
        } else {
            mapControllerMK = MKMapController(context: context, coordinate: coordinate,
                                                   zoomLevel: zoomLevel, frame: viewPort, settings: settings)
        }
        return nil
    }

    func addMarker(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let inFRE0 = argv[0] //marker:Marker
            else { return FreArgError().getError()
        }
        if self.mapProvider == .google {
            if let marker = GMSMarker(inFRE0) {
                mapControllerGMS?.addMarker(marker: marker)
                if let id = marker.userData as? String {
                    return id.toFREObject()
                }
            }
        } else {
            if let marker = CustomMKAnnotation(inFRE0) {
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
            else { return FreArgError().getError()
        }
        mapControllerMK?.setMarkerProp(id: id, name: name, value: freValue)
        mapControllerGMS?.setMarkerProp(id: id, name: name, value: freValue)
        return nil
    }

    func removeMarker(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let id = String(argv[0])
            else { return FreArgError().getError()
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
            else { return FreArgError().getError()
        }
        mapControllerMK?.setViewPort(viewPort)
        mapControllerGMS?.setViewPort(viewPort)
        return nil
    }

    func moveCamera(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 4,
            let animates = Bool(argv[4])
            else { return FreArgError().getError()
        }

        let centerAt: CLLocationCoordinate2D? = CLLocationCoordinate2D(argv[0])
        let zoom = Float(argv[1])
        let tilt = Double(argv[2])
        let bearing = Double(argv[3])
        mapControllerMK?.moveCamera(centerAt: centerAt, tilt: tilt, bearing: bearing, animates: animates)
        mapControllerGMS?.moveCamera(centerAt: centerAt, zoom: zoom, tilt: tilt, bearing: bearing, animates: animates)
        return nil
    }

    func setStyle(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let json = String(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerGMS?.setStyle(json)
        return nil
    }

    func setMapType(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let type = UInt(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerMK?.setMapType(type)
        mapControllerGMS?.setMapType(type)
        return nil
    }

    func setVisible(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let visible = Bool(argv[0])
            else { return FreArgError().getError()
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

    func requestPermissions(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        locationController.requestPermissions()
        return nil
    }
    
    func showUserLocation(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        locationController.showUserLocation()
        if let sttngs = settings {
            mapControllerGMS?.mapView.settings.myLocationButton = sttngs.myLocationButtonEnabled
        }
        return nil
    }
    
    func reverseGeocodeLocation(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let coordinate = CLLocationCoordinate2D(argv[0])
            else { return FreArgError().getError()
        }
        locationController.reverseGeocodeLocation(coordinate)
        return nil
    }
    
    func forwardGeocodeLocation(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let address = String(argv[0])
            else { return FreArgError().getError()
        }
        locationController.forwardGeocodeLocation(address)
        return nil
    }
    
    func setBuildingsEnabled(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = Bool(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerGMS?.mapView.isBuildingsEnabled = value
        return nil
    }
    
    func setTrafficEnabled(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = Bool(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerGMS?.mapView.isTrafficEnabled = value
        return nil
    }
    
    func setMinZoom(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = Float(argv[0]),
            let maxZoom = mapControllerGMS?.mapView.maxZoom
            else { return FreArgError().getError()
        }
        mapControllerGMS?.mapView.setMinZoom(value, maxZoom: maxZoom)
        return nil
    }
    
    func setMaxZoom(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = Float(argv[0]),
            let minZoom = mapControllerGMS?.mapView.minZoom
            else { return FreArgError().getError()
        }
        mapControllerGMS?.mapView.setMinZoom(minZoom, maxZoom: value)
        return nil
    }
    
    func setIndoorEnabled(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = Bool(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerGMS?.mapView.isIndoorEnabled = value
        return nil
    }
    
    func setMyLocationEnabled(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = Bool(argv[0])
            else { return FreArgError().getError()
        }
        mapControllerMK?.showsUserLocation = value
        mapControllerGMS?.mapView.isMyLocationEnabled = value
        return nil
    }
    
    func projection_pointForCoordinate(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = CLLocationCoordinate2D(argv[0])
            else { return FreArgError().getError()
        }
        return mapControllerGMS?.mapView.projection.point(for: value).toFREObject()
    }
    
    func projection_coordinateForPoint(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = CGPoint(argv[0])
            else { return FreArgError().getError()
        }
        return mapControllerGMS?.mapView.projection.coordinate(for: value).toFREObject()
    }
    
    func projection_containsCoordinate(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let value = CLLocationCoordinate2D(argv[0])
            else { return FreArgError().getError()
        }
        return mapControllerGMS?.mapView.projection.contains(value).toFREObject()
    }
    
    func projection_visibleRegion(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return mapControllerGMS?.mapView.projection.visibleRegion().toFREObject()
    }
    
    func projection_pointsForMeters(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
            let forMeters = CLLocationDistance(argv[0]),
            let at = CLLocationCoordinate2D(argv[1])
            else { return FreArgError().getError()
        }
        return mapControllerGMS?.mapView.projection.points(forMeters: forMeters, at: at).toFREObject()
    }

}
