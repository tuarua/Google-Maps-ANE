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
import com.google.android.gms.maps.model.CircleOptions
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.PatternItem
import com.google.android.gms.maps.model.Gap
import com.google.android.gms.maps.model.Dash
import com.google.android.gms.maps.model.Dot
import java.util.Arrays;


class FreCircleOptionsKotlin() : FreObjectKotlin() {
    private var TAG = "com.tuarua.FreCircleOptionsKotlin"

    constructor(freObjectKotlin: FreObjectKotlin?) : this() {
        rawValue = freObjectKotlin?.rawValue
    }

    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: CircleOptions
        @Throws(FreException::class)
        get() {
            try {
                val center = LatLng(this.getProperty("coordinate"))
                val radius = Double(this.getProperty("radius")) ?: 1.0
                val strokeWidth = Float(this.getProperty("strokeWidth")) ?: 10.0F
                val zIndex = Float(this.getProperty("zIndex")) ?: 0.0F
                val visible = Boolean(this.getProperty("visible")) == true

                val strokePatternFre = this.getProperty("strokePattern")
                val strokePatternType = Int(strokePatternFre?.getProperty("type")) ?: 0
                val strokePatternDashLength = Int(strokePatternFre?.getProperty("dashLength")) ?: 50
                val strokePatternGapLength = Int(strokePatternFre?.getProperty("gapLength")) ?: 50

                val strokeColorFre = this.getProperty("strokeColor")
                val strokeAlpha = Double(this.getProperty("strokeAlpha")) ?: 1.0
                val fillColorFre = this.getProperty("fillColor")
                val fillAlpha = Double(this.getProperty("fillAlpha")) ?: 1.0

                val strokeColor = strokeColorFre?.toColor((255 * strokeAlpha).toInt()) ?: 0
                val fillColor = fillColorFre?.toColor((255 * fillAlpha).toInt()) ?: 0

                val DOT = Dot()
                val DASH = Dash(strokePatternDashLength.toFloat())
                val GAP = Gap(strokePatternGapLength.toFloat())
                var strokePattern: MutableList<PatternItem>? = null

                when (strokePatternType) {
                    0 -> {
                        strokePattern = null
                    }
                    1 -> {
                        strokePattern = Arrays.asList(DASH, GAP)
                    }
                    2 -> {
                        strokePattern = Arrays.asList(DOT, GAP)
                    }
                    3 -> {
                        strokePattern = Arrays.asList(DOT, GAP, DOT, DASH, GAP)
                    }
                }

                return CircleOptions()
                        .center(center)
                        .radius(radius)
                        .strokeWidth(strokeWidth)
                        .zIndex(zIndex)
                        .visible(visible)
                        .strokeColor(strokeColor)
                        .fillColor(fillColor)
                        .strokePattern(strokePattern)
            } catch (e: FreException) {
                throw e
            } catch (e: Exception) {
                throw FreException(e)
            }
        }
}

fun CircleOptions(freObject: FREObject?): CircleOptions = FreCircleOptionsKotlin(freObject = freObject).value