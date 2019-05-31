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

import com.adobe.fre.FREObject
import com.tuarua.frekotlin.Boolean
import com.tuarua.frekotlin.get

class Settings() {
    var allowScrollGesturesDuringRotateOrZoom = true
    var scrollGestures = false
    var zoomGestures = true
    var tiltGestures = true
    var rotateGestures = true
    var compassButton = false
    var myLocationButtonEnabled = false
    var indoorPicker = true
    var mapToolbarEnabled = true

    constructor(freObject: FREObject) : this() {
        this.compassButton = Boolean(freObject["compassButton"]) == true
        this.indoorPicker = Boolean(freObject["indoorPicker"]) == true
        this.myLocationButtonEnabled = Boolean(freObject["myLocationButtonEnabled"]) == true
        this.rotateGestures = Boolean(freObject["rotateGestures"]) == true
        this.scrollGestures = Boolean(freObject["scrollGestures"]) == true
        this.tiltGestures = Boolean(freObject["tiltGestures"]) == true
        this.zoomGestures = Boolean(freObject["zoomGestures"]) == true
        this.mapToolbarEnabled = Boolean(freObject["mapToolbarEnabled"]) == true
        this.allowScrollGesturesDuringRotateOrZoom = Boolean(freObject["allowScrollGesturesDuringRotateOrZoom"]) == true
    }
}