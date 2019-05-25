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
package com.tuarua.googlemaps {
import flash.events.Event;

public class GoogleMapsEvent extends Event {
    public static const ON_LOADED:String = "GoogleMaps.OnLoaded";
    public static const ON_READY:String = "GoogleMaps.OnReady";
    public static const DID_TAP_AT:String = "GoogleMaps.DidTapAt";
    /**
     * This event is not fired with Apple Maps
     */
    public static const DID_LONG_PRESS_AT:String = "GoogleMaps.DidLongPressAt";
    public static const DID_TAP_MARKER:String = "GoogleMaps.DidTapMarker";
    public static const DID_BEGIN_DRAGGING:String = "GoogleMaps.DidBeginDragging";
    public static const DID_END_DRAGGING:String = "GoogleMaps.DidEndDragging";
    /**
     * This event is not fired with Apple Maps
     */
    public static const DID_DRAG:String = "GoogleMaps.DidDrag";
    /**
     * This event is not fired with Apple Maps
     */
    public static const DID_TAP_INFO_WINDOW:String = "GoogleMaps.DidTapInfoWindow";
    /**
     * This event is not fired with Apple Maps
     */
    public static const DID_TAP_GROUND_OVERLAY: String = "GoogleMaps.DidTapGroundOverlay";
    public static const DID_TAP_POLYLINE: String = "GoogleMaps.DidTapPolyline";
    public static const DID_TAP_POLYGON: String = "GoogleMaps.DidTapPolygon";

    /**
     * This event is not fired with Apple Maps
     */
    public static const DID_CLOSE_INFO_WINDOW:String = "GoogleMaps.DidCloseInfoWindow";
    /**
     * This event is not fired with Apple Maps
     */
    public static const DID_LONG_PRESS_INFO_WINDOW:String = "GoogleMaps.DidLongPressInfoWindow";
    public static const ON_CAMERA_MOVE:String = "GoogleMaps.OnCameraMove";
    /**
     * This event is not fired with Apple Maps
     */
    public static const ON_CAMERA_MOVE_STARTED:String = "GoogleMaps.OnCameraMoveStarted";
    /**
     * This event is not fired with Apple Maps
     */
    public static const ON_CAMERA_IDLE:String = "GoogleMaps.OnCameraIdle";
    public static const CAMERA_MOVE_REASON_GESTURE:int = 1;
    public static const CAMERA_MOVE_REASON_API_ANIMATION:int = 2;
    public static const CAMERA_MOVE_REASON_DEVELOPER_ANIMATION:int = 3;
    public static const ON_BITMAP_READY:String = "GoogleMaps.OnBitmapReady";

    public var params:*;

    //noinspection ReservedWordAsName
    public function GoogleMapsEvent(type:String, params:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.params = params;
    }

    public override function clone():Event {
        return new GoogleMapsEvent(type, this.params, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("GoogleMapsEvent", "params", "type", "bubbles", "cancelable");
    }
}
}
