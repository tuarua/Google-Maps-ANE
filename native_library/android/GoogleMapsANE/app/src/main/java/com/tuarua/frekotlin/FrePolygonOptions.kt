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
import com.adobe.fre.FREArray
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.*
import java.util.*

class FrePolygonOptions() : FreObjectKotlin() {
    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: PolygonOptions
        @Throws(FreException::class)
        get() {
            val rv = rawValue
            if (rv != null) {
                try {
                    val clickable = Boolean(rv["clickable"]) == true
                    val geodesic = Boolean(rv["geodesic"]) == true
                    val visible = Boolean(rv["visible"]) == true
                    val zIndex = Float(rv["zIndex"]) ?: 0.0F
                    val strokeJointType = Int(rv["strokeJointType"]) ?: 0
                    val fillColor = rv["fillColor"]?.toColor(true) ?: 0
                    val strokeColor = rv["strokeColor"]?.toColor(true) ?: 0
                    val strokeWidth = Float(rv["strokeWidth"]) ?: 10.0F
                    val strokePatternFre = rv["strokePattern"]
                    val strokePatternType = Int(strokePatternFre?.get("type")) ?: 0
                    val strokePatternDashLength = Int(strokePatternFre?.get("dashLength")) ?: 50
                    val strokePatternGapLength = Int(strokePatternFre?.get("gapLength")) ?: 50

                    val dot = Dot()
                    val dash = Dash(strokePatternDashLength.toFloat())
                    val gap = Gap(strokePatternGapLength.toFloat())
                    var strokePattern: MutableList<PatternItem>? = null

                    when (strokePatternType) {
                        0 -> strokePattern = null
                        1 -> strokePattern = Arrays.asList(dash, gap)
                        2 -> strokePattern = Arrays.asList(dot, gap)
                        3 -> strokePattern = Arrays.asList(dot, gap, dot, dash, gap)
                    }

                    val po = PolygonOptions()
                            .clickable(clickable)
                            .geodesic(geodesic)
                            .visible(visible)
                            .zIndex(zIndex)
                            .strokeJointType(strokeJointType)
                            .fillColor(fillColor)
                            .strokeColor(strokeColor)
                            .strokeWidth(strokeWidth)
                            .strokePattern(strokePattern)

                    val points: MutableList<LatLng> = mutableListOf()
                    val pointsFre = rv["points"]
                    if (pointsFre != null) {
                        val pointsArray: FREArray? = FREArray(freObject = pointsFre)
                        if (pointsArray != null) {
                            val pointsArrayLen = pointsArray.length
                            (0 until pointsArrayLen).mapTo(points) { LatLng(pointsArray[it.toInt()]) }
                        }
                    }

                    if (!points.isEmpty()) {
                        po.addAll(points)
                    }

                    val holesFre = rv["holes"]
                    if (holesFre != null) {
                        val holesArray: FREArray? = FREArray(freObject = holesFre)
                        if (holesArray != null) {
                            val holesArrayLen = holesArray.length
                            (0 until holesArrayLen).forEach { i ->
                                val freItem = holesArray.get(index = i.toInt())
                                if (freItem != null) {
                                    val holePoints: MutableList<LatLng> = mutableListOf()
                                    val holePointsArray: FREArray? = FREArray(freObject = freItem)
                                    if (holePointsArray != null) {
                                        val holePointsArrayLen = holePointsArray.length
                                        (0 until holePointsArrayLen)
                                                .mapNotNull { holePointsArray[it.toInt()] }
                                                .mapTo(holePoints) { LatLng(it) }
                                    }
                                    po.addHole(holePoints)
                                }
                            }
                        }
                    }
                    return po
                } catch (e: FreException) {
                    throw e
                } catch (e: Exception) {
                    throw FreException(e)
                }

            }
            return PolygonOptions()
        }
}

fun PolygonOptions(freObject: FREObject?): PolygonOptions = FrePolygonOptions(freObject = freObject).value
fun Polygon.setClickable(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isClickable = v
    }
}

fun Polygon.setGeodesic(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isGeodesic = v
    }
}

fun Polygon.setVisible(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isVisible = v
    }
}

fun Polygon.setZIndex(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.zIndex = v
    }
}

fun Polygon.setFillColor(value: FREObject?) {
    val fillColor = value?.toColor(true)
    if (fillColor != null) {
        this.fillColor = fillColor
    }
}

fun Polygon.setStrokeWidth(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.strokeWidth = v
    }
}

fun Polygon.setStrokeColor(value: FREObject?) {
    val strokeColor = value?.toColor(true)
    if (strokeColor != null) {
        this.strokeColor = strokeColor
    }
}

fun Polygon.setStrokePattern(value: FREObject?) {
    val strokePatternType = Int(value?.get("type"))
    val strokePatternDashLength = Int(value?.get("dashLength"))
    val strokePatternGapLength = Int(value?.get("gapLength"))
    if (strokePatternDashLength == null) return
    if (strokePatternGapLength == null) return
    val dot = Dot()
    val dash = Dash(strokePatternDashLength.toFloat())
    val gap = Gap(strokePatternGapLength.toFloat())
    var strokePattern: MutableList<PatternItem>? = null
    when (strokePatternType) {
        0 -> strokePattern = null
        1 -> strokePattern = Arrays.asList(dash, gap)
        2 -> strokePattern = Arrays.asList(dot, gap)
        3 -> strokePattern = Arrays.asList(dot, gap, dot, dash, gap)
    }
    this.strokePattern = strokePattern
}

fun Polygon.setStrokeJointType(value: FREObject?) {
    val v = Int(value)
    if (v != null) {
        this.strokeJointType
    }
}

fun Polygon.addAll(value: FREObject?) {
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

fun Polygon.addHoles(value: FREObject?) {
    val holes: MutableList<MutableList<LatLng>> = mutableListOf()
    if (value != null) {
        val holesArray: FREArray? = FREArray(freObject = value)
        if (holesArray != null) {
            val holesArrayLen = holesArray.length
            for (i in 0 until holesArrayLen) {
                val freItem = holesArray.get(index = i.toInt())
                if (freItem != null) {
                    val holePoints: MutableList<LatLng> = mutableListOf()
                    val holePointsArray: FREArray? = FREArray(freObject = freItem)
                    if (holePointsArray != null) {
                        val holePointsArrayLen = holePointsArray.length
                        (0 until holePointsArrayLen)
                                .mapNotNull { holePointsArray.get(it.toInt()) }
                                .mapTo(holePoints) { LatLng(it) }
                    }
                    holes.add(holePoints)
                }
            }
        }
    }
    this.holes = holes
}