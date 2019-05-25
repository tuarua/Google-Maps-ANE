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
import UIKit
import GoogleMaps
import FreSwift

class GMSMapController: UIViewController, FreSwiftController {
    internal static var TAG = "GMSMapController"
    internal var context: FreContextSwift!
    public var mapView: GMSMapView!
    private var settings: Settings?
    private var zoomLevel: Float = 13.0
    private var container: UIView!
    private var initialCoordinate = CLLocationCoordinate2D()
    private var viewPort = CGRect.zero
    private var markers = [String: GMSMarker]()
    private var circles = [String: GMSCircle]()
    private var groundOverlays = [String: GMSGroundOverlay]()
    private var polygons = [String: GMSPolygon]()
    private var polylines = [String: GMSPolyline]()
    private var lastCapture: CGImage?
    private var captureDimensions = CGRect.zero
    internal var isMapLoaded = false
    internal var asListeners: [String] = []
    convenience init(context: FreContextSwift, coordinate: CLLocationCoordinate2D, zoomLevel: CGFloat,
                     frame: CGRect, settings: Settings?) {
        self.init()
        self.context = context
        self.initialCoordinate = coordinate
        self.zoomLevel = Float(zoomLevel)
        self.viewPort = frame
        self.settings = settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: initialCoordinate.latitude,
                                              longitude: initialCoordinate.longitude,
                                              zoom: zoomLevel)
        self.view.frame = viewPort
        container = UIView(frame: CGRect(origin: CGPoint.zero, size: self.view.frame.size))
        mapView = GMSMapView.map(withFrame: container.bounds, camera: camera)
        mapView.delegate = self
        if let settings = self.settings {
            mapView.settings.compassButton = settings.compassButton
            mapView.settings.myLocationButton = settings.myLocationButtonEnabled
            mapView.isMyLocationEnabled = settings.myLocationEnabled
            mapView.settings.scrollGestures = settings.scrollGestures
            mapView.settings.rotateGestures = settings.rotateGestures
            mapView.settings.zoomGestures = settings.zoomGestures
            mapView.settings.tiltGestures = settings.tiltGestures
            mapView.isBuildingsEnabled = settings.buildingsEnabled
        }

