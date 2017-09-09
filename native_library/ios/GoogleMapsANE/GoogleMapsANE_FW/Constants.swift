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

import Foundation

public struct Constants {
    public static let ON_READY: String = "GoogleMaps.OnReady";
    public static let DID_TAP_AT: String = "GoogleMaps.DidTapAt"
    public static let DID_LONG_PRESS_AT: String = "GoogleMaps.DidLongPressAt"
    public static let DID_TAP_MARKER: String = "GoogleMaps.DidTapMarker"
    public static let DID_BEGIN_DRAGGING: String = "GoogleMaps.DidBeginDragging"
    public static let DID_END_DRAGGING: String = "GoogleMaps.DidEndDragging"
    public static let DID_DRAG: String = "GoogleMaps.DidDrag"
    
    public static let DID_TAP_INFO_WINDOW: String = "GoogleMaps.DidTapInfoWindow"
    public static let DID_CLOSE_INFO_WINDOW: String = "GoogleMaps.DidCloseInfoWindow"
    public static let DID_LONG_PRESS_INFO_WINDOW: String = "GoogleMaps.DidLongPressInfoWindow"
    
    public static let ON_CAMERA_MOVE: String = "GoogleMaps.OnCameraMove"
    public static let ON_CAMERA_MOVE_STARTED: String = "GoogleMaps.OnCameraMoveStarted"
    public static let ON_CAMERA_IDLE: String = "GoogleMaps.OnCameraIdle"
    
    public static let LOCATION_UPDATED:String = "Location.LocationUpdated"
    public static let AUTHORIZATION_STATUS:String = "Location.AuthorizationStatus"
    public static let AUTHORIZATION_GRANTED: String = "Location.AuthorizationGranted"
    public static let AUTHORIZATION_DENIED: String = "Location.AuthorizationDenied"
    public static let AUTHORIZATION_STATUS_ALWAYS:Int = 3
    public static let AUTHORIZATION_STATUS_DENIED:Int = 2
}
