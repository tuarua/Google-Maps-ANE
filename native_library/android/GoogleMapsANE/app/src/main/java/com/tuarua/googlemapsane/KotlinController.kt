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

import android.Manifest.permission.ACCESS_COARSE_LOCATION
import android.Manifest.permission.ACCESS_FINE_LOCATION
import android.annotation.SuppressLint
import android.os.Build.VERSION.SDK_INT
import android.os.Build.VERSION_CODES.M
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PackageManager.GET_PERMISSIONS
import android.content.res.Configuration
import android.graphics.RectF
import android.location.Address
import android.location.Geocoder
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.adobe.air.AndroidActivityWrapper
import com.adobe.air.FreKotlinActivityResultCallback
import com.adobe.air.FreKotlinStateChangeCallback
import com.adobe.fre.FREContext
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.*
import com.google.gson.Gson

import com.tuarua.frekotlin.*
import com.tuarua.frekotlin.display.toFREObject
import com.tuarua.frekotlin.geom.Point
import com.tuarua.frekotlin.geom.RectF
import com.tuarua.frekotlin.geom.toFREObject
import com.tuarua.googlemapsane.data.AddressLookup
import com.tuarua.googlemapsane.data.Settings
import com.tuarua.googlemapsane.events.PermissionEvent
import com.tuarua.googlemapsane.extensions.*
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.io.IOException

@Suppress("unused", "UNUSED_PARAMETER", "UNCHECKED_CAST", "PrivatePropertyName")
class KotlinController : FreKotlinMainController, FreKotlinStateChangeCallback, FreKotlinActivityResultCallback {
    private var scaleFactor = 1.0f
    private lateinit var airView: ViewGroup
    private val TRACE = "TRACE"
    private var isAdded = false
    private var settings = Settings()
    private var asListeners: MutableList<String> = mutableListOf()
    private var listenersAddedToMapC = false

    private var mapController: MapController? = null
    private var packageManager: PackageManager? = null
    private var packageInfo: PackageInfo? = null
    private val gson = Gson()
    private var permissionsGranted = false

    private val permissionsNeeded: Array<String> = arrayOf(
            ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION,
            "com.google.android.providers.gsf.permission.READ_GSERVICES")

    fun isSupported(ctx: FREContext, argv: FREArgv): FREObject? {
        return true.toFREObject()
    }

    fun showUserLocation(ctx: FREContext, argv: FREArgv): FREObject? {
        if (permissionsGranted) {
            mapController?.showUserLocation()
        }
        return null
    }

    fun reverseGeocodeLocation(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val coordinate = LatLng(argv[0])
        val appActivity = ctx.activity
        if (appActivity != null) {
            val geocoder = Geocoder(appActivity)
            val addresses: List<Address>?
            try {
                addresses = geocoder.getFromLocation(coordinate.latitude, coordinate.longitude, 1)
                sendGeocodeEvent(addresses)
            } catch (e: IOException) {
                dispatchEvent(Constants.ON_ADDRESS_LOOKUP_ERROR, e.localizedMessage ?: "")
            }
        }
        return null
    }

    fun forwardGeocodeLocation(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val addressSearch = String(argv[0]) ?: return null
        val appActivity = ctx.activity
        if (appActivity != null) {
            val geocoder = Geocoder(appActivity)
            val addresses: List<Address>?
            try {
                addresses = geocoder.getFromLocationName(addressSearch, 1)
                sendGeocodeEvent(addresses)
            } catch (e: IOException) {
                dispatchEvent(Constants.ON_ADDRESS_LOOKUP_ERROR, e.localizedMessage ?: "")
            }
        }
        return null
    }

