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

import android.graphics.Bitmap
import android.util.Log
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MarkerOptions
import com.tuarua.frekotlin.display.FreBitmapDataKotlin
import java.nio.ByteBuffer

class FreMarkerOptionsKotlin() : FreObjectKotlin() {
    private var TAG = "com.tuarua.FreMarkerOptionsKotlin"
    constructor(freObjectKotlin: FreObjectKotlin?) : this() {
        rawValue = freObjectKotlin?.rawValue
    }

    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: MarkerOptions?
        get() {
            val coordinate: LatLng = FreCoordinateKotlin(this.getProperty("coordinate")).value
            val title: String? = this.getProperty("title")?.value as String?
            val snippet: String? = this.getProperty("snippet")?.value as String?
            val draggable: Boolean = this.getProperty("isDraggable")?.value as Boolean
            val flat: Boolean = this.getProperty("isFlat")?.value as Boolean
            val tappable: Boolean = this.getProperty("isTappable")?.value as Boolean //TODO
            val opacityFre = this.getProperty("opacity")?.value
            val rotationFre = this.getProperty("rotation")?.value
            val opacity: Float = (opacityFre as? Int)?.toFloat() ?: (opacityFre as Double).toFloat()
            val rotation: Float = (rotationFre as? Int)?.toFloat() ?: (rotationFre as Double).toFloat()

            val colorFre = this.getProperty("color")
            val color = colorFre?.toHSV() ?: 0.0F

            val iconFre = (this.getProperty("icon") as FreObjectKotlin).rawValue
            var icon: Bitmap? = null
            try {
                if (iconFre is FREObject) {
                    val bmd = FreBitmapDataKotlin(iconFre)
                    bmd.acquire()
                    if (bmd.bits32 is ByteBuffer) {
                        icon = Bitmap.createBitmap(bmd.width, bmd.height, Bitmap.Config.ARGB_8888)
                        icon.copyPixelsFromBuffer(bmd.bits32)
                        //icon.recycle()
                    }
                    bmd.release()
                }
            } catch (e: Error) {
                Log.e(TAG, e.message)
                e.printStackTrace()
            }

            return MarkerOptions()
                    .position(coordinate)
                    .title(title)
                    .snippet(snippet)
                    .draggable(draggable)
                    .flat(flat)
                    .alpha(opacity)
                    .icon(if (icon is Bitmap) BitmapDescriptorFactory
                            .fromBitmap(icon) else BitmapDescriptorFactory
                            .defaultMarker(color))
                    .rotation(rotation)
        }
}