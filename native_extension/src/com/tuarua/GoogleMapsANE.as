package com.tuarua {
import com.tuarua.fre.ANEError;
import com.tuarua.googlemaps.CameraPosition;
import com.tuarua.googlemaps.Circle;
import com.tuarua.googlemaps.Coordinate;
import com.tuarua.googlemaps.GoogleMapsEvent;
import com.tuarua.googlemaps.GroundOverlay;
import com.tuarua.googlemaps.MapProvider;
import com.tuarua.googlemaps.Marker;
import com.tuarua.googlemaps.Polygon;
import com.tuarua.googlemaps.Polyline;
import com.tuarua.googlemaps.Settings;
import com.tuarua.location.LocationEvent;
import com.tuarua.googlemaps.permissions.PermissionEvent;

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

    public function GoogleMapsANE() {
        if (_mapView) {
            throw new Error(GoogleMapsANEContext.NAME + "GoogleMapsANE is a singleton, use .mapView");
        }

        if (GoogleMapsANEContext.context) {
            var theRet:* = GoogleMapsANEContext.context.call("init", _key, _mapProvider);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            _isInited = theRet;
        }
        _mapView = this;
    }

    private function onContextGoogleMapsEvent(event:GoogleMapsEvent):void {
        this.dispatchEvent(event);
    }

    private function onContextLocationEvent(event:LocationEvent):void {
        this.dispatchEvent(event);
    }

    private function onContextPermissionEvent(event:PermissionEvent):void {
        this.dispatchEvent(event);
    }

    public static function get mapView():GoogleMapsANE {
        if (!_mapView) {
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
            var theRet:* = GoogleMapsANEContext.context.call("initMap", _viewPort, centerAt, zoomLevel, settings, scaleFactor);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            _isMapInited = true;
        } else {
            trace("init wasn't sucessful");
        }
    }

    /**
     *
     * @param circle
     *
     */
    public function addCircle(circle:Circle):void {
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("addCircle", circle);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            var id:String = theRet as String;
            circle.id = id;
            circle.isAdded = true;
            GoogleMapsANEContext.circles[id] = circle;
        }
    }

    /**
     *
     * @param polyline
     *
     */
    public function addPolyline(polyline:Polyline):void {
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("addPolyline", polyline);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            var id:String = theRet as String;
            polyline.id = id;
            polyline.isAdded = true;
            GoogleMapsANEContext.polylines[id] = polyline;
        }
    }

    /**
     *
     * @param polygon
     *
     */
    public function addPolygon(polygon:Polygon):void {
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("addPolygon", polygon);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            var id:String = theRet as String;
            polygon.id = id;
            polygon.isAdded = true;
            GoogleMapsANEContext.polygons[id] = polygon;
        }
    }

    /**
     *
     * @param marker
     * @return
     *
     */
    public function addMarker(marker:Marker):void {
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("addMarker", marker);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            var id:String = theRet as String;
            marker.id = id;
            marker.isAdded = true;
            GoogleMapsANEContext.markers[id] = marker;
        }
    }

    /**
     *
     * @param overlay
     * @return
     *
     */
    public function addGroundOverlay(overlay:GroundOverlay):void {
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("addGroundOverlay", overlay);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            var id:String = theRet as String;
            overlay.id = id;
            overlay.isAdded = true;
            GoogleMapsANEContext.overlays[id] = overlay;
        }
    }

    /**
     *
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
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("setVisible", value);
        }
    }

    /**
     *
     * @param southWest
     * @param northEast
     * @param animates
     *
     */
    public function setBounds(southWest:Coordinate, northEast:Coordinate, animates:Boolean = false):void {
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("setBounds", southWest, northEast, animates);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     *
     * @param position
     * @param animates
     *
     */
    public function moveCamera(position:CameraPosition, animates:Boolean = false):void {
        if (safetyCheck()) {
            var centerAt:Coordinate = position.centerAt ? position.centerAt : null;
            var zoom:* = position.zoom != -9999 ? position.zoom : null;
            var tilt:* = position.tilt != -9999 ? position.tilt : null;
            var bearing:* = position.bearing != -9999 ? position.bearing : null;
            var theRet:* = GoogleMapsANEContext.context.call("moveCamera", centerAt, zoom, tilt, bearing, animates);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     *
     * @param animates
     *
     */
    public function zoomIn(animates:Boolean = false):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("zoomIn", animates);
        }
    }

    /**
     *
     * @param animates
     *
     */
    public function zoomOut(animates:Boolean = false):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("zoomOut", animates);
        }
    }

    /**
     *
     * @param zoomLevel
     * @param animates
     *
     */
    public function zoomTo(zoomLevel:Number, animates:Boolean = false):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("zoomTo", zoomLevel, animates);
        }
    }

    /**
     *
     * @param x
     * @param y
     * @param animates
     *
     */
    public function scrollBy(x:Number, y:Number, animates:Boolean = false):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("scrollBy", x, y, animates);
        }
    }

    /**
     *
     * @param value
     *
     */
    public function set mapType(value:uint):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("setMapType", value);
        }
    }

    /**
     *
     *
     */
    public function showUserLocation():void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("showUserLocation");
        }
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
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("capture", x, y, width, height) as BitmapData;
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     * <p>Returns the last bitmap capture of the mapView</p>
     */
    public function getCapture():BitmapData {
        if (safetyCheck()) {
            var theRet:* = GoogleMapsANEContext.context.call("getCapture") as BitmapData;
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            return theRet;
        }
        return null;
    }

    /**
     *
     *
     */
    public function requestPermissions():void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("requestPermissions");
        }
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
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("setViewPort", _viewPort);
        }
    }

    /**
     *
     * @param id
     *
     */
    public function showInfoWindow(id:String):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("showInfoWindow", id);
        }
    }

    /**
     *
     * @param id
     *
     */
    public function hideInfoWindow(id:String):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("hideInfoWindow", id);
        }
    }

    /**
     *
     * @param json
     * <p>Sets the style of the map.</p>
     *
     */
    public function set style(json:String):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("setStyle", json);
        }
    }

    /**
     *
     * @param value in milliseconds, Android only
     *
     */
    public function set animationDuration(value:int):void {
        if (safetyCheck()) {
            GoogleMapsANEContext.context.call("setAnimationDuration", value);
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
        if (!_isInited && _isMapInited) {
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
    public function get overlays():Dictionary {
        return GoogleMapsANEContext.overlays;
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
