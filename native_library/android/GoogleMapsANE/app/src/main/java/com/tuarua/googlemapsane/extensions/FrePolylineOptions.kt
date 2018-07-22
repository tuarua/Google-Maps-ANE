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

import com.adobe.fre.FREArray
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.*
import java.util.*
import com.google.android.gms.maps.model.RoundCap
import com.tuarua.frekotlin.*

class FrePolylineOptions() : FreObjectKotlin() {
    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: PolylineOptions
        @Throws(FreException::class)
        get() {
            val rv = rawValue
            if (rv != null) {
                try {
                    val clickable = Boolean(rv["isTappable"]) == true
                    val color = rv["color"]?.toColor(true) ?: 0
                    val geodesic = Boolean(rv["geodesic"]) == true
                    val visible = Boolean(rv["visible"]) == true
                    val zIndex = Float(rv["zIndex"]) ?: 0.0F
                    val width = Float(rv["width"]) ?: 10.0F
                    val jointType = Int(rv["jointType"]) ?: 0
                    val patternFre = rv["pattern"]
                    val patternType = Int(patternFre?.get("type")) ?: 0
                    val patternDashLength = Int(patternFre?.get("dashLength"))
                            ?: 50
                    val patternGapLength = Int(patternFre?.get("gapLength")) ?: 50

                    val dot = Dot()
                    val dash = Dash(patternDashLength.toFloat())
                    val gap = Gap(patternGapLength.toFloat())
                    var pattern: MutableList<PatternItem>? = null

                    when (patternType) {
                        0 -> pattern = null
                        1 -> pattern = Arrays.asList(dash, gap)
                        2 -> pattern = Arrays.asList(dot, gap)
                        3 -> pattern = Arrays.asList(dot, gap, dot, dash, gap)
                    }

                    var startCap:Cap = SquareCap()
                    val startCapFre = Int(patternFre?.get("startCap")) ?: 2
                    when (startCapFre) {
                        0 -> startCap = ButtCap()
                        1 -> startCap = RoundCap()
                        2 -> startCap = SquareCap()
                    }

                    var endCap:Cap = SquareCap()
                    val endCapFre = Int(patternFre?.get("endCap")) ?: 2
                    when (endCapFre) {
                        0 -> endCap = ButtCap()
                        1 -> endCap = RoundCap()
                        2 -> endCap = SquareCap()
                    }

                    val points: MutableList<LatLng> = mutableListOf()
                    val pointsFre = rv["points"]
                    if (pointsFre != null) {
                        val pointsArray: FREArray? = FREArray(freObject = pointsFre)
                        if (pointsArray != null) {
                            val pointsArrayLen = pointsArray.length
                            (0 until pointsArrayLen).mapTo(points) { LatLng(pointsArray[it.toInt()]) }
                        }
                    }

                    return PolylineOptions()
                            .clickable(clickable)
                            .color(color)
                            .geodesic(geodesic)
                            .visible(visible)
                            .zIndex(zIndex)
                            .width(width)
                            .pattern(pattern)
                            .jointType(jointType)
                            .startCap(startCap)
                            .endCap(endCap)
                            .addAll(points)
                } catch (e: FreException) {
                    throw e
                } catch (e: Exception) {
                    throw FreException(e)
                }
            }
            return PolylineOptions()
        }
}
fun PolylineOptions(freObject: FREObject?): PolylineOptions = FrePolylineOptions(freObject = freObject).value

fun Polyline.setClickable(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isClickable = v
    }
}

fun Polyline.setColor(value: FREObject?) {
    val color = value?.toColor(true)
    if (color != null) {
        this.color = color
    }
}

fun Polyline.setVisible(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isVisible = v
    }
}

fun Polyline.setZIndex(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.zIndex = v
    }
}

fun Polyline.setWidth(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.width = v
    }
}

fun Polyline.setGeodesic(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isGeodesic = v
    }
}

fun Polyline.setJointType(value: FREObject?) {
    val v = Int(value)
    if (v != null) {
        this.jointType
    }
}

fun Polyline.addAll(value: FREObject?) {
    val points: MutableList<LatLng> = mutableListOf()
    if (value != null) {
        val pointsArray: FREArray? = FREArray(freObject = value)
        if (pointsArray != null) {
            val pointsArrayLen = pointsArray.length
            (0 until pointsArrayLen).mapTo(points) { LatLng(pointsArray[it.toInt()]) }
        }
    }
    this.points = points
}

fun Polyline.setPattern(value: FREObject?) {
    val patternType = Int(value?.get("type"))
    val patternDashLength = Int(value?.get("dashLength"))
    val patternGapLength = Int(value?.get("gapLength"))
    if (patternDashLength == null) return
    if (patternGapLength == null) return
    val dot = Dot()
    val dash = Dash(patternDashLength.toFloat())
    val gap = Gap(patternGapLength.toFloat())
    var pattern: MutableList<PatternItem>? = null
    when (patternType) {
        0 -> pattern = null
        1 -> pattern = Arrays.asList(dash, gap)
        2 -> pattern = Arrays.asList(dot, gap)
        3 -> pattern = Arrays.asList(dot, gap, dot, dash, gap)
    }
    this.pattern = pattern
}

