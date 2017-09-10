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
import android.view.ViewGroup
import com.adobe.fre.FREContext
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.*

import com.tuarua.frekotlin.*
import com.tuarua.frekotlin.geom.Rect
import com.tuarua.googlemapsane.data.Settings
import java.util.ArrayList

@Suppress("unused", "UNUSED_PARAMETER", "UNCHECKED_CAST")
class KotlinController : FreKotlinMainController {
    private var scaleFactor: Double = 1.0
    private lateinit var airView: ViewGroup
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
        airView = context?.activity?.findViewById(android.R.id.content) as ViewGroup
        airView = airView.getChildAt(0) as ViewGroup
        return FreObjectKotlin(true).rawValue.guard { return null }
    }

    fun initMap(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 4 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        try {
            val zoomLevel = Float(argv[2]) ?: 12.0F
            scaleFactor = Double(argv[4]) ?: 1.0
            val centerAt = LatLng(argv[1])
            val viewPort = Rect(argv[0])
            val settingsFre = FreObjectKotlin(argv[3]) // settings: Settings
            settings.compassButton = Boolean(settingsFre.getProperty("compassButton")) == true
            settings.indoorPicker = Boolean(settingsFre.getProperty("indoorPicker")) == true
            settings.myLocationButton = Boolean(settingsFre.getProperty("myLocationButton")) == true
            settings.rotateGestures = Boolean(settingsFre.getProperty("rotateGestures")) == true
            settings.scrollGestures = Boolean(settingsFre.getProperty("scrollGestures")) == true
            settings.tiltGestures = Boolean(settingsFre.getProperty("tiltGestures")) == true
            settings.zoomGestures = Boolean(settingsFre.getProperty("zoomGestures")) == true
            mapController = MapController(ctx, airView, centerAt, zoomLevel, scaleViewPort(viewPort), settings)
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace) //return the error as an actionscript error
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun addEventListener(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val type = String(argv[0]) ?: return null
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
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val type = String(argv[0]) ?: return null
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
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        try {
            mapController?.addCircle(CircleOptions(argv[0]))
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun addMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        try {
            val addedMarker: Marker? = mapController?.addMarker(MarkerOptions(argv[0]))
            return FreObjectKotlin(addedMarker?.id).rawValue.guard { return null }
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
    }

    fun updateMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)

        try {
            val uuid = String(argv[0]) // id:String
            if (uuid != null) {
                mapController?.updateMarker(uuid, MarkerOptions(argv[1]))
            }
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }

        return null
    }

    fun removeMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        try {
            val uuid = String(argv[0])
            if (uuid != null) {
                mapController?.removeMarker(uuid)
            }
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun showInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        try {
            val uuid = String(argv[0])
            if (uuid != null) {
                mapController?.showInfoWindow(uuid)
            }
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun hideInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        try {
            val uuid = String(argv[0])
            if (uuid != null) {
                mapController?.hideInfoWindow(uuid)
            }
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun clear(ctx: FREContext, argv: FREArgv): FREObject? {
        mapController?.clear()
        return null
    }

    private fun scaleViewPort(rect: Rect?): Rect {
        if (rect == null) {
            return Rect(0, 0, 0, 0)
        }
        return Rect(
                (rect.x * scaleFactor).toInt(),
                (rect.y * scaleFactor).toInt(),
                (rect.width * scaleFactor).toInt(),
                (rect.height * scaleFactor).toInt())
    }

    fun setViewPort(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val viewPortFre = Rect(argv[0])

        trace("setViewPort pre-resize", "${viewPortFre?.x} ${viewPortFre?.y} ${viewPortFre?.width} ${viewPortFre?.height}")

        mapController?.viewPort = scaleViewPort(viewPortFre)
        return null
    }

    fun setVisible(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val visible = Boolean(argv[0]) == true
        if (!isAdded) {
            mapController?.add()
            isAdded = true
        }
        mapController?.visible = visible
        return null
    }

    fun moveCamera(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 4 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val cameraPositionBuilder: CameraPosition.Builder = CameraPosition.builder()
        try {
            val target = LatLng(argv[0])
            val zoom = Float(argv[1])
            val tilt = Float(argv[2])
            val bearing = Float(argv[3])
            val animates = Boolean(argv[4]) == true
            cameraPositionBuilder.target(target)
            if (zoom != null) cameraPositionBuilder.zoom(zoom)
            if (tilt != null) cameraPositionBuilder.tilt(tilt)
            if (bearing != null) cameraPositionBuilder.bearing(bearing)
            mapController?.moveCamera(cameraPositionBuilder.build(), animates)
        } catch (e: FreException) {
            return e.getError(Thread.currentThread().stackTrace)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun setBounds(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 2 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val southWest = LatLng(argv[0])
        val northEast = LatLng(argv[1])
        val animates = Boolean(argv[2]) == true
        mapController?.setBounds(LatLngBounds(southWest, northEast), animates)
        return null
    }

    fun zoomIn(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val animates = Boolean(argv[0]) == true
        mapController?.zoomIn(animates)
        return null
    }

    fun zoomOut(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val animates = Boolean(argv[0]) == true
        mapController?.zoomOut(animates)
        return null
    }

    fun zoomTo(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val zoomLevel = Float(argv[0])
        val animates = Boolean(argv[1]) == true
        if (zoomLevel != null) {
            mapController?.zoomTo(zoomLevel, animates)
        }
        return null
    }

    fun setAnimationDuration(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val duration = Int(argv[0])
        if (duration != null) {
            mapController?.animationDuration = duration
        }
        return null
    }

    fun setStyle(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        try {
            val json = String(argv[0])
            mapController?.style = json
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun setMapType(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val type = Int(argv[0])
        if (type is Int) mapController?.mapType = type
        return null
    }

    fun requestLocation(ctx: FREContext, argv: FREArgv): FREObject? {
        try {
            val permissionIntent = Intent(ctx.activity.applicationContext, PermissionActivity::class.java)
            ctx.activity.startActivity(permissionIntent)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
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

    override val TAG: String
        get() = this::class.java.canonicalName
    private var _context: FREContext? = null
    override var context: FREContext?
        get() = _context
        set(value) {
            _context = value
        }

}