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
    val ON_READY: String = "GoogleMaps.OnReady";
    val DID_TAP_AT: String = "GoogleMaps.DidTapAt"
    val DID_LONG_PRESS_AT: String = "GoogleMaps.DidLongPressAt"
    val DID_TAP_MARKER: String = "GoogleMaps.DidTapMarker"
    val DID_BEGIN_DRAGGING: String = "GoogleMaps.DidBeginDragging"
    val DID_END_DRAGGING: String = "GoogleMaps.DidEndDragging"
    val DID_DRAG: String = "GoogleMaps.DidDrag"
    val DID_TAP_INFO_WINDOW: String = "GoogleMaps.DidTapInfoWindow"
    val DID_CLOSE_INFO_WINDOW: String = "GoogleMaps.DidCloseInfoWindow"
    val DID_LONG_PRESS_INFO_WINDOW: String = "GoogleMaps.DidLongPressInfoWindow"
    val ON_CAMERA_MOVE: String = "GoogleMaps.OnCameraMove"
    val ON_CAMERA_MOVE_STARTED: String = "GoogleMaps.OnCameraMoveStarted"
    val ON_CAMERA_IDLE: String = "GoogleMaps.OnCameraIdle"
    val LOCATION_UPDATED: String = "Location.LocationUpdated"
    val AUTHORIZATION_STATUS: String = "Location.AuthorizationStatus"
    val AUTHORIZATION_GRANTED: String = "Location.AuthorizationGranted"
    val AUTHORIZATION_DENIED: String = "Location.AuthorizationDenied"
    val AUTHORIZATION_STATUS_ALWAYS:Int = 3
    val AUTHORIZATION_STATUS_DENIED:Int = 2
}