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
import FreSwift

extension SwiftController: FreSwiftMainController {
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
        functionsToSet["\(prefix)reverseGeocodeLocation"] = reverseGeocodeLocation
        functionsToSet["\(prefix)forwardGeocodeLocation"] = forwardGeocodeLocation
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
        // Turn on FreSwift logging
        FreSwiftLogger.shared.context = context
    }
    
    @objc public func onLoad() {
    }
    
}
