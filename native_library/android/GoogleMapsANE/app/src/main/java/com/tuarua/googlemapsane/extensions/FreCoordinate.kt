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
@file:Suppress("unused")

package com.tuarua.googlemapsane.extensions

import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.LatLng
import com.tuarua.frekotlin.*

class FreCoordinate() : FreObjectKotlin() {
    private var TAG = "com.tuarua.FreCoordinate"

    constructor(value: LatLng) : this() {
        rawValue = FREObject("com.tuarua.googlemaps.Coordinate", value.longitude, value.latitude)
    }

    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: LatLng
        @Throws(FreException::class)
        get() {
            return LatLng(Double(rawValue?.get("latitude")) ?: 0.0,
                    Double(rawValue?.get("longitude")) ?: 0.0)
        }
}

fun LatLng(freObject: FREObject?): LatLng = FreCoordinate(freObject = freObject).value