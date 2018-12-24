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

public struct Constants {
    public static let ON_LOADED = "GoogleMaps.OnLoaded"
    public static let ON_READY = "GoogleMaps.OnReady"
    public static let DID_TAP_AT = "GoogleMaps.DidTapAt"
    public static let DID_LONG_PRESS_AT = "GoogleMaps.DidLongPressAt"
    public static let DID_TAP_MARKER = "GoogleMaps.DidTapMarker"
    public static let DID_BEGIN_DRAGGING = "GoogleMaps.DidBeginDragging"
    public static let DID_END_DRAGGING = "GoogleMaps.DidEndDragging"
    public static let DID_DRAG = "GoogleMaps.DidDrag"
    public static let DID_TAP_INFO_WINDOW = "GoogleMaps.DidTapInfoWindow"
    public static let DID_CLOSE_INFO_WINDOW = "GoogleMaps.DidCloseInfoWindow"
    public static let DID_LONG_PRESS_INFO_WINDOW = "GoogleMaps.DidLongPressInfoWindow"
    public static let ON_CAMERA_MOVE = "GoogleMaps.OnCameraMove"
    public static let ON_CAMERA_MOVE_STARTED = "GoogleMaps.OnCameraMoveStarted"
    public static let ON_CAMERA_IDLE = "GoogleMaps.OnCameraIdle"
    public static let LOCATION_UPDATED = "Location.LocationUpdated"
    public static let ON_ADDRESS_LOOKUP = "Location.OnAddressLookup"
    public static let ON_ADDRESS_LOOKUP_ERROR = "Location.OnAddressLookupError"
    public static let ON_PERMISSION_STATUS = "Permission.OnStatus"
    public static let ON_BITMAP_READY = "GoogleMaps.OnBitmapReady"
    public static let PERMISSION_NOT_DETERMINED = 0
    public static let PERMISSION_RESTRICTED = 1
    public static let PERMISSION_DENIED = 2
    public static let PERMISSION_ALWAYS = 3
    public static let PERMISSION_WHEN_IN_USE = 4
}
