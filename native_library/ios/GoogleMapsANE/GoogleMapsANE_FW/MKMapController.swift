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

class MKMapController: UIViewController, MKMapViewDelegate, FreSwiftController {
    internal var TAG: String? = "MKMapController"
    internal var context: FreContextSwift!
    public var mapView: MKMapView!
    private var settings: Settings?
    private var zoomLevel: UInt = 13
    private var container: UIView!
    private var initialCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var viewPort: CGRect = CGRect.zero
    private var asListeners: [String] = []
    private var markers: [String: CustomMKAnnotation] = Dictionary()
    private var circles: [String: CustomMKCircle] = Dictionary()
    private var circleRenderers: [String: MKCircleRenderer] = Dictionary()
    private var polygonRenderers: [String: MKPolygonRenderer] = Dictionary()
    private var polylineRenderers: [String: MKPolylineRenderer] = Dictionary()
    private var polygons: [String: CustomMKPolygon] = Dictionary()
    private var polylines: [String: CustomMKPolyline] = Dictionary()
    
    private var tapGestureRecogniser: UITapGestureRecognizer?
    private var _showsUserLocation: Bool = false
    private var lastCapture: CGImage?
    private var captureDimensions: CGRect = CGRect.zero
    private var isMapLoaded: Bool = false
    
    var showsUserLocation: Bool {
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

    internal func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !asListeners.contains(Constants.ON_CAMERA_MOVE) {
            return
        }
        var props: [String: Any] = Dictionary()
        let camera = mapView.camera
        props["latitude"] = camera.centerCoordinate.latitude
        props["longitude"] = camera.centerCoordinate.longitude
        props["zoom"] = mapView.zoomLevel
        props["tilt"] = camera.pitch
        props["bearing"] = camera.heading
        let json = JSON(props)
        sendEvent(name: Constants.ON_CAMERA_MOVE, value: json.description)
        
    }
    
    internal func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if !isMapLoaded {
            sendEvent(name: Constants.ON_LOADED, value: "")
        }
        isMapLoaded = true
    }

    internal func mapView(_ mapView: MKMapView,
                          annotationView view: MKAnnotationView,
                          didChange newState: MKAnnotationViewDragState,
                          fromOldState oldState: MKAnnotationViewDragState) {

        guard let anno = view.annotation,
        let annotation = anno as? CustomMKAnnotation else { return }
        
        let identifier = annotation.identifier
        
        switch newState {
        case .starting:
            if !asListeners.contains(Constants.DID_BEGIN_DRAGGING) {
                return
            }
            sendEvent(name: Constants.DID_BEGIN_DRAGGING, value: identifier)
        case .none:
            break
        case .dragging:
            
            break
        case .ending:
            if !asListeners.contains(Constants.DID_END_DRAGGING) {
                return
            }
            var props: [String: Any] = Dictionary()
            props["id"] = identifier
            props["latitude"] = annotation.coordinate.latitude
            props["longitude"] = annotation.coordinate.longitude
            let json = JSON(props)
            sendEvent(name: Constants.DID_END_DRAGGING, value: json.description)
            view.setDragState(.none, animated: false)
        case .canceling:
            break
        }
    }

    internal func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard asListeners.contains(Constants.DID_TAP_MARKER),
              let annotation = view.annotation as? CustomMKAnnotation
          else {
            return
        }
        let identifier = annotation.identifier
        sendEvent(name: Constants.DID_TAP_MARKER, value: identifier)
        return
    }

    @objc internal func didTapAt(_ recogniser: UITapGestureRecognizer) {
        let firstTouch = recogniser.location(ofTouch: 0, in: self.mapView)
        let coordinate = mapView.convert(firstTouch, toCoordinateFrom: mapView)
        var props: [String: Any] = Dictionary()
        props["latitude"] = coordinate.latitude
        props["longitude"] = coordinate.longitude
        let json = JSON(props)
        sendEvent(name: Constants.DID_TAP_AT, value: json.description)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: CustomMKCircle.self),
           let ol = overlay as? CustomMKCircle,
           let circle = circles[ol.identifier] {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = circle.fillColor
            circleRenderer.strokeColor = circle.strokeColor
            circleRenderer.lineWidth = circle.strokeWidth
            circleRenderers[ol.identifier] = circleRenderer
            return circleRenderer
        }
        
        if overlay.isKind(of: CustomMKPolygon.self),
            let ol = overlay as? CustomMKPolygon,
            let polygon = polygons[ol.identifier] {
            let polygonRenderer = MKPolygonRenderer(overlay: overlay)
            polygonRenderer.fillColor = polygon.fillColor
            polygonRenderer.strokeColor = polygon.strokeColor
            polygonRenderer.lineWidth = polygon.strokeWidth
            polygonRenderers[ol.identifier] = polygonRenderer
            return polygonRenderer
        }
        
        if overlay.isKind(of: CustomMKPolyline.self),
            let ol = overlay as? CustomMKPolyline,
            let polyline = polylines[ol.identifier] {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = polyline.color
            polylineRenderer.lineWidth = polyline.width
            polylineRenderers[ol.identifier] = polylineRenderer
            return polylineRenderer
        }
        
        let ret = MKOverlayRenderer(overlay: overlay)
        return ret
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomMKAnnotation else {
            return nil
        }
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
            return view
        } else {
            if let markerOptions = markers[annotation.identifier] {
                if let icon = markerOptions.icon {
                    let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    view.image = icon
                    view.isEnabled = (markerOptions.isTappable || markerOptions.isDraggable)
                    view.canShowCallout = markerOptions.isTappable
                    view.isDraggable = markerOptions.isDraggable
                    view.alpha = markerOptions.opacity
                    return view

                } else {
                    let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    view.pinTintColor = markerOptions.color
                    view.isEnabled = (markerOptions.isTappable || markerOptions.isDraggable)
                    view.canShowCallout = markerOptions.isTappable
                    view.isDraggable = markerOptions.isDraggable
                    view.alpha = markerOptions.opacity
                    return view
                }
            }
        }
        return nil
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
        sendEvent(name: Constants.ON_READY, value: "")
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
                            self.sendEvent(name: Constants.ON_BITMAP_READY, value: "")
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
        mapView.add(circle)
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
        mapView.add(polygon)
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
                mapView.add(replaceWith)
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
        mapView.add(polyline)
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
                mapView.add(replaceWith)
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
        self.removeFromParentViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        trace("didReceiveMemoryWarning")
        // Dispose of any resources that can be recreated.
    }

}
