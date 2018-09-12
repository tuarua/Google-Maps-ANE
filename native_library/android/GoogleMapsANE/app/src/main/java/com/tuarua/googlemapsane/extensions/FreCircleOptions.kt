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
import java.util.Arrays

fun CircleOptions(freObject: FREObject?): CircleOptions {
    val rv = freObject ?: return CircleOptions()
    val clickable = Boolean(rv["isTappable"]) == true
    val center = LatLng(rv["center"])
    val radius = Double(rv["radius"]) ?: 1.0
    val strokeWidth = Float(rv["strokeWidth"]) ?: 10.0F
    val zIndex = Float(rv["zIndex"]) ?: 0.0F
    val visible = Boolean(rv["visible"]) == true
    val strokePatternFre = rv["strokePattern"]
    val strokePatternType = Int(strokePatternFre["type"]) ?: 0
    val strokePatternDashLength = Int(strokePatternFre["dashLength"]) ?: 50
    val strokePatternGapLength = Int(strokePatternFre["gapLength"]) ?: 50
    val strokeColor = rv["strokeColor"]?.toColor() ?: 0
    val fillColor = rv["fillColor"]?.toColor() ?: 0

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

    return CircleOptions()
            .center(center)
            .radius(radius)
            .strokeWidth(strokeWidth)
            .zIndex(zIndex)
            .visible(visible)
            .strokeColor(strokeColor)
            .fillColor(fillColor)
            .strokePattern(strokePattern)
            .clickable(clickable)
}

fun Circle.setClickable(value: FREObject?) {
    Boolean(value)?.let { this.isClickable = it }
}

fun Circle.setCenter(value: FREObject?) {
    this.center = LatLng(value)
}

fun Circle.setRadius(value: FREObject?) {
    Double(value)?.let { this.radius = it }
}

fun Circle.setStrokeWidth(value: FREObject?) {
    Float(value)?.let { this.strokeWidth = it }
}

fun Circle.setStrokeColor(value: FREObject?) {
    value?.toColor()?.let { this.strokeColor = it }
}

fun Circle.setStrokePattern(value: FREObject?) {
    val strokePatternType = Int(value["type"])
    val strokePatternDashLength = Int(value["dashLength"]) ?: return
    val strokePatternGapLength = Int(value["gapLength"]) ?: return
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

fun Circle.setFillColor(value: FREObject?) {
    value?.toColor()?.let { this.fillColor = it }
}

fun Circle.setVisible(value: FREObject?) {
    Boolean(value)?.let { this.isVisible = it }
}

fun Circle.setZIndex(value: FREObject?) {
    Float(value)?.let { this.zIndex = it }
}