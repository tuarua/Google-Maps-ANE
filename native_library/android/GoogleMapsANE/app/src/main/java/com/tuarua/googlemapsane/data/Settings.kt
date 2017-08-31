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
package com.tuarua.googlemapsane.data
data class Settings(
        var scrollGestures: Boolean = false,
        var zoomGestures: Boolean = true,
        var tiltGestures: Boolean = true,
        var rotateGestures: Boolean = true,
        var compassButton: Boolean = false,
        var myLocationButton: Boolean = false,
        var indoorPicker: Boolean = true
)