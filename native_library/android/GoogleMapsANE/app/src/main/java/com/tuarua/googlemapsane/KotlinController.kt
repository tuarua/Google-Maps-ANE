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
import android.os.Build.VERSION.SDK_INT
import android.os.Build.VERSION_CODES.M
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PackageManager.GET_PERMISSIONS
import android.location.Address
import android.location.Geocoder
import android.support.v4.content.ContextCompat
import android.view.ViewGroup
import com.adobe.fre.FREContext
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.*
import com.google.gson.Gson

import com.tuarua.frekotlin.*
import com.tuarua.frekotlin.display.toFREObject
import com.tuarua.frekotlin.geom.Rect
import com.tuarua.googlemapsane.data.AddressLookup
import com.tuarua.googlemapsane.data.Settings
import com.tuarua.googlemapsane.events.PermissionEvent
import com.tuarua.googlemapsane.extensions.*
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.io.IOException

@Suppress("unused", "UNUSED_PARAMETER", "UNCHECKED_CAST", "PrivatePropertyName")
class KotlinController : FreKotlinMainController {
    private var scaleFactor: Double = 1.0
    private lateinit var airView: ViewGroup
    private val TRACE = "TRACE"
    private var isAdded: Boolean = false
    private var settings: Settings = Settings()
    private var asListeners: MutableList<String> = mutableListOf()
    private var listenersAddedToMapC: Boolean = false

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
        argv.takeIf { argv.size > 0 } ?: return FreArgException("reverseGeocodeLocation")
        val coordinate = LatLng(argv[0])
        val appActivity = ctx.activity
        if (appActivity != null) {
            val geocoder = Geocoder(appActivity)
            val addresses: List<Address>?
            val address: Address?
            try {
                addresses = geocoder.getFromLocation(coordinate.latitude, coordinate.longitude, 1)
                if (null != addresses && !addresses.isEmpty()) {
                    address = addresses[0]
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
                                    coordinate.latitude,
                                    coordinate.longitude,
                                    formattedAddress,
                                    name,
                                    address.thoroughfare,
                                    address.locality,
                                    address.postalCode,
                                    address.countryName

                            ))
                    )
                }
            } catch (e: IOException) {
                dispatchEvent(Constants.ON_ADDRESS_LOOKUP_ERROR, e.localizedMessage)
            }
        }
        return null
    }

    fun forwardGeocodeLocation(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("forwardGeocodeLocation")
        val addressSearch = String(argv[0]) ?: return FreConversionException("addressSearch")
        val appActivity = ctx.activity
        if (appActivity != null) {
            val geocoder = Geocoder(appActivity)
            val addresses: List<Address>?
            val address: Address?
            try {
                addresses = geocoder.getFromLocationName(addressSearch, 1)
                if (null != addresses && !addresses.isEmpty()) {
                    address = addresses[0]
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
            } catch (e: IOException) {
                dispatchEvent(Constants.ON_ADDRESS_LOOKUP_ERROR, e.localizedMessage)
            }
        }
        return null
    }

    fun requestPermissions(ctx: FREContext, argv: FREArgv): FREObject? {
        try {
            val permissionsToCheck = getPermissionsToCheck()
            if (permissionsToCheck.size == 0 || SDK_INT < M) {
                dispatchEvent(PermissionEvent.ON_PERMISSION_STATUS, gson.toJson(PermissionEvent(ACCESS_FINE_LOCATION, PermissionEvent.PERMISSION_ALWAYS)))
                permissionsGranted = true
                return null
            }
            val permissionIntent = Intent(ctx.activity.applicationContext, PermissionActivity::class.java)
            permissionIntent.putExtra("ptc", permissionsToCheck.toTypedArray())
            ctx.activity.startActivity(permissionIntent)
        } catch (e: Exception) {
            return FreException(e).getError(Thread.currentThread().stackTrace)
        }
        return null
    }

    fun capture(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 3 } ?: return FreArgException("initMap")
        val xFre = Int(argv[0]) ?: return FreConversionException("x")
        val yFre = Int(argv[1]) ?: return FreConversionException("y")
        val wFre = Int(argv[2]) ?: return FreConversionException("w")
        val hFre = Int(argv[3]) ?: return FreConversionException("h")
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
        argv.takeIf { argv.size > 4 } ?: return FreArgException("initMap")
        val zoomLevel = Float(argv[2]) ?: 12.0F
        scaleFactor = Double(argv[4]) ?: 1.0
        val centerAt = LatLng(argv[1])
        val viewPort = Rect(argv[0]) ?: return FreConversionException("viewPort")
        val settingsFre = argv[3]
        settings.compassButton = Boolean(settingsFre["compassButton"]) == true
        settings.indoorPicker = Boolean(settingsFre["indoorPicker"]) == true
        settings.myLocationButtonEnabled = Boolean(settingsFre["myLocationButtonEnabled"]) == true
        settings.myLocationEnabled = Boolean(settingsFre["myLocationEnabled"]) == true
        settings.rotateGestures = Boolean(settingsFre["rotateGestures"]) == true
        settings.scrollGestures = Boolean(settingsFre["scrollGestures"]) == true
        settings.tiltGestures = Boolean(settingsFre["tiltGestures"]) == true
        settings.zoomGestures = Boolean(settingsFre["zoomGestures"]) == true
        settings.mapToolbarEnabled = Boolean(settingsFre["mapToolbarEnabled"]) == true
        settings.buildingsEnabled = Boolean(settingsFre["buildingsEnabled"]) == true

        mapController = MapController(ctx, airView, centerAt, zoomLevel, scaleViewPort(viewPort), settings)
        return null
    }

    fun addEventListener(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("addEventListener")
        val type = String(argv[0]) ?: return FreConversionException("type")
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
        argv.takeIf { argv.size > 0 } ?: return FreArgException("removeEventListener")
        val type = String(argv[0]) ?: return FreConversionException("type")
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
        argv.takeIf { argv.size > 0 } ?: return FreArgException("addCircle")
        val addedCircle: Circle? = mapController?.addCircle(CircleOptions(argv[0]))
        return addedCircle?.id?.toFREObject()
    }

    fun setCircleProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 2 } ?: return FreArgException("setCircleProp")
        val id = String(argv[0]) ?: return FreConversionException("id")
        val name = String(argv[1]) ?: return FreConversionException("name")
        mapController?.setCircleProp(id, name, argv[2])
        return null
    }

    fun removeCircle(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("removeCircle")
        val id = String(argv[0]) ?: return FreConversionException("id")
        mapController?.removeCircle(id)
        return null
    }

    fun addMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("addMarker")
        val addedMarker: Marker? = mapController?.addMarker(MarkerOptions(argv[0]))
        return addedMarker?.id?.toFREObject()
    }

    fun setMarkerProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 2 } ?: return FreArgException("setMarkerProp")
        val id = String(argv[0]) ?: return FreConversionException("id")
        val name = String(argv[1]) ?: return FreConversionException("name")
        mapController?.setMarkerProp(id, name, argv[2])
        return null
    }

    fun removeMarker(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("removeMarker")
        val id = String(argv[0]) ?: return FreConversionException("id")
        mapController?.removeMarker(id)
        return null
    }

    fun addGroundOverlay(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("addGroundOverlay")
        val addedOverlay: GroundOverlay? = mapController?.addGroundOverlay(GroundOverlayOptions(argv[0]))
        return addedOverlay?.id?.toFREObject()
    }

    fun setGroundOverlayProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException("setGroundOverlayProp")
        val id = String(argv[0]) ?: return FreConversionException("id")
        val name = String(argv[1]) ?: return FreConversionException("name")
        mapController?.setGroundOverlayProp(id, name, argv[2])
        return null
    }

    fun removeGroundOverlay(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("removeGroundOverlay")
        val id = String(argv[0]) ?: return FreConversionException("id")
        mapController?.removeGroundOverlay(id)
        return null
    }

    fun addPolyline(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("addPolyline")
        val addedPolyline: Polyline? = mapController?.addPolyline(PolylineOptions(argv[0]))
        return addedPolyline?.id?.toFREObject()
    }

    fun setPolylineProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException("setPolylineProp")
        val id = String(argv[0]) ?: return FreConversionException("id")
        val name = String(argv[1]) ?: return FreConversionException("name")
        mapController?.setPolylineProp(id, name, argv[2])
        return null
    }

    fun removePolyline(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("removePolyline")
        val id = String(argv[0]) ?: return FreConversionException("id")
        mapController?.removePolyline(id) ?: return FreConversionException("name")
        return null
    }

    fun addPolygon(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("addPolygon")
        val addedPolygon: Polygon? = mapController?.addPolygon(PolygonOptions(argv[0]))
        return addedPolygon?.id?.toFREObject()
    }

    fun setPolygonProp(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException("setPolygonProp")
        val id = String(argv[0]) ?: return FreConversionException("id")
        val name = String(argv[1]) ?: return FreConversionException("name")
        mapController?.setPolygonProp(id, name, argv[2])
        return null
    }

    fun removePolygon(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("removePolygon")
        val id = String(argv[0]) ?: return FreConversionException("id")
        mapController?.removePolygon(id)
        return null
    }

    fun showInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("showInfoWindow")
        val id = String(argv[0]) ?: return FreConversionException("id")
        mapController?.showInfoWindow(id)
        return null
    }

    fun hideInfoWindow(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("hideInfoWindow")
        val id = String(argv[0]) ?: return FreConversionException("id")
        mapController?.hideInfoWindow(id)
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
        argv.takeIf { argv.size > 0 } ?: return FreArgException("initMap")
        val viewPortFre = Rect(argv[0])
        mapController?.viewPort = scaleViewPort(viewPortFre)
        return null
    }

    fun setVisible(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("setVisible")
        val visible = Boolean(argv[0]) == true
        if (!isAdded) {
            mapController?.add()
            isAdded = true
        }
        mapController?.visible = visible
        return null
    }

    fun moveCamera(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 4 } ?: return FreArgException("moveCamera")
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
        argv.takeIf { argv.size > 2 } ?: return FreArgException("setBounds")
        val southWest = LatLng(argv[0])
        val northEast = LatLng(argv[1])
        val animates = Boolean(argv[2]) == true
        mapController?.setBounds(LatLngBounds(southWest, northEast), animates)
        return null
    }

    fun zoomIn(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("zoomIn")
        val animates = Boolean(argv[0]) == true
        mapController?.zoomIn(animates)
        return null
    }

    fun zoomOut(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("zoomOut")
        val animates = Boolean(argv[0]) == true
        mapController?.zoomOut(animates)
        return null
    }

    fun zoomTo(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return FreArgException("zoomTo")
        val zoomLevel = Float(argv[0]) ?: return FreConversionException("zoomLevel")
        val animates = Boolean(argv[1]) == true
        mapController?.zoomTo(zoomLevel, animates)
        return null
    }

    fun scrollBy(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 2 } ?: return FreArgException("scrollBy")
        val x = Float(argv[0]) ?: return FreConversionException("x")
        val y = Float(argv[1]) ?: return FreConversionException("y")
        val animates = Boolean(argv[2]) == true
        mapController?.scrollBy(x, y, animates)
        return null
    }

    fun setAnimationDuration(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("setAnimationDuration")
        val duration = Int(argv[0]) ?: return FreConversionException("duration")
        mapController?.animationDuration = duration
        return null
    }

    fun setStyle(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("setStyle")
        val json = String(argv[0]) ?: return FreConversionException("json")
        mapController?.style = json

        return null
    }

    fun setMapType(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return FreArgException("setMapType")
        val type = Int(argv[0]) ?: return FreConversionException("type")
        mapController?.mapType = type
        return null
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
        }

}