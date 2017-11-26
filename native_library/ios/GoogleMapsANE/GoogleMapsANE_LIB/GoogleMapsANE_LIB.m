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
        ,MAP_FUNCTION(TRGMA, updateMarker)
        ,MAP_FUNCTION(TRGMA, removeMarker)
        ,MAP_FUNCTION(TRGMA, clear)
        ,MAP_FUNCTION(TRGMA, setViewPort)
        ,MAP_FUNCTION(TRGMA, setVisible)
        ,MAP_FUNCTION(TRGMA, moveCamera)
        ,MAP_FUNCTION(TRGMA, setStyle)
        ,MAP_FUNCTION(TRGMA, setMapType)
        ,MAP_FUNCTION(TRGMA, showUserLocation)
        ,MAP_FUNCTION(TRGMA, addEventListener)
        ,MAP_FUNCTION(TRGMA, removeEventListener)
        ,MAP_FUNCTION(TRGMA, zoomIn)
        ,MAP_FUNCTION(TRGMA, zoomOut)
        ,MAP_FUNCTION(TRGMA, zoomTo)
        ,MAP_FUNCTION(TRGMA, setAnimationDuration)
        ,MAP_FUNCTION(TRGMA, showInfoWindow)
        ,MAP_FUNCTION(TRGMA, hideInfoWindow)
        ,MAP_FUNCTION(TRGMA, addCircle)
        ,MAP_FUNCTION(TRGMA, setBounds)
        ,MAP_FUNCTION(TRGMA, requestPermissions)
        ,MAP_FUNCTION(TRGMA, capture)
        ,MAP_FUNCTION(TRGMA, getCapture)
        
        
    };
    
    /**************************************************************************/
    /**************************************************************************/
    
    SET_FUNCTIONS
    
}

CONTEXT_FIN(TRGMA) {
    //any clean up code here
}
EXTENSION_INIT(TRGMA)
EXTENSION_FIN(TRGMA)
@end
