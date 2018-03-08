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
package com.tuarua.googlemapsane

object Constants {
    const val ON_READY: String = "GoogleMaps.OnReady"
    const val ON_LOADED: String = "GoogleMaps.OnLoaded"
    const val DID_TAP_AT: String = "GoogleMaps.DidTapAt"
    const val DID_LONG_PRESS_AT: String = "GoogleMaps.DidLongPressAt"
    const val DID_TAP_MARKER: String = "GoogleMaps.DidTapMarker"
    const val DID_BEGIN_DRAGGING: String = "GoogleMaps.DidBeginDragging"
    const val DID_END_DRAGGING: String = "GoogleMaps.DidEndDragging"
    const val DID_DRAG: String = "GoogleMaps.DidDrag"
    const val DID_TAP_INFO_WINDOW: String = "GoogleMaps.DidTapInfoWindow"
    const val DID_TAP_GROUND_OVERLAY: String = "GoogleMaps.DidTapGroundOverlay"
    const val DID_TAP_POLYLINE: String = "GoogleMaps.DidTapPolyline"
    const val DID_TAP_POLYGON: String = "GoogleMaps.DidTapPolygon"
    const val DID_CLOSE_INFO_WINDOW: String = "GoogleMaps.DidCloseInfoWindow"
    const val DID_LONG_PRESS_INFO_WINDOW: String = "GoogleMaps.DidLongPressInfoWindow"
    const val ON_CAMERA_MOVE: String = "GoogleMaps.OnCameraMove"
    const val ON_CAMERA_MOVE_STARTED: String = "GoogleMaps.OnCameraMoveStarted"
    const val ON_CAMERA_IDLE: String = "GoogleMaps.OnCameraIdle"
    const val ON_BITMAP_READY: String = "GoogleMaps.OnBitmapReady"

    const val LOCATION_UPDATED: String = "Location.LocationUpdated"
    const val ON_ADDRESS_LOOKUP: String = "Location.OnAddressLookup"
    const val ON_ADDRESS_LOOKUP_ERROR: String = "Location.OnAddressLookupError"

    const val ON_PERMISSION_STATUS: String = "Permission.OnStatus"
    const val PERMISSION_DENIED = 2
    const val PERMISSION_ALWAYS = 3
    const val PERMISSION_SHOW_RATIONALE = 5
}
