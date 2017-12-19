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
import com.google.android.gms.maps.model.PatternItem
import com.google.android.gms.maps.model.Gap
import com.google.android.gms.maps.model.Dash
import com.google.android.gms.maps.model.Dot
import java.util.Arrays


class FreCircleOptionsKotlin() : FreObjectKotlin() {
    private var TAG = "com.tuarua.FreCircleOptionsKotlin"

    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: CircleOptions
        @Throws(FreException::class)
        get() {
            val rv = rawValue
            if (rv != null) {
                try {
                    val center = LatLng(rv["coordinate"])
                    val radius = Double(rv["radius"]) ?: 1.0
                    val strokeWidth = Float(rv["strokeWidth"]) ?: 10.0F
                    val zIndex = Float(rv["zIndex"]) ?: 0.0F
                    val visible = Boolean(rv["visible"]) == true
                    val strokePatternFre = rv["strokePattern"]
                    val strokePatternType = Int(strokePatternFre?.get("type")) ?: 0
                    val strokePatternDashLength = Int(strokePatternFre?.get("dashLength")) ?: 50
                    val strokePatternGapLength = Int(strokePatternFre?.get("gapLength")) ?: 50
                    val strokeColor = rv["strokeColor"]?.toColor(true) ?: 0
                    val fillColor = rv["fillColor"]?.toColor(true) ?: 0

                    val dot = Dot()
                    val dash = Dash(strokePatternDashLength.toFloat())
                    val gap = Gap(strokePatternGapLength.toFloat())
                    var strokePattern: MutableList<PatternItem>? = null

                    when (strokePatternType) {
                        0 -> {
                            strokePattern = null
                        }
                        1 -> {
                            strokePattern = Arrays.asList(dash, gap)
                        }
                        2 -> {
                            strokePattern = Arrays.asList(dot, gap)
                        }
                        3 -> {
                            strokePattern = Arrays.asList(dot, gap, dot, dash, gap)
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
            return CircleOptions()
        }
}

fun CircleOptions(freObject: FREObject?): CircleOptions = FreCircleOptionsKotlin(freObject = freObject).value