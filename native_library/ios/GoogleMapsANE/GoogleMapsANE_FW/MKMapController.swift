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
import FreSwift
import GoogleMaps
import MapKit

class MKMapController: UIViewController, FreSwiftController {
    internal static var TAG = "MKMapController"
    internal var context: FreContextSwift!
    public var mapView: MKMapView!
    private var settings: Settings?
    private var zoomLevel: UInt = 13
    private var container: UIView!
    private var initialCoordinate = CLLocationCoordinate2D()
    private var viewPort = CGRect.zero
    private var tapGestureRecogniser: UITapGestureRecognizer?
    private var _showsUserLocation = false
    private var lastCapture: CGImage?
    private var captureDimensions = CGRect.zero
    internal var polygons = [String: CustomMKPolygon]()
    internal var polylines = [String: CustomMKPolyline]()
    internal var markers = [String: CustomMKAnnotation]()
    internal var circleRenderers = [String: MKCircleRenderer]()
    internal var polygonRenderers = [String: MKPolygonRenderer]()
    internal var polylineRenderers = [String: MKPolylineRenderer]()
    internal var circles = [String: CustomMKCircle]()
    internal var asListeners: [String] = []
    internal var isMapLoaded = false
    internal var showsUserLocation: Bool {
        set {
            _showsUserLocation = newValue
            if let mv = mapView {
                mv.showsUserLocation = _showsUserLocation
            }
        }
        get {
            return _showsUserLocation
        }
    }

    convenience init(context: FreContextSwift, coordinate: CLLocationCoordinate2D,
                     zoomLevel: CGFloat, frame: CGRect, settings: Settings?) {
        self.init()
        self.context = context
        self.initialCoordinate = coordinate
        self.zoomLevel = UInt(zoomLevel)
        self.viewPort = frame
        self.settings = settings
    }

