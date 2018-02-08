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
import MapKit

extension MKMapController: MKMapViewDelegate {
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
    
}
