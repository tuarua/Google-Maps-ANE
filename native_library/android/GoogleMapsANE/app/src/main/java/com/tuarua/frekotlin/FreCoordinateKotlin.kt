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
package com.tuarua.frekotlin

import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.LatLng

class FreCoordinateKotlin() : FreObjectKotlin() {
    private var TAG = "com.tuarua.FreCoordinateKotlin"

    constructor(value: LatLng) : this() {
        rawValue = FreObjectKotlin("com.tuarua.googlemaps.Coordinate", value.longitude, value.latitude).rawValue
    }

    constructor(freObjectKotlin: FreObjectKotlin?) : this() {
        rawValue = freObjectKotlin?.rawValue
    }

    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: LatLng
        @Throws(FreException::class)
        get() {
            var lat = 0.0
            var lng = 0.0
            if (this.rawValue == null) return LatLng(lat, lng)
            try {
                val latFre = Double(this.getProperty("latitude"))
                val lngFre = Double(this.getProperty("longitude"))
                if (latFre != null && lngFre != null) {
                    lat = latFre
                    lng = lngFre
                }
            } catch (e: FreException) {
                throw e
            } catch (e: Exception) {
                throw FreException(e)
            }
            return LatLng(lat, lng)
        }
}

fun LatLng(freObject: FREObject?): LatLng = FreCoordinateKotlin(freObject = freObject).value
fun LatLng(freObjectKotlin: FreObjectKotlin?): LatLng = FreCoordinateKotlin(freObjectKotlin = freObjectKotlin).value