    private fun sendGeocodeEvent(addresses: List<Address>?) {
        if (null == addresses || addresses.isEmpty()) return
        val address = addresses[0]
        val name: String? = if (address.subThoroughfare != null) {
            """${address.subThoroughfare} ${address.thoroughfare}"""
        } else {
            address.thoroughfare
        }

        var formattedAddress = ""
        if (address.maxAddressLineIndex > 0) {
            for (i in 0 until address.maxAddressLineIndex) {
                formattedAddress += if (i == 0) address.getAddressLine(i) else ", " + address.getAddressLine(i)
            }
        } else {
            formattedAddress = name + "\n"
        }

        formattedAddress = """$formattedAddress${address.locality}, ${address.postalCode}, ${address.countryName}"""

        dispatchEvent(Constants.ON_ADDRESS_LOOKUP, gson.toJson(
                AddressLookup(
                        address.latitude,
                        address.longitude,
                        formattedAddress,
                        name,
                        address.thoroughfare,
                        address.locality,
                        address.postalCode,
                        address.countryName

                ))
        )
    }

    fun requestPermissions(ctx: FREContext, argv: FREArgv): FREObject? {
        try {
            val permissionsToCheck = getPermissionsToCheck()
            if (permissionsToCheck.size == 0 || SDK_INT < M) {
                dispatchEvent(PermissionEvent.ON_PERMISSION_STATUS,
                        gson.toJson(PermissionEvent(ACCESS_FINE_LOCATION,
                                PermissionEvent.PERMISSION_ALWAYS)))
                permissionsGranted = true
                return null
            }
            val permissionIntent = Intent(ctx.activity.applicationContext, PermissionActivity::class.java)
            permissionIntent.putExtra("ptc", permissionsToCheck.toTypedArray())
            ctx.activity.startActivity(permissionIntent)
        } catch (e: Exception) {
            return FreException(e).getError()
        }
        return null
    }

