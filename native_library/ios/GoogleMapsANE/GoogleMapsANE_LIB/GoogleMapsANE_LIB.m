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

#import "FreMacros.h"
#import "GoogleMapsANE_LIB.h"
#import <FreSwift/FreSwift-iOS-Swift.h>
#import <GoogleMapsANE_FW/GoogleMapsANE_FW.h>


#define FRE_OBJC_BRIDGE TRGMA_FlashRuntimeExtensionsBridge // use unique prefix throughout to prevent clashes with other ANEs
@interface FRE_OBJC_BRIDGE : NSObject<FreSwiftBridgeProtocol>
@end
@implementation FRE_OBJC_BRIDGE {
}
FRE_OBJC_BRIDGE_FUNCS
@end

@implementation GoogleMapsANE_LIB
SWIFT_DECL(TRGMA) // use unique prefix throughout to prevent clashes with other ANEs
CONTEXT_INIT(TRGMA) {
    SWIFT_INITS(TRGMA)
    
    /**************************************************************************/
    /******* MAKE SURE TO ADD FUNCTIONS HERE THE SAME AS SWIFT CONTROLLER *****/
    /**************************************************************************/

    static FRENamedFunction extensionFunctions[] =
    {
         MAP_FUNCTION(TRGMA, isSupported)
        ,MAP_FUNCTION(TRGMA, init)
        ,MAP_FUNCTION(TRGMA, initMap)
        ,MAP_FUNCTION(TRGMA, addMarker)
        ,MAP_FUNCTION(TRGMA, setMarkerProp)
        ,MAP_FUNCTION(TRGMA, removeMarker)
        ,MAP_FUNCTION(TRGMA, addGroundOverlay)
        ,MAP_FUNCTION(TRGMA, setGroundOverlayProp)
        ,MAP_FUNCTION(TRGMA, removeGroundOverlay)
        ,MAP_FUNCTION(TRGMA, addCircle)
        ,MAP_FUNCTION(TRGMA, setCircleProp)
        ,MAP_FUNCTION(TRGMA, removeCircle)
        ,MAP_FUNCTION(TRGMA, addPolyline)
        ,MAP_FUNCTION(TRGMA, setPolylineProp)
        ,MAP_FUNCTION(TRGMA, removePolyline)
        ,MAP_FUNCTION(TRGMA, addPolygon)
        ,MAP_FUNCTION(TRGMA, setPolygonProp)
        ,MAP_FUNCTION(TRGMA, removePolygon)
        ,MAP_FUNCTION(TRGMA, clear)
        ,MAP_FUNCTION(TRGMA, setViewPort)
        ,MAP_FUNCTION(TRGMA, setVisible)
        ,MAP_FUNCTION(TRGMA, moveCamera)
        ,MAP_FUNCTION(TRGMA, setStyle)
        ,MAP_FUNCTION(TRGMA, setMapType)
        ,MAP_FUNCTION(TRGMA, showUserLocation)
        ,MAP_FUNCTION(TRGMA, reverseGeocodeLocation)
        ,MAP_FUNCTION(TRGMA, forwardGeocodeLocation)
        ,MAP_FUNCTION(TRGMA, addEventListener)
        ,MAP_FUNCTION(TRGMA, removeEventListener)
        ,MAP_FUNCTION(TRGMA, zoomIn)
        ,MAP_FUNCTION(TRGMA, zoomOut)
        ,MAP_FUNCTION(TRGMA, zoomTo)
        ,MAP_FUNCTION(TRGMA, scrollBy)
        ,MAP_FUNCTION(TRGMA, setAnimationDuration)
        ,MAP_FUNCTION(TRGMA, showInfoWindow)
        ,MAP_FUNCTION(TRGMA, hideInfoWindow) 
        ,MAP_FUNCTION(TRGMA, setBounds)
        ,MAP_FUNCTION(TRGMA, requestPermissions)
        ,MAP_FUNCTION(TRGMA, capture)
        ,MAP_FUNCTION(TRGMA, getCapture)
        ,MAP_FUNCTION(TRGMA, setBuildingsEnabled)
        ,MAP_FUNCTION(TRGMA, setTrafficEnabled)
        ,MAP_FUNCTION(TRGMA, setMinZoom)
        ,MAP_FUNCTION(TRGMA, setMaxZoom)
        ,MAP_FUNCTION(TRGMA, setIndoorEnabled)
        ,MAP_FUNCTION(TRGMA, setMyLocationEnabled)
        ,MAP_FUNCTION(TRGMA, projection_pointForCoordinate)
        ,MAP_FUNCTION(TRGMA, projection_coordinateForPoint)
        ,MAP_FUNCTION(TRGMA, projection_containsCoordinate)
        ,MAP_FUNCTION(TRGMA, projection_visibleRegion)
        ,MAP_FUNCTION(TRGMA, projection_pointsForMeters)
        
    };
    
    /**************************************************************************/
    /**************************************************************************/
    
    SET_FUNCTIONS
    
}

CONTEXT_FIN(TRGMA) {
    [TRGMA_swft dispose];
    TRGMA_swft = nil;
    TRGMA_freBridge = nil;
    TRGMA_swftBridge = nil;
    TRGMA_funcArray = nil;
    
}
EXTENSION_INIT(TRGMA)
EXTENSION_FIN(TRGMA)
@end
