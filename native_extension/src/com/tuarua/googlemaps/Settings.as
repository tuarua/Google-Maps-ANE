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
public class Settings {
    [RemoteClass(alias="com.tuarua.googlemaps.Settings")]
    /**
     * Controls whether scroll gestures are enabled (default) or disabled. If
     * enabled, users may drag to pan the camera. This does not limit programmatic
     * movement of the camera.
     */
    public var scrollGestures:Boolean = true;
    /**
     * Controls whether zoom gestures are enabled (default) or disabled. If
     * enabled, users may double tap/two-finger tap or pinch to zoom the camera.
     * This does not limit programmatic movement of the camera.
     */
    public var zoomGestures:Boolean = true;
    /**
     * Controls whether tilt gestures are enabled (default) or disabled. If enabled,
     * users may use a two-finger vertical down or up swipe to tilt the camera. This
     * does not limit programmatic control of the camera's viewingAngle.
     */
    public var tiltGestures:Boolean = true;
    /**
     * Controls whether rotate gestures are enabled (default) or disabled. If
     * enabled, users may use a two-finger rotate gesture to rotate the camera. This
     * does not limit programmatic control of the camera's bearing.
     */
    public var rotateGestures:Boolean = true;
    /**
     * Controls whether gestures by users are completely consumed by the GMSMapView
     * when gestures are enabled (default true).  This prevents these gestures from
     * being received by parent views.
     *
     * When the GMSMapView is contained by a UIScrollView (or other scrollable area),
     * this means that gestures on the map will not be additional consumed as scroll
     * gestures.  However, disabling this (set to NO) may be useful to support
     * complex view hierarchies or requirements.
     *
     * Ignored on Apple Maps
     *
     */
    public var consumesGesturesInView:Boolean = true;
    /**
     * Enables or disables the compass. The compass is an icon on the map that
     * indicates the direction of north on the map.
     *
     * If enabled, it is only shown when the camera is rotated away from its default
     * orientation (bearing of 0). When a user taps the compass, the camera orients
     * itself to its default orientation and fades away shortly after. If disabled,
     * the compass will never be displayed.
     */
    public var compassButton:Boolean = false;
    /**
     * Enables or disables the My Location button. This is a button visible on the
     * map that, when tapped by users, will center the map on the current user
     * location.
     */
    public var myLocationButtonEnabled:Boolean = false;
    /**
     * Enables or disables the my-location layer.
     */
    public var myLocationEnabled:Boolean = false;
    /**
     * Enables (default) or disables the indoor floor picker. If enabled, it is only
     * visible when the view is focused on a building with indoor floor data.
     * If disabled, the selected floor can still be controlled programmatically via
     * the indoorDisplay mapView property.
     *
     * Ignored on Apple Maps
     *
     */
    public var indoorPicker:Boolean = true;
    /**
     * Controls whether rotate and zoom gestures can be performed off-center and scrolled around
     * (default true).
     *
     * Ignored on Apple Maps
     *
     */
    public var allowScrollGesturesDuringRotateOrZoom:Boolean = true;
    /**
     * Sets the preference for whether the Map Toolbar should be enabled or disabled. If enabled, and the Map
     * Toolbar can be shown in the current context, users will see a bar with various context-dependent actions,
     * including 'open this map in the Google Maps app' and 'find directions to the highlighted marker in the
     * Google Maps app' (default true).
     *
     * Ignored on Apple Maps
     *
     */
    public var mapToolbarEnabled:Boolean = true;
    /**
     * Sets whether 3D buildings layer is enabled. (default true).
     *
     * Ignored on iOS
     *
     */
    public var buildingsEnabled:Boolean = true;

    public function Settings() {
    }
}
}