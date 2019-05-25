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
import java.util.*
import com.google.android.gms.maps.model.RoundCap
import com.tuarua.frekotlin.*

fun PolylineOptions(freObject: FREObject?): PolylineOptions {
    val rv = freObject ?: return PolylineOptions()
    val clickable = Boolean(rv["isTappable"]) == true
    val color = rv["color"]?.toColor() ?: 0
    val geodesic = Boolean(rv["geodesic"]) == true
    val visible = Boolean(rv["visible"]) == true
    val zIndex = Float(rv["zIndex"]) ?: 0.0F
    val width = Float(rv["width"]) ?: 10.0F
    val jointType = Int(rv["jointType"]) ?: 0
    val patternFre = rv["pattern"]
    val patternType = Int(patternFre["type"]) ?: 0
    val patternDashLength = Int(patternFre["dashLength"]) ?: 50
    val patternGapLength = Int(patternFre["gapLength"]) ?: 50

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

    var startCap: Cap = SquareCap()
    when (Int(patternFre["startCap"]) ?: 2) {
        0 -> startCap = ButtCap()
        1 -> startCap = RoundCap()
        2 -> startCap = SquareCap()
    }

    var endCap: Cap = SquareCap()
    when (Int(patternFre["endCap"]) ?: 2) {
        0 -> endCap = ButtCap()
        1 -> endCap = RoundCap()
        2 -> endCap = SquareCap()
    }

    val points: MutableList<LatLng> = mutableListOf()
    val pointsFre = rv["points"]
    if (pointsFre != null) {
        val pointsArray = FREArray(pointsFre)
        for (fre in pointsArray) {
            points.add(LatLng(fre))
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
}

fun Polyline.setClickable(value: FREObject?) {
    Boolean(value)?.let { this.isClickable = it }
}

fun Polyline.setColor(value: FREObject?) {
    value?.toColor()?.let { this.color = it }
}

fun Polyline.setVisible(value: FREObject?) {
    Boolean(value)?.let { this.isVisible = it }
}

fun Polyline.setZIndex(value: FREObject?) {
    Float(value)?.let { this.zIndex = it }
}

fun Polyline.setWidth(value: FREObject?) {
    Float(value)?.let { this.width = it }
}

fun Polyline.setGeodesic(value: FREObject?) {
    Boolean(value)?.let { this.isGeodesic = it }
}

fun Polyline.setJointType(value: FREObject?) {
    Int(value)?.let { this.jointType = it }
}

fun Polyline.addAll(value: FREObject?) {
    val rv = value ?: return
    val points: MutableList<LatLng> = mutableListOf()
    val pointsArray = FREArray(rv)
    for (fre in pointsArray) {
        points.add(LatLng(fre))
    }
    this.points = points
}

fun Polyline.setPattern(value: FREObject?) {
    val patternType = Int(value["type"])
    val patternDashLength = Int(value["dashLength"])
    val patternGapLength = Int(value["gapLength"])
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