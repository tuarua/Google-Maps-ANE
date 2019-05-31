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
package com.tuarua;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.tuarua.googlemapsane.KotlinController;

public class GoogleMapsANE implements FREExtension {
    private static final String[] FUNCTIONS = {
             "isSupported"
            ,"init"
            ,"initMap"
            ,"addEventListener"
            ,"removeEventListener"
            ,"addMarker"
            ,"setMarkerProp"
            ,"removeMarker"
            ,"addGroundOverlay"
            ,"setGroundOverlayProp"
            ,"removeGroundOverlay"
            ,"showInfoWindow"
            ,"hideInfoWindow"
            ,"addCircle"
            ,"setCircleProp"
            ,"removeCircle"
            ,"addPolyline"
            ,"setPolylineProp"
            ,"removePolyline"
            ,"addPolygon"
            ,"setPolygonProp"
            ,"removePolygon"
            ,"clear"
            ,"setViewPort"
            ,"setVisible"
            ,"moveCamera"
            ,"setStyle"
            ,"setMapType"
            ,"showUserLocation"
            ,"reverseGeocodeLocation"
            ,"forwardGeocodeLocation"
            ,"setBounds"
            ,"zoomIn"
            ,"zoomOut"
            ,"zoomTo"
            ,"scrollBy"
            ,"setAnimationDuration"
            ,"requestPermissions"
            ,"capture"
            ,"getCapture"
            ,"setBuildingsEnabled"
            ,"setTrafficEnabled"
            ,"setMinZoom"
            ,"setMaxZoom"
            ,"setIndoorEnabled"
            ,"setMyLocationEnabled"
            ,"projection_pointForCoordinate"
            ,"projection_coordinateForPoint"
            ,"projection_containsCoordinate"
            ,"projection_visibleRegion"
            ,"projection_pointsForMeters"
    };

    private static GoogleMapsANEContext extensionContext;

    @Override
    public void initialize() {

    }

    @Override
    public FREContext createContext(String s) {
        String NAME = "com.tuarua.GoogleMapsANE";
        return extensionContext = new GoogleMapsANEContext(NAME, new KotlinController(), FUNCTIONS);
    }

    @Override
    public void dispose() {
        extensionContext.dispose();
    }
}
