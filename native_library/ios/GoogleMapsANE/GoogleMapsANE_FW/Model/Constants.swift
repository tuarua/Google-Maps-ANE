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

struct Constants {
    static let ON_LOADED = "GoogleMaps.OnLoaded"
    static let ON_READY = "GoogleMaps.OnReady"
    static let DID_TAP_AT = "GoogleMaps.DidTapAt"
    static let DID_LONG_PRESS_AT = "GoogleMaps.DidLongPressAt"
    static let DID_TAP_MARKER = "GoogleMaps.DidTapMarker"
    static let DID_BEGIN_DRAGGING = "GoogleMaps.DidBeginDragging"
    static let DID_END_DRAGGING = "GoogleMaps.DidEndDragging"
    static let DID_DRAG = "GoogleMaps.DidDrag"
    static let DID_TAP_INFO_WINDOW = "GoogleMaps.DidTapInfoWindow"
    static let DID_CLOSE_INFO_WINDOW = "GoogleMaps.DidCloseInfoWindow"
    static let DID_LONG_PRESS_INFO_WINDOW = "GoogleMaps.DidLongPressInfoWindow"
    static let DID_TAP_GROUND_OVERLAY = "GoogleMaps.DidTapGroundOverlay"
    static let ON_CAMERA_MOVE = "GoogleMaps.OnCameraMove"
    static let ON_CAMERA_MOVE_STARTED = "GoogleMaps.OnCameraMoveStarted"
    static let ON_CAMERA_IDLE = "GoogleMaps.OnCameraIdle"
    static let LOCATION_UPDATED = "Location.LocationUpdated"
    static let ON_ADDRESS_LOOKUP = "Location.OnAddressLookup"
    static let ON_ADDRESS_LOOKUP_ERROR = "Location.OnAddressLookupError"
    static let ON_PERMISSION_STATUS = "Permission.OnStatus"
    static let ON_BITMAP_READY = "GoogleMaps.OnBitmapReady"
    static let PERMISSION_NOT_DETERMINED = 0
    static let PERMISSION_RESTRICTED = 1
    static let PERMISSION_DENIED = 2
    static let PERMISSION_ALWAYS = 3
    static let PERMISSION_WHEN_IN_USE = 4
}
