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
package com.tuarua {
import com.tuarua.fre.ANEError;
import com.tuarua.googlemaps.CameraPosition;
import com.tuarua.googlemaps.Circle;
import com.tuarua.googlemaps.Coordinate;
import com.tuarua.googlemaps.CoordinateBounds;
import com.tuarua.googlemaps.GroundOverlay;
import com.tuarua.googlemaps.MapProvider;
import com.tuarua.googlemaps.Marker;
import com.tuarua.googlemaps.Polygon;
import com.tuarua.googlemaps.Polyline;
import com.tuarua.googlemaps.Projection;
import com.tuarua.googlemaps.Settings;

import flash.display.BitmapData;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class GoogleMapsANE extends EventDispatcher {
    private var _viewPort:Rectangle;
    private var _visible:Boolean;
    private var _isInited:Boolean;
    private var _isMapInited:Boolean;

    private static var _mapView:GoogleMapsANE;
    private static var _key:String;
    private static var _mapProvider:int = MapProvider.GOOGLE;
    private var _projection:Projection = new Projection();

    public function GoogleMapsANE() {
        if (_mapView) {
            throw new Error(GoogleMapsANEContext.NAME + "GoogleMapsANE is a singleton, use .mapView");
        }

        if (GoogleMapsANEContext.context) {
            var ret:* = GoogleMapsANEContext.context.call("init", _key, _mapProvider);
            if (ret is ANEError) throw ret as ANEError;
            _isInited = ret;
        }
        _mapView = this;
    }

    public static function get mapView():GoogleMapsANE {
        if (_mapView == null) {
            new GoogleMapsANE();
        }
        return _mapView;
    }

    public static function set key(value:String):void {
        _key = value;
    }

    public static function set mapProvider(value:int):void {
        _mapProvider = value;
    }

    public static function dispose():void {
        if (GoogleMapsANEContext.context) {
            GoogleMapsANEContext.dispose();
        }
    }

    /**
     *
     * @param type
     * @param listener
     * @param useCapture
     * @param priority
     * @param useWeakReference
     *
     */
    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0,
                                              useWeakReference:Boolean = false):void {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        if (_isInited) {
            GoogleMapsANEContext.context.call("addEventListener", type);
        } else {
            trace("You need to init before adding EventListeners");
        }
    }

    /**
     *
     * @param type
     * @param listener
     * @param useCapture
     *
     */
    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        super.removeEventListener(type, listener, useCapture);
        if (_isInited) {
            GoogleMapsANEContext.context.call("removeEventListener", type);
        } else {
            trace("You need to init before removing EventListeners");
        }
    }

    /**
     *
     * @param viewPort
     * @param centerAt
     * @param zoomLevel
     * @param settings
     * @param scaleFactor
     *
     */
    public function initMap(viewPort:Rectangle, centerAt:Coordinate, zoomLevel:Number, settings:Settings,
                            scaleFactor:Number = 1.0):void {
        if (_isInited) {
            _viewPort = viewPort;
            var ret:* = GoogleMapsANEContext.context.call("initMap", _viewPort, centerAt, zoomLevel, settings, scaleFactor);
            if (ret is ANEError) throw ret as ANEError;
            _isMapInited = true;
        } else {
            trace("initMap wasn't successful");
        }
    }

    /**
     *
     * @param circle
     *
     */
    public function addCircle(circle:Circle):void {
        if (!safetyCheck()) return;
        var ret:* = GoogleMapsANEContext.context.call("addCircle", circle);
        if (ret is ANEError) throw ret as ANEError;
        var id:String = ret as String;
        circle.id = id;
        circle.isAdded = true;
        GoogleMapsANEContext.circles[id] = circle;
    }

    public function addGroundOverlay(groundOverlay:GroundOverlay):void {
        if (!safetyCheck()) return;
        var ret:* = GoogleMapsANEContext.context.call("addGroundOverlay", groundOverlay);
        if (ret is ANEError) throw ret as ANEError;
        var id:String = ret as String;
        groundOverlay.id = id;
        groundOverlay.isAdded = true;
        GoogleMapsANEContext.groundOverlays[id] = groundOverlay;
    }

    /**
     *
     * @param polyline
     *
     */
    public function addPolyline(polyline:Polyline):void {
        if (!safetyCheck()) return;
        var ret:* = GoogleMapsANEContext.context.call("addPolyline", polyline);
        if (ret is ANEError) throw ret as ANEError;
        var id:String = ret as String;
        polyline.id = id;
        polyline.isAdded = true;
        GoogleMapsANEContext.polylines[id] = polyline;
    }

    /**
     *
     * @param polygon
     *
     */
    public function addPolygon(polygon:Polygon):void {
        if (!safetyCheck()) return;
        var ret:* = GoogleMapsANEContext.context.call("addPolygon", polygon);
        if (ret is ANEError) throw ret as ANEError;
        var id:String = ret as String;
        polygon.id = id;
        polygon.isAdded = true;
        GoogleMapsANEContext.polygons[id] = polygon;
    }

    /**
     *
     * @param marker
     * @return
     *
     */
    public function addMarker(marker:Marker):void {
        if (!safetyCheck()) return;
        var ret:* = GoogleMapsANEContext.context.call("addMarker", marker);
        if (ret is ANEError) throw ret as ANEError;
        var id:String = ret as String;
        marker.id = id;
        marker.isAdded = true;
        GoogleMapsANEContext.markers[id] = marker;
    }

    /**
     *
     */
    public function clear():void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("clear");
        }
    }

    /**
     *
     * @param value
     *
     */
    public function set visible(value:Boolean):void {
        if (_visible == value) return;
        _visible = value;
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setVisible", value);
    }

    /**
     * @param bounds
     * @param animates
     *
     */
    public function setBounds(bounds:CoordinateBounds, animates:Boolean = false):void {
        if (!safetyCheck()) return;
        var ret:* = GoogleMapsANEContext.context.call("setBounds", bounds, animates);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     *
     * @param position
     * @param animates
     *
     */
    public function moveCamera(position:CameraPosition, animates:Boolean = false):void {
        if (!safetyCheck()) return;
        var centerAt:Coordinate = position.centerAt ? position.centerAt : null;
        var zoom:* = position.zoom != -9999 ? position.zoom : null;
        var tilt:* = position.tilt != -9999 ? position.tilt : null;
        var bearing:* = position.bearing != -9999 ? position.bearing : null;
        var ret:* = GoogleMapsANEContext.context.call("moveCamera", centerAt, zoom, tilt, bearing, animates);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     *
     * @param animates
     *
     */
    public function zoomIn(animates:Boolean = false):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("zoomIn", animates);
    }

    /**
     *
     * @param animates
     *
     */
    public function zoomOut(animates:Boolean = false):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("zoomOut", animates);
    }

    /**
     *
     * @param zoomLevel
     * @param animates
     *
     */
    public function zoomTo(zoomLevel:Number, animates:Boolean = false):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("zoomTo", zoomLevel, animates);
    }

    /**
     *
     * @param x
     * @param y
     * @param animates
     *
     * <p>Android Only.</p>
     */
    public function scrollBy(x:Number, y:Number, animates:Boolean = false):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("scrollBy", x, y, animates);
    }

    /**
     *
     * @param value
     *
     */
    public function set mapType(value:uint):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setMapType", value);
    }

    /**
     *
     *
     */
    public function showUserLocation():void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("showUserLocation");
    }

    /**
     *
     * @param x
     * @param y
     * @param width leaving as default of 0 captures the full width
     * @param height leaving as default of 0 captures the full height
     *
     * <p>Captures the mapView. This is asynchronous.
     * Listen for GoogleMapsEvent.ON_BITMAP_READY event and then call getCapture()</p>
     *
     */
    public function capture(x:int = 0, y:int = 0, width:int = 0, height:int = 0):void {
        if (!safetyCheck()) return;
        var ret:* = GoogleMapsANEContext.context.call("capture", x, y, width, height) as BitmapData;
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * <p>Returns the last bitmap capture of the mapView</p>
     */
    public function getCapture():BitmapData {
        if (!safetyCheck()) return null;
        var ret:* = GoogleMapsANEContext.context.call("getCapture") as BitmapData;
        if (ret is ANEError) throw ret as ANEError;
        return ret;
    }

    /**
     *
     *
     */
    public function requestPermissions():void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("requestPermissions");
    }


    /**
     *
     * @return whether the mapView is visible
     *
     */
    public function get visible():Boolean {
        return _visible;
    }

    /**
     *
     * @return the viewPort of the mapView
     *
     */
    public function get viewPort():Rectangle {
        return _viewPort;
    }

    /**
     *
     * @param value
     * <p>Sets the viewPort of the mapView.</p>
     *
     */
    public function set viewPort(value:Rectangle):void {
        _viewPort = value;
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setViewPort", _viewPort);
    }

    /**
     *
     * @param id
     *
     */
    public function showInfoWindow(id:String):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("showInfoWindow", id);
    }

    /**
     *
     * @param id
     *
     */
    public function hideInfoWindow(id:String):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("hideInfoWindow", id);
    }

    /**
     *
     * @param json
     * <p>Sets the style of the map.</p>
     *
     */
    public function set style(json:String):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setStyle", json);
    }

    /**
     * Sets whether 3D buildings layer is enabled. (default true).
     *
     * Ignored on Apple Maps
     */
    public function set buildingsEnabled(value:Boolean):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setBuildingsEnabled", value);
    }

    /**
     * Controls whether the map is drawing traffic data, if available.
     *
     * Ignored on Apple Maps
     */
    public function set trafficEnabled(value:Boolean):void  {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setTrafficEnabled", value);
    }

    /**
     * Minimum zoom (the farthest the camera may be zoomed out).
     *
     * Ignored on Apple Maps
     */
    public function set minZoom(value:Number):void  {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setMinZoom", value);
    }

    /**
     * Maximum zoom (the closest the camera may be to the Earth).
     *
     * Ignored on Apple Maps
     */
    public function set maxZoom(value:Number):void  {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setMaxZoom", value);
    }

    /**
     * Sets whether 3D buildings layer is enabled. (default true).
     *
     * Ignored on Apple Maps
     */
    public function set indoorEnabled(value:Boolean):void  {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setIndoorEnabled", value);
    }

    /**
     * Enables or disables the my-location layer.
     */
    public function set myLocationEnabled(value:Boolean):void  {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setMyLocationEnabled", value);
    }

    /**
     * Returns a Projection object that you can use to convert between screen coordinates and latitude/longitude coordinates.
     *
     * returns null on Apple Maps
     */
    public function get projection():Projection {
        if (!safetyCheck()) return null;
        return _projection;
    }

    /**
     *
     * @param value in milliseconds, Android only
     *
     */
    public function set animationDuration(value:int):void {
        if (!safetyCheck()) return;
        GoogleMapsANEContext.context.call("setAnimationDuration", value);
    }

    /**
     *
     * @param coordinate
     *
     */
    public function reverseGeocodeLocation(coordinate:Coordinate):void {
        if (_isInited && !GoogleMapsANEContext.isDisposed) {
            GoogleMapsANEContext.context.call("reverseGeocodeLocation", coordinate);
        }
    }

    /**
     *
     * @param addressString
     *
     */
    public function forwardGeocodeLocation(addressString:String):void {
        if (_isInited && !GoogleMapsANEContext.isDisposed) {
            GoogleMapsANEContext.context.call("forwardGeocodeLocation", addressString);
        }
    }

    /**
     *
     * @return whether we have inited the Google Maps API
     *
     */
    public function get isInited():Boolean {
        return _isInited;
    }

    /**
     *
     * @return whether we have inited the mapView
     *
     */
    public function get isMapInited():Boolean {
        return _isMapInited;
    }

    /**
     * This method is omitted from the output. * * @private
     */
    private function safetyCheck():Boolean {
        if (!_isInited && _isMapInited || GoogleMapsANEContext.isDisposed) {
            trace("You need to init first");
            return false;
        }
        return true;
    }

    //noinspection JSMethodCanBeStatic
    /**
     *
     * @return
     *
     */
    public function get markers():Dictionary {
        return GoogleMapsANEContext.markers;
    }

    //noinspection JSMethodCanBeStatic
    /**
     *
     * @return
     *
     */
    public function get groundOverlays():Dictionary {
        return GoogleMapsANEContext.groundOverlays;
    }

    //noinspection JSMethodCanBeStatic
    /**
     *
     * @return
     *
     */
    public function get circles():Dictionary {
        return GoogleMapsANEContext.circles;
    }

    //noinspection JSMethodCanBeStatic
    /**
     *
     * @return
     *
     */
    public function get polylines():Dictionary {
        return GoogleMapsANEContext.polylines;
    }

}
}
