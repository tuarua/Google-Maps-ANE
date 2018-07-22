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
import GoogleMaps

extension GMSMapController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if !asListeners.contains(Constants.DID_TAP_AT) {return}
        var props: [String: Any] = Dictionary()
        props["latitude"] = coordinate.latitude
        props["longitude"] = coordinate.longitude
        let json = JSON(props)
        dispatchEvent(name: Constants.DID_TAP_AT, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if !asListeners.contains(Constants.DID_LONG_PRESS_AT) {return}
        var props: [String: Any] = Dictionary()
        props["latitude"] = coordinate.latitude
        props["longitude"] = coordinate.longitude
        let json = JSON(props)
        dispatchEvent(name: Constants.DID_LONG_PRESS_AT, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if !asListeners.contains(Constants.ON_CAMERA_MOVE) { return }
        var props: [String: Any] = Dictionary()
        props["latitude"] = position.target.latitude
        props["longitude"] = position.target.longitude
        props["zoom"] = position.zoom
        props["tilt"] = position.viewingAngle
        props["bearing"] = position.bearing
        
        let json = JSON(props)
        dispatchEvent(name: Constants.ON_CAMERA_MOVE, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if !asListeners.contains(Constants.ON_CAMERA_IDLE) { return }
        dispatchEvent(name: Constants.ON_CAMERA_IDLE, value: "")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if !asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED) { return }
        var props: [String: Any] = Dictionary()
        props["reason"] = gesture ? 1: 3
        let json = JSON(props)
        dispatchEvent(name: Constants.ON_CAMERA_MOVE_STARTED, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_DRAG) {return}
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        dispatchEvent(name: Constants.DID_DRAG, value: identifier)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_END_DRAGGING) {return}
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        var props: [String: Any] = Dictionary()
        props["id"] = identifier
        props["latitude"] = marker.position.latitude
        props["longitude"] = marker.position.longitude
        let json = JSON(props)
        dispatchEvent(name: Constants.DID_END_DRAGGING, value: json.description)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if !asListeners.contains(Constants.DID_TAP_MARKER) {return false}
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        dispatchEvent(name: Constants.DID_TAP_MARKER, value: identifier)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_BEGIN_DRAGGING) {return}
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        dispatchEvent(name: Constants.DID_BEGIN_DRAGGING, value: identifier)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_TAP_INFO_WINDOW) {return}
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        dispatchEvent(name: Constants.DID_TAP_INFO_WINDOW, value: identifier)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW) {return}
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        dispatchEvent(name: Constants.DID_CLOSE_INFO_WINDOW, value: identifier)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW) {return}
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        dispatchEvent(name: Constants.DID_LONG_PRESS_INFO_WINDOW, value: identifier)
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        if !isMapLoaded {
            dispatchEvent(name: Constants.ON_LOADED, value: "")
        }
        isMapLoaded = true
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String,
                 location: CLLocationCoordinate2D) {
        dispatchEvent(name: "TRACE",
                  value: "placeID \(placeID.debugDescription) \(name) \(location.latitude) \(location.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        dispatchEvent(name: "TRACE", value: "didTap overlay \(overlay.debugDescription)")
    }
}