    @objc internal func didTapAt(_ recogniser: UITapGestureRecognizer) {
        let firstTouch = recogniser.location(ofTouch: 0, in: self.mapView)
        let coordinate = mapView.convert(firstTouch, toCoordinateFrom: mapView)
        var props = [String: Any]()
        props["latitude"] = coordinate.latitude
        props["longitude"] = coordinate.longitude
        let json = JSON(props)
        dispatchEvent(name: Constants.DID_TAP_AT, value: json.description)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTapAt(_:)))
        self.view.addGestureRecognizer(tapGestureRecogniser!)

        let camera = MKMapCamera()
        camera.centerCoordinate = initialCoordinate

        self.view.frame = viewPort
        container = UIView(frame: CGRect(origin: CGPoint.zero, size: self.view.frame.size))

        mapView = MKMapView(frame: container.bounds)
        mapView.camera = camera
        mapView.delegate = self
        if let settings = self.settings {
            mapView.showsCompass = settings.compassButton
            mapView.showsUserLocation = settings.myLocationEnabled
            mapView.isScrollEnabled = settings.scrollGestures
            mapView.isRotateEnabled = settings.rotateGestures
            mapView.isZoomEnabled = settings.zoomGestures
            mapView.isPitchEnabled = settings.tiltGestures
        }

        mapView.setCenter(coordinate: initialCoordinate, zoomLevel: zoomLevel, animated: false)

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

    func setViewPort(frame: CGRect) {
        viewPort = frame
        self.view.frame = viewPort
        container.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
        mapView.frame = container.bounds
    }
    
    func addMarker(marker: CustomMKAnnotation) {
        if let id = marker.userData as? String {
            markers[id] = marker
            mapView.addAnnotation(marker)
        }
    }
    
    func setMarkerProp(id: String, name: String, value: FREObject) {
        guard let marker =  markers[id]
            else { return }
        marker.setProp(name: name, value: value)
    }

    func removeMarker(id: String) {
        if let marker: CustomMKAnnotation = markers[id] {
            mapView.removeAnnotation(marker)
            markers.removeValue(forKey: id)
        }
    }

    func clear() {
        var annos: [MKAnnotation] = []
        for anno in markers {
            annos.append(anno.value)
        }
        mapView.removeAnnotations(annos)
    }

    func setBounds(bounds: GMSCoordinateBounds, animates: Bool) {
        let topLeftCoord = CLLocationCoordinate2D(latitude: bounds.southWest.latitude,
                                                       longitude: bounds.northEast.longitude)
        
        let bottomRightCoord = CLLocationCoordinate2D(latitude: bounds.northEast.latitude,
                                                           longitude: bounds.southWest.longitude)
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1
        
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: animates)
        
    }

    func addCircle(circle: CustomMKCircle) {
        circles[circle.identifier] = circle
        mapView.addOverlay(circle)
    }
    
    func setCircleProp(id: String, name: String, value: FREObject) {
        guard let circle =  circles[id],
        let renderer = circleRenderers[id]
            else { return }
        circle.setProp(name: name, value: value)
        renderer.fillColor = circle.fillColor
        renderer.strokeColor = circle.strokeColor
        renderer.lineWidth = circle.strokeWidth
        renderer.setNeedsDisplay()
    }
    
    func removeCircle(id: String) {
        if let circle: CustomMKCircle = circles[id] {
            mapView.removeAnnotation(circle)
            circles.removeValue(forKey: id)
        }
    }
    
    func addPolygon(polygon: CustomMKPolygon) {
        polygons[polygon.identifier] = polygon
        mapView.addOverlay(polygon)
    }
    
    func setPolygonProp(id: String, name: String, value: FREObject) {
        guard let polygon = polygons[id],
        let renderer = polygonRenderers[id]
            else { return }
        // TODO holes
        if name == "points" {
            if let replaceWith = CustomMKPolygon(value, polygon: polygon) {
                mapView.removeAnnotation(polygon)
                polygons[id] = replaceWith
                mapView.addOverlay(replaceWith)
            }
        } else {
            polygon.setProp(name: name, value: value)
            renderer.fillColor = polygon.fillColor
            renderer.strokeColor = polygon.strokeColor
            renderer.lineWidth = polygon.strokeWidth
            renderer.setNeedsDisplay()
        }
    }
    
    func removePolygon(id: String) {
        if let polygon = polygons[id] {
            mapView.removeAnnotation(polygon)
            polygons.removeValue(forKey: id)
        }
    }
    
    func addPolyline(polyline: CustomMKPolyline) {
        polylines[polyline.identifier] = polyline
        mapView.addOverlay(polyline)
    }
    
    func setPolylineProp(id: String, name: String, value: FREObject) {
        guard let polyline = polylines[id],
            let renderer = polylineRenderers[id]
            else { return }
        // if points we have to reinit the polyline
        if name == "points" {
            if let replaceWith = CustomMKPolyline(value, polyline: polyline) {
                trace("replacing with", replaceWith.debugDescription)
                mapView.removeAnnotation(polyline)
                polylines[id] = replaceWith
                mapView.addOverlay(replaceWith)
            }
        } else {
            polyline.setProp(name: name, value: value)
            renderer.strokeColor = polyline.color
            renderer.lineWidth = polyline.width
            renderer.setNeedsDisplay()
        }
    }
    
    func removePolyline(id: String) {
        if let polyline = polylines[id] {
            mapView.removeAnnotation(polyline)
            polylines.removeValue(forKey: id)
        }
    }

    func addEventListener(type: String) {
        asListeners.append(type)
    }

    func removeEventListener(type: String) {
        asListeners = asListeners.filter({ $0 != type })
    }

    func zoomIn(animates: Bool) {
        let zl = mapView.zoomLevel + 1
        mapView.setCenter(coordinate: mapView.camera.centerCoordinate, zoomLevel: zl, animated: true)
    }

    func zoomOut(animates: Bool) {
        let zl = mapView.zoomLevel - 1
        mapView.setCenter(coordinate: mapView.camera.centerCoordinate, zoomLevel: zl, animated: true)
    }

    func zoomTo(zoomLevel: CGFloat, animates: Bool) {
        let zl = UInt(zoomLevel)
        mapView.setCenter(coordinate: mapView.camera.centerCoordinate, zoomLevel: zl, animated: animates)
    }

    func moveCamera(centerAt: CLLocationCoordinate2D?, tilt: Double?, bearing: Double?, animates: Bool) {
        let currentCamPosition = mapView.camera
        var newCenterAt = currentCamPosition.centerCoordinate
        var newBearing = currentCamPosition.heading
        var newViewingAngle = currentCamPosition.pitch
        let newAlt = mapView.camera.altitude
        if let c = centerAt {
            newCenterAt = c
        }
        if let b = bearing {
            newBearing = b
        }
        if let va = tilt {
            newViewingAngle = CGFloat(va)
        }

        let camera = MKMapCamera()
        camera.centerCoordinate = newCenterAt
        camera.heading = newBearing
        camera.pitch = newViewingAngle
        camera.altitude = newAlt
        mapView.setCamera(camera, animated: animates)
    }

    func setStyle(json: String) {
        trace("setStyle is Google Maps only")
    }

    func setMapType(type: UInt) {
        //standard is 1
        //satellite is 2
        //hybrid is 4
        switch type {
        case 1:
            mapView.mapType = MKMapType.standard
        case 2:
            mapView.mapType = MKMapType.satellite
        case 4:
            mapView.mapType = MKMapType.hybrid
        default:
            mapView.mapType = MKMapType.standard
        }
    }
    
    func dispose() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
