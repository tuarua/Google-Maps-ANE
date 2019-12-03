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
import SwiftyJSON

extension GMSMapController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if !asListeners.contains(Constants.DID_TAP_AT) { return }
        dispatchEvent(name: Constants.DID_TAP_AT, value: coordinate.toJSON())
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if !asListeners.contains(Constants.DID_LONG_PRESS_AT) { return }
        dispatchEvent(name: Constants.DID_LONG_PRESS_AT, value: coordinate.toJSON())
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if !asListeners.contains(Constants.ON_CAMERA_MOVE) { return }
        dispatchEvent(name: Constants.ON_CAMERA_MOVE, value: position.toJSON())
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if !asListeners.contains(Constants.ON_CAMERA_IDLE) { return }
        dispatchEvent(name: Constants.ON_CAMERA_IDLE, value: "")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if !asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED) { return }
        dispatchEvent(name: Constants.ON_CAMERA_MOVE_STARTED, value: JSON(["reason": gesture ? 1: 3]).description)
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_DRAG) { return }
        dispatchEvent(name: Constants.DID_DRAG, value: marker.userData as? String ?? "")
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_END_DRAGGING) { return }
        var props = [String: Any]()
        props["id"] = marker.userData as? String ?? ""
        props["latitude"] = marker.position.latitude
        props["longitude"] = marker.position.longitude
        dispatchEvent(name: Constants.DID_END_DRAGGING, value: JSON(props).description)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if !asListeners.contains(Constants.DID_TAP_MARKER) { return false }
        dispatchEvent(name: Constants.DID_TAP_MARKER, value: marker.userData as? String ?? "")
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_BEGIN_DRAGGING) { return }
        dispatchEvent(name: Constants.DID_BEGIN_DRAGGING, value: marker.userData as? String ?? "")
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_TAP_INFO_WINDOW) { return }
        dispatchEvent(name: Constants.DID_TAP_INFO_WINDOW, value: marker.userData as? String ?? "")
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW) { return }
        var identifier: String = ""
        if let _identifier = marker.userData as? String {
            identifier = _identifier
        }
        dispatchEvent(name: Constants.DID_CLOSE_INFO_WINDOW, value: identifier)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        if !asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW) { return }
        dispatchEvent(name: Constants.DID_LONG_PRESS_INFO_WINDOW, value: marker.userData as? String ?? "")
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
        if !asListeners.contains(Constants.DID_TAP_GROUND_OVERLAY) { return }
        dispatchEvent(name: Constants.DID_TAP_GROUND_OVERLAY, value: overlay.userData as? String ?? "")
    }
}
