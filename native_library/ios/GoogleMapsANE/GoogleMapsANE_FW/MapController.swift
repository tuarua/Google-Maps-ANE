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
import UIKit
import GoogleMaps
import FreSwift

class MapController: UIViewController, GMSMapViewDelegate, FreSwiftController {
    internal var TAG: String? = "GoogleMapsANE"
    internal var context: FreContextSwift!
    public var mapView: GMSMapView!
    private var settings: Settings?
    private var zoomLevel: Float = 13.0
    private var container: UIView!
    private var initialCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    private var viewPort: CGRect = CGRect.zero
    private var markers: Dictionary<String, GMSMarker> = Dictionary()
    private var asListeners:Array<String> = []
    
    convenience init(context: FreContextSwift, coordinate: CLLocationCoordinate2D, zoomLevel: CGFloat, frame: CGRect, settings: Settings?) {
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
        container = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: self.view.frame.size))
        mapView = GMSMapView.map(withFrame: container.bounds, camera: camera)
        mapView.delegate = self
        if let settings = self.settings {
            mapView.settings.compassButton = settings.compassButton
            mapView.settings.myLocationButton = settings.myLocationButton
            mapView.settings.scrollGestures = settings.scrollGestures
            mapView.settings.rotateGestures = settings.rotateGestures
            mapView.settings.zoomGestures = settings.zoomGestures
        }
        
        view.addSubview(container)
        container.addSubview(mapView)
        sendEvent(name: Constants.ON_READY, value: "")
    }
    
    public func addMarker(markerOptions: MarkerOptions) -> GMSMarker {
        let uuid = UUID.init().uuidString
        let marker = GMSMarker()
        markers[uuid] = marker
        updateMarker(uuid: uuid, markerOptions: markerOptions)
        return marker
    }
    
    public func updateMarker(uuid: String, markerOptions: MarkerOptions) {

        if let marker: GMSMarker = markers[uuid], let coordinate = markerOptions.coordinate {
            marker.tracksInfoWindowChanges = true
            marker.position = coordinate
            if let icon = markerOptions.icon {
                marker.icon = icon
            } else {
                marker.icon = GMSMarker.markerImage(with: markerOptions.color)
            }
            marker.title = markerOptions.title
            marker.snippet = markerOptions.snippet
            marker.isDraggable = markerOptions.isDraggable
            marker.isFlat = markerOptions.isFlat
            marker.isTappable = markerOptions.isTappable
            marker.opacity = Float(markerOptions.opacity)
            marker.map = mapView
            marker.userData = uuid
            marker.rotation = markerOptions.rotation
        }
    }
    
    public func removeMarker(uuid: String) {
        if let marker: GMSMarker = markers[uuid] {
            marker.map = nil
        }
    }
    
    public func clear() {
        mapView.clear()
    }
    
    //TODO
    public func addGroundOverlay() {
        
    }
    
    public func setBounds(bounds: GMSCoordinateBounds, animates: Bool){
        let update = GMSCameraUpdate.fit(bounds)
        updateCamera(update, animates)
    }
    
    public func addCircle(circle: GMSCircle) {
        circle.map = mapView
    }
    
    public func addEventListener(type: String) {
        asListeners.append(type)
    }
    
    public func removeEventListener(type: String) {
        asListeners = asListeners.filter( {$0 != type} )
    }
    
    public func zoomIn(animates: Bool) {
        let update = GMSCameraUpdate.zoomIn()
        updateCamera(update, animates)
    }
    
    public func zoomOut(animates: Bool) {
        let update = GMSCameraUpdate.zoomOut()
        updateCamera(update, animates)
    }
    
    public func zoomTo(zoomLevel: CGFloat, animates: Bool){
        let update = GMSCameraUpdate.zoom(to: Float(zoomLevel))
        updateCamera(update, animates)
    }
    
    
    public func moveCamera(target: CLLocationCoordinate2D?, zoom: Float?, tilt:Double?, bearing:Double?, animates: Bool) {
        let currentCamPosition = mapView.camera
        var newTarget = currentCamPosition.target
        var newBearing = currentCamPosition.bearing
        var newViewingAngle = currentCamPosition.viewingAngle
        var newZoom = currentCamPosition.zoom
        if let t = target {
            newTarget = t
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
        let camPosition:GMSCameraPosition = GMSCameraPosition.init(target: newTarget, zoom: newZoom, bearing: newBearing, viewingAngle: newViewingAngle)
        
        let update = GMSCameraUpdate.setCamera(camPosition)
        
        updateCamera(update, animates)
    }
    
    public func setStyle(json: String) {
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: json)
        } catch {
            trace("One or more of the map styles failed to load. \(error)")
        }
    }
    
    public func setMapType(type: UInt) {
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
    
    public func setViewPort(frame: CGRect) {
        viewPort = frame
        self.view.frame = viewPort
        container.frame = CGRect.init(origin: CGPoint.zero, size: self.view.frame.size)
        mapView.frame = container.bounds
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if !asListeners.contains(Constants.DID_TAP_AT) {return}
        var props: Dictionary<String, Any> = Dictionary()
        props["latitude"] = coordinate.latitude
        props["longitude"] = coordinate.longitude
        let json = JSON(props)
        sendEvent(name: Constants.DID_TAP_AT, value: json.description)
    }
    
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if !asListeners.contains(Constants.DID_LONG_PRESS_AT) {return}
        var props: Dictionary<String, Any> = Dictionary()
        props["latitude"] = coordinate.latitude
        props["longitude"] = coordinate.longitude
        let json = JSON(props)
        sendEvent(name: Constants.DID_LONG_PRESS_AT, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (!asListeners.contains(Constants.ON_CAMERA_MOVE)) {return}
        var props: Dictionary<String, Any> = Dictionary()
        props["latitude"] = position.target.latitude
        props["longitude"] = position.target.longitude
        props["zoom"] = position.zoom
        props["tilt"] = position.viewingAngle
        props["bearing"] = position.bearing
        
        let json = JSON(props)
        sendEvent(name: Constants.ON_CAMERA_MOVE, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if (!asListeners.contains(Constants.ON_CAMERA_IDLE)) {return}
        sendEvent(name: Constants.ON_CAMERA_IDLE, value: "")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (!asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED)) {return}
        var props: Dictionary<String, Any> = Dictionary()
        props["reason"] = gesture ? 1: 3
        let json = JSON(props)
        sendEvent(name: Constants.ON_CAMERA_MOVE_STARTED, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_DRAG) {return}
        var uuid: String = ""
        if let _uuid = marker.userData as? String {
            uuid = _uuid
        }
        sendEvent(name: Constants.DID_DRAG, value: uuid)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_END_DRAGGING) {return}
        var uuid: String = ""
        if let _uuid = marker.userData as? String {
            uuid = _uuid
        }
        sendEvent(name: Constants.DID_END_DRAGGING, value: uuid)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if !asListeners.contains(Constants.DID_TAP_MARKER) {return false}
        var uuid: String = ""
        if let _uuid = marker.userData as? String {
            uuid = _uuid
        }
        sendEvent(name: Constants.DID_TAP_MARKER, value: uuid)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_BEGIN_DRAGGING) {return}
        var uuid: String = ""
        if let _uuid = marker.userData as? String {
            uuid = _uuid
        }
        sendEvent(name: Constants.DID_BEGIN_DRAGGING, value: uuid)
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_TAP_INFO_WINDOW) {return}
        var uuid: String = ""
        if let _uuid = marker.userData as? String {
            uuid = _uuid
        }
        sendEvent(name: Constants.DID_TAP_INFO_WINDOW, value: uuid)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW) {return}
        var uuid: String = ""
        if let _uuid = marker.userData as? String {
            uuid = _uuid
        }
        sendEvent(name: Constants.DID_CLOSE_INFO_WINDOW, value: uuid)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW) {return}
        var uuid: String = ""
        if let _uuid = marker.userData as? String {
            uuid = _uuid
        }
        sendEvent(name: Constants.DID_LONG_PRESS_INFO_WINDOW, value: uuid)
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        sendEvent(name: "TRACE", value: "placeID \(placeID.debugDescription) \(name) \(location.latitude) \(location.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        sendEvent(name: "TRACE", value: "didTap overlay \(overlay.debugDescription)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        trace("didReceiveMemoryWarning")
        // Dispose of any resources that can be recreated.
    }
    
}
