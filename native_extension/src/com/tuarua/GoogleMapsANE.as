package com.tuarua {
import com.tuarua.fre.ANEError;
import com.tuarua.googlemaps.CameraPosition;
import com.tuarua.googlemaps.Circle;
import com.tuarua.googlemaps.Coordinate;
import com.tuarua.googlemaps.GoogleMapsEvent;
import com.tuarua.googlemaps.MapProvider;
import com.tuarua.googlemaps.Marker;
import com.tuarua.googlemaps.Settings;
import com.tuarua.location.LocationEvent;
import com.tuarua.googlemaps.permissions.PermissionEvent;

import flash.display.BitmapData;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class GoogleMapsANE extends EventDispatcher {
    private static const NAME:String = "GoogleMapsANE";
    private var ctx:ExtensionContext;
    private var _viewPort:Rectangle;
    private var _visible:Boolean;
    private var _isInited:Boolean;
    private var _isMapInited:Boolean;
    private var _isSupported:Boolean = true;
    private var _markers:Dictionary = new Dictionary();
    private var argsAsJSON:Object;
    private static const TRACE:String = "TRACE";

    public function GoogleMapsANE() {
        initiate();
    }

    /**
     * This method is omitted from the output. * * @private
     */
    private function initiate():void {
        trace("[" + NAME + "] Initalizing ANE...");
        try {
            ctx = ExtensionContext.createExtensionContext("com.tuarua." + NAME, null);
            ctx.addEventListener(StatusEvent.STATUS, gotEvent);
            _isSupported = ctx.call("isSupported");
        } catch (e:Error) {
            trace(e.name);
            trace(e.message);
            trace(e.getStackTrace());
            trace(e.errorID);
            trace("[" + NAME + "] ANE Not loaded properly.  Future calls will fail.");
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
            ctx.call("addEventListener", type);
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
            ctx.call("removeEventListener", type);
        } else {
            trace("You need to init before removing EventListeners");
        }
    }

    /**
     * This method is omitted from the output. * * @private
     */
    private function gotEvent(event:StatusEvent):void {
        switch (event.level) {
            case TRACE:
                trace("[" + NAME + "]", event.code);
                break;
            case GoogleMapsEvent.DID_TAP_AT:
            case GoogleMapsEvent.DID_LONG_PRESS_AT:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var coordinate:Coordinate = new Coordinate(argsAsJSON.latitude, argsAsJSON.longitude);
                    dispatchEvent(new GoogleMapsEvent(event.level, coordinate));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case GoogleMapsEvent.DID_TAP_MARKER:
            case GoogleMapsEvent.DID_BEGIN_DRAGGING:
            case GoogleMapsEvent.DID_DRAG:
            case GoogleMapsEvent.DID_TAP_INFO_WINDOW:
            case GoogleMapsEvent.DID_CLOSE_INFO_WINDOW:
            case GoogleMapsEvent.DID_LONG_PRESS_INFO_WINDOW:
            case GoogleMapsEvent.ON_READY:
            case GoogleMapsEvent.ON_CAMERA_IDLE:
            case GoogleMapsEvent.ON_BITMAP_READY:
                dispatchEvent(new GoogleMapsEvent(event.level, event.code));
                break;
            case LocationEvent.LOCATION_UPDATED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var location:Coordinate = new Coordinate(argsAsJSON.latitude, argsAsJSON.longitude);
                    dispatchEvent(new LocationEvent(event.level, location));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case PermissionEvent.ON_PERMISSION_STATUS:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    dispatchEvent(new PermissionEvent(event.level, argsAsJSON));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case GoogleMapsEvent.DID_END_DRAGGING:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var id:String = argsAsJSON.id;
                    var latitude:Number = argsAsJSON.latitude;
                    var longitude:Number = argsAsJSON.longitude;
                    var marker:Marker = _markers[id] as Marker;
                    marker.coordinate.latitude = latitude;
                    marker.coordinate.longitude = longitude;
                    dispatchEvent(new GoogleMapsEvent(event.level, argsAsJSON));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case GoogleMapsEvent.ON_CAMERA_MOVE:
            case GoogleMapsEvent.ON_CAMERA_MOVE_STARTED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    dispatchEvent(new GoogleMapsEvent(event.level, argsAsJSON));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
        }
    }

    /**
     *
     * @param key
     * @return
     * @param mapProvider
     *
     */
    public function init(key:String, mapProvider:int = MapProvider.GOOGLE):Boolean {
        _isInited = ctx.call("init", key ,mapProvider);
        return _isInited;
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
            var theRet:* = ctx.call("initMap", _viewPort, centerAt, zoomLevel, settings, scaleFactor);
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
            var theRet:* = ctx.call("addCircle", circle);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     *
     * @param marker
     * @return
     *
     */
    public function addMarker(marker:Marker):String {
        if (safetyCheck()) {
            var theRet:* = ctx.call("addMarker", marker);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            _markers[theRet as String] = marker;
            return theRet as String;
        }
        return null;
    }

    /**
     *
     * @param uuid
     *
     */
    public function updateMarker(uuid:String):void {
        if (safetyCheck()) {
            var marker:Marker = _markers[uuid];
            var theRet:* = ctx.call("updateMarker", uuid, marker);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     *
     * @param uuid
     *
     */
    public function removeMarker(uuid:String):void {
        if (safetyCheck()) {
            delete markers[uuid];
            ctx.call("removeMarker", uuid);
        }
    }

    /**
     *
     *
     */
    public function clear():void {
        if (safetyCheck()) {
            ctx.call("clear");
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
            ctx.call("setVisible", value);
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
            var theRet:* = ctx.call("setBounds", southWest, northEast, animates);
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
            var theRet:* = ctx.call("moveCamera", centerAt, zoom, tilt, bearing, animates);
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
            ctx.call("zoomIn", animates);
        }
    }

    /**
     *
     * @param animates
     *
     */
    public function zoomOut(animates:Boolean = false):void {
        if (safetyCheck()) {
            ctx.call("zoomOut", animates);
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
            ctx.call("zoomTo", zoomLevel, animates);
        }
    }

    /**
     *
     * @param value
     *
     */
    public function set mapType(value:uint):void {
        if (safetyCheck()) {
            ctx.call("setMapType", value);
        }
    }

    /**
     *
     *
     */
    public function showUserLocation():void {
        if (safetyCheck()) {
            ctx.call("showUserLocation");
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
            var theRet:* = ctx.call("capture", x, y, width, height) as BitmapData;
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
            var theRet:* = ctx.call("getCapture") as BitmapData;
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
            ctx.call("requestPermissions");
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
            ctx.call("setViewPort", _viewPort);
        }
    }

    /**
     *
     * @param uuid
     *
     */
    public function showInfoWindow(uuid:String):void {
        if (safetyCheck()) {
            ctx.call("showInfoWindow", uuid);
        }
    }

    /**
     *
     * @param uuid
     *
     */
    public function hideInfoWindow(uuid:String):void {
        if (safetyCheck()) {
            ctx.call("hideInfoWindow", uuid);
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
            ctx.call("setStyle", json);
        }
    }

    /**
     *
     * @param value in milliseconds, Android only
     *
     */
    public function set animationDuration(value:int):void {
        if (safetyCheck()) {
            ctx.call("setAnimationDuration", value);
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
        return _isSupported;
    }

    public function dispose():void {
        if (!ctx) {
            trace("[" + NAME + "] Error. ANE Already in a disposed or failed state...");
            return;
        }
        trace("[" + NAME + "] Unloading ANE...");
        ctx.removeEventListener(StatusEvent.STATUS, gotEvent);
        ctx.dispose();
        ctx = null;
    }

    /**
     *
     * @return
     *
     */
    public function get markers():Dictionary {
        return _markers;
    }
}
}
