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
package com.tuarua.googlemapsane.extensions

import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.tuarua.frekotlin.*

fun LatLng(freObject: FREObject?): LatLng {
    return LatLng(Double(freObject["latitude"]) ?: 0.0,
            Double(freObject["longitude"]) ?: 0.0)
}

fun LatLng.toFREObject(): FREObject? {
    return FREObject("com.tuarua.googlemaps.Coordinate", this.latitude, this.longitude)
}

fun LatLngBounds(freObject: FREObject?): LatLngBounds {
    return LatLngBounds(LatLng(freObject["southWest"]),
            LatLng(freObject["northEast"]))
}

fun LatLngBounds.toFREObject(): FREObject? {
    return FREObject("ccom.tuarua.googlemaps.CoordinateBounds",
            this.southwest.toFREObject(), this.northeast.toFREObject())
}