        view.addSubview(container)
        container.addSubview(mapView)
        dispatchEvent(name: Constants.ON_READY, value: "")
    }
    
    func capture(captureDimensions: CGRect) {
        self.captureDimensions = captureDimensions
        DispatchQueue.main.async {
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, UIScreen.main.scale )
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let ui = newImage {
                if let ci = CIImage(image: ui) {
                    let context = CIContext(options: nil)
                    if let cg = context.createCGImage(ci, from: ci.extent) {
                        if let ret = cg.copy(colorSpace: CGColorSpaceCreateDeviceRGB()) {
                            self.lastCapture = ret
                            self.dispatchEvent(name: Constants.ON_BITMAP_READY, value: "")
                        }
                    }
                }
            }
        }
    }
    
    func getCapture() -> (CGImage?, CGRect) {
        return (lastCapture, captureDimensions)
    }
    
    func addMarker(marker: GMSMarker) {
        if let id = marker.userData as? String {
            markers[id] = marker
            marker.map = mapView
        }
    }
    
    func setMarkerProp(id: String, name: String, value: FREObject) {
        guard let marker =  markers[id]
            else { return }
        marker.setProp(name: name, value: value)
    }
    
    func removeMarker(id: String) {
        if let marker = markers[id] {
            markers.removeValue(forKey: id)
            marker.map = nil
        }
    }
    
    func clear() {
        mapView.clear()
    }
    
    func setBounds(bounds: GMSCoordinateBounds, animates: Bool) {
        let update = GMSCameraUpdate.fit(bounds)
        updateCamera(update, animates)
    }
      
    func addCircle(circle: GMSCircle) {
        if let id = circle.userData as? String {
            circles[id] = circle
            circle.map = mapView
        }
    }
    
    func setCircleProp(id: String, name: String, value: FREObject) {
        guard let circle =  circles[id]
            else { return }
        circle.setProp(name: name, value: value)
    }
    
    func removeCircle(id: String) {
        if let circle = circles[id] {
            circle.map = nil
            circles.removeValue(forKey: id)
        }
    }
    
    func addGroundOverlay(groundOverlay: GMSGroundOverlay) {
        if let id = groundOverlay.userData as? String {
            groundOverlays[id] = groundOverlay
            groundOverlay.map = mapView
        }
    }
    
    func setGroundOverlay(id: String, name: String, value: FREObject) {
        guard let groundOverlay =  groundOverlays[id]
            else { return }
        groundOverlay.setProp(name: name, value: value)
    }
    
    func removeGroundOverlay(id: String) {
        if let groundOverlay = groundOverlays[id] {
            groundOverlay.map = nil
            groundOverlays.removeValue(forKey: id)
        }
    }
    
    func addPolygon(polygon: GMSPolygon) {
        if let id = polygon.userData as? String {
            polygons[id] = polygon
            polygon.map = mapView
        }
    }
    
    func setPolygonProp(id: String, name: String, value: FREObject) {
        guard let polygon =  polygons[id]
            else { return }
        polygon.setProp(name: name, value: value)
    }
    
    func removePolygon(id: String) {
        if let polygon = polygons[id] {
            polygon.map = nil
            polygons.removeValue(forKey: id)
        }
    }
    
    func addPolyline(polyline: GMSPolyline) {
        if let id = polyline.userData as? String {
            polylines[id] = polyline
            polyline.map = mapView
        }
    }
    
    func setPolylineProp(id: String, name: String, value: FREObject) {
        guard let polyline =  polylines[id]
            else { return }
        polyline.setProp(name: name, value: value)
    }
    
    func removePolyline(id: String) {
        if let polyline = polylines[id] {
            polyline.map = nil
            polylines.removeValue(forKey: id)
        }
    }
    
    func addEventListener(type: String) {
        asListeners.append(type)
    }
    
    func removeEventListener(type: String) {
        asListeners = asListeners.filter({$0 != type})
    }
    
    func zoomIn(animates: Bool) {
        let update = GMSCameraUpdate.zoomIn()
        updateCamera(update, animates)
    }
    
    func zoomOut(animates: Bool) {
        let update = GMSCameraUpdate.zoomOut()
        updateCamera(update, animates)
    }
    
    func zoomTo(zoomLevel: CGFloat, animates: Bool) {
        let update = GMSCameraUpdate.zoom(to: Float(zoomLevel))
        updateCamera(update, animates)
    }
    
    func moveCamera(centerAt: CLLocationCoordinate2D?, zoom: Float?,
                    tilt: Double?, bearing: Double?, animates: Bool) {
        let currentCamPosition = mapView.camera
        var newCenterAt = currentCamPosition.target
        var newBearing = currentCamPosition.bearing
        var newViewingAngle = currentCamPosition.viewingAngle
        var newZoom = currentCamPosition.zoom
        if let c = centerAt {
            newCenterAt = c
        }
        if let b = bearing {
            newBearing = b
        }
        if let va = tilt {
            newViewingAngle = va
        }
        if let z = zoom {
            newZoom = z
        }
        let camPosition: GMSCameraPosition = GMSCameraPosition(target: newCenterAt,
                                                                   zoom: newZoom,
                                                                   bearing: newBearing,
                                                                   viewingAngle: newViewingAngle)
        
        let update = GMSCameraUpdate.setCamera(camPosition)
        
        updateCamera(update, animates)
    }
    
    func setStyle(json: String) {
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: json)
        } catch {
            trace("One or more of the map styles failed to load. \(error)")
        }
    }
    
    func setMapType(type: UInt) {
        //Normal is 1
        //Satellite is 2
        //kGMSTypeTerrain is 3
        //kGMSTypeHybrid is 4
        //kGMSTypeNone is 5
        if let mType = GMSMapViewType(rawValue: type) {
            mapView.mapType = mType
        }
    }
    
    private func updateCamera(_ update: GMSCameraUpdate, _ animates: Bool) {
        if animates {
            mapView.animate(with: update)
        } else {
            mapView.moveCamera(update)
        }
    }
    
    func setViewPort(frame: CGRect) {
        viewPort = frame
        self.view.frame = viewPort
        container.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
        mapView.frame = container.bounds
    }
    
    func dispose() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
