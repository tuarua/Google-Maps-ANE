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
package com.tuarua.googlemapsane

import android.content.Intent
import android.graphics.Rect
import android.util.Log
import com.adobe.fre.FREContext
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.*

import com.tuarua.frekotlin.*
import com.tuarua.frekotlin.geom.FreRectangleKotlin
import java.util.ArrayList

typealias FREArgv = ArrayList<FREObject>
@Suppress("unused", "UNUSED_PARAMETER", "UNCHECKED_CAST")
class KotlinController : FreKotlinController {
    private var scaleFactor: Double = 1.0
    private var context: FREContext? = null
    private val TRACE = "TRACE"
    private var isAdded: Boolean = false
    private var settings: Settings = Settings()
    private var asListeners: ArrayList<String> = ArrayList()
    private var listenersAddedToMapC: Boolean = false

    private var mapController: MapController? = null

    fun isSupported(ctx: FREContext, argv: FREArgv): FREObject? {
        return FreObjectKotlin(true).rawValue.guard { return null }
    }

    fun init(ctx: FREContext, argv: FREArgv): FREObject? {
        return FreObjectKotlin(true).rawValue.guard { return null }
    }

    fun initMap(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 5 } ?: return null
        // viewPort:Rectangle
        // centerAt:Coordinate
        // zoomLevel:Number
        // settings: Settings
        // scaleFactor:Number
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "viewPort not passed", 0, "", "", "").rawValue
        }
        val inFRE1 = argv[1].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        val inFRE2 = argv[2].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "zoomLevel not passed", 0, "", "", "").rawValue
        }
        val inFRE4 = argv[4].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "scaleFactor not passed", 0, "", "", "").rawValue
        }

        try {
            val zl = FreObjectKotlin(inFRE2).value
            val sf = FreObjectKotlin(inFRE4).value
            val zoomLevel = (zl as? Int)?.toFloat() ?: (zl as Double).toFloat()
            scaleFactor = (sf as? Int)?.toDouble() ?: sf as Double
            val centerAt = FreCoordinateKotlin(inFRE1).value

            val viewPort = FreRectangleKotlin(inFRE0).value

            val settingsFre = FreObjectKotlin(argv[3])
            settings.compassButton = settingsFre.getProperty("compassButton")?.value as Boolean
            settings.indoorPicker = settingsFre.getProperty("indoorPicker")?.value as Boolean
            settings.myLocationButton = settingsFre.getProperty("myLocationButton")?.value as Boolean
            settings.rotateGestures = settingsFre.getProperty("rotateGestures")?.value as Boolean
            settings.scrollGestures = settingsFre.getProperty("scrollGestures")?.value as Boolean
            settings.tiltGestures = settingsFre.getProperty("tiltGestures")?.value as Boolean
            settings.zoomGestures = settingsFre.getProperty("zoomGestures")?.value as Boolean

            trace("zoomLevel", zoomLevel)
            trace("scaleFactor", scaleFactor)
            trace("viewPort", viewPort.left, viewPort.top, viewPort.width(), viewPort.height())
            trace("coordinate", centerAt.latitude, centerAt.longitude)

            mapController = MapController(ctx, centerAt, zoomLevel, scaleViewPort(viewPort), settings)
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace) //return the error as an actionscript error
        } catch (e: Exception) {
            Log.e("initEror", e.message)
            e.printStackTrace()
        }


        return null
    }

    fun addEventListener(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "type not passed", 0, "", "", "").rawValue
        }
        val type: String = FreObjectKotlin(inFRE0).value as? String ?: return null

        if (mapController == null) {
            asListeners.add(type)
        } else {
            if (!listenersAddedToMapC) {
                for (asListener in asListeners) {
                    asListeners.add(asListener)
                }
            }
            listenersAddedToMapC = true
        }

        mapController?.addEventListener(type)
        return null
    }

    fun removeEventListener(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "type not passed", 0, "", "", "").rawValue
        }
        val type: String = FreObjectKotlin(inFRE0).value as? String ?: return null

        if (mapController == null) {
            asListeners.remove(type)
        } else {
            if (!listenersAddedToMapC) {
                for (asListener in asListeners) {
                    asListeners.remove(asListener)
                }
            }
        }

        mapController?.removeEventListener(type)
        return null

    }

    fun addCircle(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "marker not passed", 0, "", "", "").rawValue
        }
        var circleOptions: CircleOptions = FreCircleOptionsKotlin(inFRE0).value
        trace("addCircle called")
        mapController?.addCircle(circleOptions)
        return null
    }

    fun addMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        // marker:Marker
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "marker not passed", 0, "", "", "").rawValue
        }
        val markerOptionsFre = FreMarkerOptionsKotlin(inFRE0)
        val markerOptions = markerOptionsFre.value ?: return null
        val addedMarker: Marker? = mapController?.addMarker(markerOptions)
        return FreObjectKotlin(addedMarker?.id).rawValue.guard { return null }

    }

    fun updateMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 2 } ?: return null
        // id:String
        // marker:Marker
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "marker uuid not passed", 0, "", "", "").rawValue
        }
        val inFRE1 = argv[1].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "marker not passed", 0, "", "", "").rawValue
        }
        val uuid: String = FreObjectKotlin(inFRE0).value as String
        val markerOptionsFre = FreMarkerOptionsKotlin(inFRE1)
        val markerOptions = markerOptionsFre.value ?: return null
        mapController?.updateMarker(uuid, markerOptions)
        return null
    }

    fun removeMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "marker uuid not passed", 0, "", "", "").rawValue
        }
        val uuid: String = FreObjectKotlin(inFRE0).value as String
        mapController?.removeMarker(uuid)
        return null
    }

    fun showInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        // uuid:String
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "uuid not passed", 0, "", "", "").rawValue
        }
        val uuid: String = FreObjectKotlin(inFRE0).value as String
        mapController?.showInfoWindow(uuid)
        return null
    }

    fun hideInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        // uuid:String
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "uuid not passed", 0, "", "", "").rawValue
        }
        val uuid: String = FreObjectKotlin(inFRE0).value as String
        mapController?.hideInfoWindow(uuid)
        return null
    }

    fun clear(ctx: FREContext, argv: FREArgv): FREObject? {
        mapController?.clear()

        return null
    }

    private fun scaleViewPort(rect: Rect): Rect {
        return Rect((rect.left * scaleFactor).toInt(), (rect.top * scaleFactor).toInt(),
                (rect.width() * scaleFactor).toInt(), ((rect.height() + rect.top) * scaleFactor).toInt())
    }

    fun setViewPort(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "viewPort not passed", 0, "", "", "").rawValue
        }
        val viewPortFre = FreRectangleKotlin(inFRE0).value
        mapController?.viewPort = scaleViewPort(viewPortFre)

        return null
    }

    fun setVisible(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "viewPort not passed", 0, "", "", "").rawValue
        }
        val visible = FreObjectKotlin(inFRE0).value as Boolean

        if (!isAdded) {
            mapController?.add()
            isAdded = true
        }
        mapController?.visible = visible

        return null
    }

    fun moveCamera(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 5 } ?: return null
        val inFRE0 = argv[0]
        val inFRE1 = argv[1]
        val inFRE2 = argv[2]
        val inFRE3 = argv[3]
        val inFRE4 = argv[4]

        val cameraPositionBuilder: CameraPosition.Builder = CameraPosition.builder()

        val targetFre = FreCoordinateKotlin(inFRE0)
        val zoomFre = FreObjectKotlin(inFRE1)
        val tiltFre = FreObjectKotlin(inFRE2)
        val bearingFre = FreObjectKotlin(inFRE3)
        val animates = FreObjectKotlin(inFRE4).value as Boolean

        try {
            if (targetFre.getType() != FreObjectTypeKotlin.NULL) {
                cameraPositionBuilder.target(targetFre.value)
            }
            if (zoomFre.getType() != FreObjectTypeKotlin.NULL) {
                val zoom: Float = (zoomFre.value as? Int)?.toFloat() ?: (zoomFre.value as Double).toFloat()
                Log.d(TAG, "zoom: " + zoom)
                cameraPositionBuilder.zoom(zoom)
            }
            if (tiltFre.getType() != FreObjectTypeKotlin.NULL) {
                val tilt: Float = (tiltFre.value as? Int)?.toFloat() ?: (tiltFre.value as Double).toFloat()
                Log.d(TAG, "tilt: " + tilt)
                cameraPositionBuilder.tilt(tilt)
            }
            if (bearingFre.getType() != FreObjectTypeKotlin.NULL) {
                val bearing: Float = (bearingFre.value as? Int)?.toFloat() ?: (bearingFre.value as Double).toFloat()
                Log.d(TAG, "bearing: " + bearing)
                cameraPositionBuilder.bearing(bearing)
            }
            mapController?.moveCamera(cameraPositionBuilder.build(), animates)
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            Log.e(TAG, e.message)
        }


        return null
    }

    fun setBounds(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 3 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        val inFRE1 = argv[1].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "animates not passed", 0, "", "", "").rawValue
        }
        val inFRE2 = argv[2].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        val southwest = FreCoordinateKotlin(inFRE0).value
        val northeast = FreCoordinateKotlin(inFRE1).value
        val animates = FreObjectKotlin(inFRE2).value as Boolean
        mapController?.setBounds(LatLngBounds(southwest, northeast), animates)
        return null
    }

    fun zoomIn(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        val animates = FreObjectKotlin(inFRE0).value as Boolean
        mapController?.zoomIn(animates)
        return null
    }

    fun zoomOut(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        val animates = FreObjectKotlin(inFRE0).value as Boolean
        mapController?.zoomOut(animates)
        return null
    }

    fun zoomTo(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 2 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        val inFRE1 = argv[1].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        val toFre = FreObjectKotlin(inFRE0).value
        val zoomLevel = (toFre as? Int)?.toFloat() ?: (toFre as Double).toFloat()

        val animates = FreObjectKotlin(inFRE1).value as Boolean
        mapController?.zoomTo(zoomLevel, animates)
        return null
    }

    fun setAnimationDuration(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "coordinate not passed", 0, "", "", "").rawValue
        }
        mapController?.animationDuration = FreObjectKotlin(inFRE0).value as Int
        return null
    }

    fun setStyle(ctx: FREContext, argv: FREArgv): FREObject? {
        trace("setStyle called")
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "style not passed", 0, "", "", "").rawValue
        }
        try {
            val json = FreObjectKotlin(inFRE0).value as String

            trace(json)

            mapController?.style = json
        } catch (e: Exception) {
            Log.e(TAG, e.message)
        }

        return null
    }

    fun setMapType(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size == 1 } ?: return null
        val inFRE0 = argv[0].guard {
            return FreObjectKotlin("com.tuarua.fre.ANEError", "map type not passed", 0, "", "", "").rawValue
        }
        val type: Int = FreObjectKotlin(inFRE0).value as Int
        mapController?.mapType = type
        return null
    }

    fun requestLocation(ctx: FREContext, argv: FREArgv): FREObject? {
        try {
            val permissionIntent = Intent(ctx.activity.applicationContext, PermissionActivity::class.java)
            ctx.activity.startActivity(permissionIntent)
        } catch (e: Exception) {
            Log.e(TAG, e.message)
            e.printStackTrace()
        }
        return null
    }


    override fun onStarted() {
        super.onStarted()
    }

    override fun onRestarted() {
        super.onRestarted()
    }

    override fun onResumed() {
        super.onResumed()
    }

    override fun onPaused() {
        super.onPaused()
    }

    override fun onStopped() {
        super.onStopped()
    }

    override fun onDestroyed() {
        super.onDestroyed()
    }

    override fun setFREContext(context: FREContext) {
        this.context = context
    }

    private fun trace(vararg value: Any?) {
        context?.trace(TAG, value)
    }

    private fun sendEvent(name: String, value: String) {
        context?.sendEvent(name, value)
    }

    companion object {
        private var TAG = KotlinController::class.java.simpleName
    }

}