    fun capture(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 3 } ?: return FreArgException()
        val xFre = Int(argv[0]) ?: return null
        val yFre = Int(argv[1]) ?: return null
        val wFre = Int(argv[2]) ?: return null
        val hFre = Int(argv[3]) ?: return null
        val x: Int = (xFre * scaleFactor).toInt()
        val y: Int = (yFre * scaleFactor).toInt()
        val w: Int = (wFre * scaleFactor).toInt()
        val h: Int = (hFre * scaleFactor).toInt()
        mapController?.capture(x, y, w, h)
        return null
    }

    fun getCapture(ctx: FREContext, argv: FREArgv): FREObject? {
        return mapController?.getCapture()?.toFREObject()
    }

    fun init(ctx: FREContext, argv: FREArgv): FREObject? {
        val appActivity = ctx.activity
        if (appActivity != null) {
            airView = appActivity.findViewById(android.R.id.content) as ViewGroup
            airView = airView.getChildAt(0) as ViewGroup
            packageManager = appActivity.packageManager
            val pm = packageManager ?: return false.toFREObject()
            packageInfo = pm.getPackageInfo(appActivity.packageName, GET_PERMISSIONS)
            EventBus.getDefault().register(this)
            return hasRequiredPermissions().toFREObject()
        }
        return false.toFREObject()
    }

    private fun hasRequiredPermissions(): Boolean {
        val pi = packageInfo ?: return false
        permissionsNeeded.forEach { p ->
            if (p !in pi.requestedPermissions) {
                trace("Please add $p to uses-permission list in your AIR manifest")
                return false
            }
        }
        return true
    }

    @Throws(FreException::class)
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onMessageEvent(event: PermissionEvent) {
        dispatchEvent(PermissionEvent.ON_PERMISSION_STATUS, gson.toJson(event))
        when {
            event.status == PermissionEvent.PERMISSION_ALWAYS -> {
                permissionsGranted = true
            }
        }
    }

    private fun getPermissionsToCheck(): ArrayList<String> {
        val appCtx = context?.activity?.applicationContext ?: return ArrayList()
        val pi = packageInfo ?: return ArrayList()
        val permissionsToCheck = ArrayList<String>()
        pi.requestedPermissions.filterTo(permissionsToCheck) {
            it in permissionsNeeded &&
                    ContextCompat.checkSelfPermission(appCtx, it) != PackageManager.PERMISSION_GRANTED
        }
        return permissionsToCheck
    }

    fun initMap(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 4 } ?: return FreArgException()
        val centerAt = LatLng(argv[1])
        val viewPort = RectF(argv[0])
        val zoomLevel = Float(argv[2]) ?: 12.0f
        val settings = Settings(argv[3])
        scaleFactor = Float(argv[4]) ?: 1.0f
        mapController = MapController(ctx, airView, centerAt, zoomLevel, scaleViewPort(viewPort), settings)
        return null
    }

    fun addEventListener(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
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
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
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
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val addedCircle: Circle? = mapController?.addCircle(CircleOptions(argv[0]))
        return addedCircle?.id?.toFREObject()
    }

    fun setCircleProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 2 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        val name = String(argv[1]) ?: return null
        mapController?.setCircleProp(id, name, argv[2])
        return null
    }

    fun removeCircle(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        mapController?.removeCircle(id)
        return null
    }

    fun addMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val addedMarker: Marker? = mapController?.addMarker(MarkerOptions(argv[0]))
        return addedMarker?.id?.toFREObject()
    }

    fun setMarkerProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 2 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        val name = String(argv[1]) ?: return null
        mapController?.setMarkerProp(id, name, argv[2])
        return null
    }

    fun removeMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        mapController?.removeMarker(id)
        return null
    }

    fun addGroundOverlay(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val addedOverlay: GroundOverlay? = mapController?.addGroundOverlay(GroundOverlayOptions(argv[0]))
        return addedOverlay?.id?.toFREObject()
    }

    fun setGroundOverlayProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        val name = String(argv[1]) ?: return null
        mapController?.setGroundOverlayProp(id, name, argv[2])
        return null
    }

    fun removeGroundOverlay(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        mapController?.removeGroundOverlay(id)
        return null
    }

    fun addPolyline(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val addedPolyline: Polyline? = mapController?.addPolyline(PolylineOptions(argv[0]))
        return addedPolyline?.id?.toFREObject()
    }

    fun setPolylineProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        val name = String(argv[1]) ?: return null
        mapController?.setPolylineProp(id, name, argv[2])
        return null
    }

    fun removePolyline(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        mapController?.removePolyline(id) ?: return null
        return null
    }

    fun addPolygon(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val addedPolygon: Polygon? = mapController?.addPolygon(PolygonOptions(argv[0]))
        return addedPolygon?.id?.toFREObject()
    }

    fun setPolygonProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        val name = String(argv[1]) ?: return null
        mapController?.setPolygonProp(id, name, argv[2])
        return null
    }

    fun removePolygon(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        mapController?.removePolygon(id)
        return null
    }

    fun showInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        mapController?.showInfoWindow(id)
        return null
    }

    fun hideInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val id = String(argv[0]) ?: return null
        mapController?.hideInfoWindow(id)
        return null
    }

    fun clear(ctx: FREContext, argv: FREArgv): FREObject? {
        mapController?.mapView?.clear()
        return null
    }

    private fun scaleViewPort(rect: RectF): RectF {
        return RectF(
                (rect.left * scaleFactor),
                (rect.top * scaleFactor),
                (rect.right * scaleFactor),
                (rect.bottom * scaleFactor))
    }

    fun setViewPort(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val viewPortFre = RectF(argv[0])
        mapController?.viewPort = scaleViewPort(viewPortFre)
        return null
    }

    fun setVisible(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val visible = Boolean(argv[0]) == true
        if (!isAdded) {
            mapController?.add()
            isAdded = true
        }
        mapController?.visible = visible
        return null
    }

    fun moveCamera(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 4 } ?: return FreArgException()
        var centerAt: LatLng? = null
        if (argv[0].type != FreObjectTypeKotlin.NULL) {
            centerAt = LatLng(argv[0])
        }
        val zoom = Float(argv[1])
        val tilt = Float(argv[2])
        val bearing = Float(argv[3])
        val animates = Boolean(argv[4]) == true
        mapController?.moveCamera(centerAt, zoom, tilt, bearing, animates)
        return null
    }

    fun setBounds(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException()
        val bounds = LatLngBounds(argv[0])
        val animates = Boolean(argv[1]) == true
        mapController?.setBounds(bounds, animates)
        return null
    }

    fun zoomIn(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val animates = Boolean(argv[0]) == true
        mapController?.zoomIn(animates)
        return null
    }

    fun zoomOut(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val animates = Boolean(argv[0]) == true
        mapController?.zoomOut(animates)
        return null
    }

    fun zoomTo(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException()
        val zoomLevel = Float(argv[0]) ?: return null
        val animates = Boolean(argv[1]) == true
        mapController?.zoomTo(zoomLevel, animates)
        return null
    }

    fun scrollBy(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 2 } ?: return FreArgException()
        val x = Float(argv[0]) ?: return null
        val y = Float(argv[1]) ?: return null
        val animates = Boolean(argv[2]) == true
        mapController?.scrollBy(x, y, animates)
        return null
    }

    fun setAnimationDuration(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val duration = Int(argv[0]) ?: return null
        mapController?.animationDuration = duration
        return null
    }

    fun setStyle(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val json = String(argv[0]) ?: return null
        mapController?.style = json
        return null
    }

    fun setMapType(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        val type = Int(argv[0]) ?: return null
        mapController?.mapView?.mapType = type
        return null
    }

    fun setBuildingsEnabled(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        mapController?.mapView?.isBuildingsEnabled = Boolean(argv[0]) == true
        return null
    }

    fun setTrafficEnabled(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        mapController?.mapView?.isTrafficEnabled = Boolean(argv[0]) == true
        return null
    }

    fun setMinZoom(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        Float(argv[0])?.let { mapController?.mapView?.setMinZoomPreference(it) }
        return null
    }

    fun setMaxZoom(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        Float(argv[0])?.let { mapController?.mapView?.setMaxZoomPreference(it) }
        return null
    }

    fun setIndoorEnabled(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        mapController?.mapView?.isIndoorEnabled = Boolean(argv[0]) == true
        return null
    }

    @SuppressLint("MissingPermission")
    fun setMyLocationEnabled(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        mapController?.mapView?.isMyLocationEnabled = Boolean(argv[0]) == true
        return null
    }

    fun projection_pointForCoordinate(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        return mapController?.mapView?.projection?.toScreenLocation(LatLng(argv[0]))?.toFREObject()
    }

    fun projection_coordinateForPoint(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException()
        return mapController?.mapView?.projection?.fromScreenLocation(Point(argv[0]))?.toFREObject()
    }

    fun projection_containsCoordinate(ctx: FREContext, argv: FREArgv): FREObject? {
        warning("containsCoordinate is iOS only")
        return null
    }

    fun projection_visibleRegion(ctx: FREContext, argv: FREArgv): FREObject? {
        return mapController?.mapView?.projection?.visibleRegion?.toFREObject()
    }

    fun projection_pointsForMeters(ctx: FREContext, argv: FREArgv): FREObject? {
        warning("pointsForMeters is iOS only")
        return null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
    }

    override fun onConfigurationChanged(configuration: Configuration?) {
    }

    override fun onActivityStateChanged(activityState: AndroidActivityWrapper.ActivityState?) {
    }

    override fun dispose() {
        super.dispose()
        mapController?.dispose()
        mapController = null
    }

    override val TAG: String
        get() = this::class.java.simpleName
    private var _context: FREContext? = null
    override var context: FREContext?
        get() = _context
        set(value) {
            _context = value
            FreKotlinLogger.context = _context
        }

}
