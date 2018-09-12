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
import com.google.android.gms.maps.model.*
import com.tuarua.frekotlin.*
import java.util.*

fun PolygonOptions(freObject: FREObject?): PolygonOptions {
    val rv = freObject ?: return PolygonOptions()
    val clickable = Boolean(rv["isTappable"]) == true
    val geodesic = Boolean(rv["geodesic"]) == true
    val visible = Boolean(rv["visible"]) == true
    val zIndex = Float(rv["zIndex"]) ?: 0.0F
    val strokeJointType = Int(rv["strokeJointType"]) ?: 0
    val fillColor = rv["fillColor"]?.toColor() ?: 0
    val strokeColor = rv["strokeColor"]?.toColor() ?: 0
    val strokeWidth = Float(rv["strokeWidth"]) ?: 10.0F
    val strokePatternFre = rv["strokePattern"]
    val strokePatternType = Int(strokePatternFre["type"]) ?: 0
    val strokePatternDashLength = Int(strokePatternFre["dashLength"]) ?: 50
    val strokePatternGapLength = Int(strokePatternFre["gapLength"]) ?: 50

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
        val pointsArray = FREArray(pointsFre)
        for (fre in pointsArray) {
            points.add(LatLng(fre))
        }
    }

    if (!points.isEmpty()) {
        po.addAll(points)
    }

    val holesFre = rv["holes"]
    if (holesFre != null) {
        val holesArray = FREArray(holesFre)
        for (freItem in holesArray) {
            if (freItem == null) continue
            val holePoints: MutableList<LatLng> = mutableListOf()
            val holePointsArray = FREArray(freItem)
            for (freLatLng in holePointsArray) {
                if (freLatLng == null) continue
                holePoints.add(LatLng(freLatLng))
            }
            po.addHole(holePoints)
        }
    }
    return po

}

fun Polygon.setClickable(value: FREObject?) {
    Boolean(value)?.let { this.isClickable = it }
}

fun Polygon.setGeodesic(value: FREObject?) {
    Boolean(value)?.let { this.isGeodesic = it }
}

fun Polygon.setVisible(value: FREObject?) {
    Boolean(value)?.let { this.isVisible = it }
}

fun Polygon.setZIndex(value: FREObject?) {
    Float(value)?.let { this.zIndex = it }
}

fun Polygon.setFillColor(value: FREObject?) {
    value?.toColor()?.let { this.fillColor = it }
}

fun Polygon.setStrokeWidth(value: FREObject?) {
    Float(value)?.let { this.strokeWidth = it }
}

fun Polygon.setStrokeColor(value: FREObject?) {
    value?.toColor()?.let { this.strokeColor = it }
}

fun Polygon.setStrokePattern(value: FREObject?) {
    val strokePatternType = Int(value["type"])
    val strokePatternDashLength = Int(value["dashLength"])
    val strokePatternGapLength = Int(value["gapLength"])
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
    this.strokeJointType = Int(value) ?: this.strokeJointType
}

fun Polygon.addAll(value: FREObject?) {
    val rv = value ?: return
    val points: MutableList<LatLng> = mutableListOf()
    val pointsArray = FREArray(rv)
    for (fre in pointsArray) {
        points.add(LatLng(fre))
    }
    this.points = points
}

fun Polygon.addHoles(value: FREObject?) {
    val rv = value ?: return
    val holes: MutableList<MutableList<LatLng>> = mutableListOf()
    val holesArray = FREArray(rv)
    for (freItem in holesArray) {
        if (freItem == null) continue
        val holePoints: MutableList<LatLng> = mutableListOf()
        val holePointsArray = FREArray(freItem)
        for (freLatLng in holePointsArray) {
            if (freLatLng == null) continue
            holePoints.add(LatLng(freLatLng))
        }
        holes.add(holePoints)
    }
    this.holes = holes
}