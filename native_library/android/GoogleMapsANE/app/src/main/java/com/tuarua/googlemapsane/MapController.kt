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

import android.Manifest.permission.ACCESS_FINE_LOCATION
import android.app.FragmentTransaction
import android.content.pm.PackageManager
import android.graphics.Rect
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.adobe.fre.FREContext
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapFragment
import com.google.android.gms.maps.OnMapReadyCallback
import android.os.Bundle
import android.support.v4.content.ContextCompat.checkSelfPermission
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.maps.model.*
import org.json.JSONException
import org.json.JSONObject
import com.google.android.gms.common.api.GoogleApiClient
import com.google.android.gms.location.LocationServices.*
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.ThreadMode
import org.greenrobot.eventbus.Subscribe
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.CircleOptions
import com.tuarua.frekotlin.FreException
import com.tuarua.frekotlin.sendEvent
import com.tuarua.frekotlin.trace
import java.util.ArrayList


class MapController : OnMapReadyCallback, GoogleMap.OnMarkerClickListener, GoogleMap.OnMarkerDragListener,
        GoogleMap.OnMapClickListener, GoogleMap.OnMapLongClickListener, GoogleMap.OnInfoWindowClickListener,
        GoogleMap.OnInfoWindowCloseListener, GoogleMap.OnInfoWindowLongClickListener, GoogleApiClient
        .ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener, GoogleMap.OnCameraMoveListener,
        GoogleMap.OnCameraMoveStartedListener, GoogleMap.OnCameraIdleListener {

    private var googleApiClient: GoogleApiClient? = null
    private var context: FREContext
    private var _viewPort: Rect
    private var _visible: Boolean = false
    private var _style: String? = null
    private var _mapType = 0
    private var zoomLevel = 12.0F
    private var centerAt: LatLng
    private var mapView: GoogleMap? = null
    private var airView: ViewGroup? = null
    private var container: FrameLayout? = null
    private var settings: Settings
    private var asListeners: ArrayList<String> = ArrayList()
    private val markers = mutableMapOf<String, Marker>()
    var animationDuration: Int = 2000
    override fun onMapReady(googleMap: GoogleMap?) {
        mapView = googleMap
        val mv: GoogleMap = mapView ?: return

        mv.uiSettings.isMyLocationButtonEnabled = settings.myLocationButton
        mv.uiSettings.isCompassEnabled = settings.compassButton
        mv.uiSettings.isRotateGesturesEnabled = settings.rotateGestures
        mv.uiSettings.isIndoorLevelPickerEnabled = settings.indoorPicker
        mv.uiSettings.isScrollGesturesEnabled = settings.scrollGestures
        mv.uiSettings.isZoomGesturesEnabled = settings.zoomGestures
        mv.uiSettings.isTiltGesturesEnabled = settings.tiltGestures
        //TODO other settings for Android

        if (asListeners.contains(Constants.DID_TAP_AT)) mv.setOnMapClickListener(this)
        if (asListeners.contains(Constants.DID_LONG_PRESS_AT)) mv.setOnMapLongClickListener(this)
        if (asListeners.contains(Constants.DID_TAP_MARKER)) mv.setOnMarkerClickListener(this)
        if (asListeners.contains(Constants.DID_DRAG)) mv.setOnMarkerDragListener(this)
        if (asListeners.contains(Constants.DID_TAP_INFO_WINDOW)) mv.setOnInfoWindowClickListener(this)
        if (asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW)) mv.setOnInfoWindowLongClickListener(this)
        if (asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW)) mv.setOnInfoWindowCloseListener(this)
        if (asListeners.contains(Constants.ON_CAMERA_MOVE)) mv.setOnCameraMoveListener(this)
        if (asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED)) mv.setOnCameraMoveStartedListener(this)
        if (asListeners.contains(Constants.ON_CAMERA_IDLE)) mv.setOnCameraIdleListener(this)

        mv.moveCamera(CameraUpdateFactory.newLatLngZoom(centerAt, zoomLevel))
        val message = ""
        context.dispatchStatusEventAsync(message, Constants.ON_READY)
    }

    constructor(context: FREContext, coordinate: LatLng, zoomLevel: Float, viewPort: Rect, settings: Settings) {
        this.context = context
        this.centerAt = coordinate
        this.zoomLevel = zoomLevel
        this._viewPort = viewPort
        this.settings = settings
        EventBus.getDefault().register(this)
    }

    fun addEventListener(type: String) {
        trace("adding event listener", type)
        asListeners.add(type)
        val mv: GoogleMap = mapView ?: return

        when {
            type == Constants.DID_TAP_AT && asListeners.contains(Constants.DID_TAP_AT) -> mv.setOnMapClickListener(this)
            type == Constants.DID_LONG_PRESS_AT && asListeners.contains(Constants.DID_LONG_PRESS_AT) -> mv.setOnMapLongClickListener(this)
            type == Constants.DID_TAP_MARKER && asListeners.contains(Constants.DID_TAP_MARKER) -> mv.setOnMarkerClickListener(this)
            type == Constants.DID_DRAG && asListeners.contains(Constants.DID_DRAG) -> mv.setOnMarkerDragListener(this)
            type == Constants.DID_TAP_INFO_WINDOW && asListeners.contains(Constants.DID_TAP_INFO_WINDOW) -> mv.setOnInfoWindowClickListener(this)
            type == Constants.DID_LONG_PRESS_INFO_WINDOW && asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW) -> mv.setOnInfoWindowLongClickListener(this)
            type == Constants.DID_CLOSE_INFO_WINDOW && asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW) -> mv.setOnInfoWindowCloseListener(this)
            type == Constants.ON_CAMERA_MOVE && asListeners.contains(Constants.ON_CAMERA_MOVE) -> mv.setOnCameraMoveListener(this)
            asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED) && asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED) -> mv.setOnCameraMoveStartedListener(this)
            asListeners.contains(Constants.ON_CAMERA_IDLE) && asListeners.contains(Constants.ON_CAMERA_IDLE) -> mv.setOnCameraIdleListener(this)
        }
    }

    fun removeEventListener(type: String) {
        trace("remove event listener", type)
        asListeners.remove(type)
        val mv: GoogleMap = mapView ?: return
        if (type == Constants.DID_TAP_AT) {
            mv.setOnMapClickListener(null)
            return
        }
        if (type == Constants.DID_LONG_PRESS_AT) {
            mv.setOnMapLongClickListener(null)
            return
        }
        if (type == Constants.DID_TAP_MARKER) {
            mv.setOnMarkerClickListener(null)
            return
        }
        if (type == Constants.DID_DRAG) {
            mv.setOnMarkerDragListener(null)
            return
        }
        if (type == Constants.DID_TAP_INFO_WINDOW) {
            mv.setOnInfoWindowClickListener(null)
            return
        }
        if (type == Constants.DID_LONG_PRESS_INFO_WINDOW) {
            mv.setOnInfoWindowLongClickListener(null)
            return
        }
        if (type == Constants.DID_CLOSE_INFO_WINDOW) {
            mv.setOnInfoWindowCloseListener(null)
            return
        }
        if (type == Constants.ON_CAMERA_MOVE) {
            mv.setOnCameraMoveListener(null)
            return
        }
    }

    @Throws(FreException::class)
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onMessageEvent(event: MessageEvent) {
        val mv: GoogleMap = mapView ?: return
        var granted = false
        when {
            event.message == Constants.AUTHORIZATION_GRANTED -> {
                if (checkSelfPermission(this.context.activity.applicationContext,
                        ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    mv.isMyLocationEnabled = true
                    mv.uiSettings?.isMyLocationButtonEnabled = true
                    granted = true
                    try {
                        val lastKnownLocation = FusedLocationApi.getLastLocation(googleApiClient) ?: return
                        mv.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lastKnownLocation.latitude, lastKnownLocation.longitude), zoomLevel))
                    } catch (e: Exception) {
                        throw FreException(e)
                    }
                }
            }
            event.message == Constants.AUTHORIZATION_DENIED -> {
                mv.isMyLocationEnabled = false
                mv.uiSettings?.isMyLocationButtonEnabled = false
            }
        }

        val props = JSONObject()
        try {
            props.put("status", if (granted) Constants.AUTHORIZATION_STATUS_ALWAYS else Constants.AUTHORIZATION_STATUS_DENIED)
            sendEvent(Constants.AUTHORIZATION_STATUS, props.toString())
        } catch (e: JSONException) {
            throw FreException(e)
        }
    }

    fun add() {
        val newId = View.generateViewId()

        airView = context.activity.findViewById(android.R.id.content) as ViewGroup
        airView = (airView as ViewGroup).getChildAt(0) as ViewGroup

        container = FrameLayout(context.activity)

        val frame = container ?: return
        frame.layoutParams = FrameLayout.LayoutParams(viewPort.width(), viewPort.height())
        frame.x = viewPort.left.toFloat()
        frame.y = viewPort.top.toFloat()
        frame.id = newId
        (airView as ViewGroup).addView(frame)

        val mMapFragment: MapFragment = MapFragment.newInstance()
        googleApiClient = GoogleApiClient.Builder(this.context.activity.applicationContext)
                .addConnectionCallbacks(this)
                .addApi(API)
                .build()
        googleApiClient?.connect()

        //TODO https://stackoverflow.com/questions/4721449/how-can-i-enable-or-disable-the-gps-programmatically-on
        // -android?noredirect=1&lq=1

        val fragmentTransaction: FragmentTransaction = context.activity.fragmentManager.beginTransaction()
        fragmentTransaction.add(newId, mMapFragment)
        fragmentTransaction.commit()
        mMapFragment.getMapAsync(this)
    }

    fun clear() {
        mapView?.clear()
    }

    var visible: Boolean
        set(value) {
            this._visible = value
            val frame = container ?: return
            frame.visibility = if (_visible) View.VISIBLE else View.INVISIBLE
        }
        get() = _visible

    var viewPort: Rect
        set(value) {
            this._viewPort = value
            val frame = container ?: return
            frame.layoutParams = FrameLayout.LayoutParams(viewPort.width(), viewPort.height())
            frame.x = viewPort.left.toFloat()
            frame.y = viewPort.top.toFloat()
        }
        get() = _viewPort

    var mapType: Int
        get() = _mapType
        set(value) {
            _mapType = value
            mapView?.mapType = _mapType
        }

    var style: String?
        get() = _style
        @Throws(FreException::class)
        set(value) {
            _style = value
            try {
                mapView?.setMapStyle(MapStyleOptions(_style))
            } catch (e: Exception) {
                throw FreException(e, "Cannot set map style")
            }
        }

    fun setBounds(bounds: LatLngBounds, animates: Boolean) {
        val mv: GoogleMap = this.mapView ?: return
        if (animates) {
            mv.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, 0), animationDuration, null)
        } else {
            mv.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds, 0))
        }
    }

    fun moveCamera(position: CameraPosition, animates: Boolean) {
        val mv: GoogleMap = this.mapView ?: return
        if (animates) {
            mv.animateCamera(CameraUpdateFactory.newCameraPosition(position), animationDuration, null)
        } else {
            mv.moveCamera(CameraUpdateFactory.newCameraPosition(position))
        }
    }

    fun zoomIn(animates: Boolean) {
        val mv: GoogleMap = this.mapView ?: return
        if (animates) {
            mv.animateCamera(CameraUpdateFactory.zoomIn(), animationDuration, null)
        } else {
            mv.moveCamera(CameraUpdateFactory.zoomIn())
        }
    }

    fun zoomOut(animates: Boolean) {
        val mv: GoogleMap = this.mapView ?: return
        if (animates) {
            mv.animateCamera(CameraUpdateFactory.zoomOut(), animationDuration, null)
        } else {
            mv.moveCamera(CameraUpdateFactory.zoomOut())
        }
    }

    fun zoomTo(zoomLevel: Float, animates: Boolean) {
        val mv: GoogleMap = this.mapView ?: return
        if (animates) {
            mv.animateCamera(CameraUpdateFactory.zoomTo(zoomLevel), animationDuration, null)
        } else {
            mv.moveCamera(CameraUpdateFactory.zoomTo(zoomLevel))
        }
    }

    fun addCircle(circleOptions: CircleOptions) {
        val mv: GoogleMap = mapView ?: return
        mv.addCircle(circleOptions)
    }

    fun addMarker(markerOptions: MarkerOptions): Marker? {
        val mv: GoogleMap = mapView ?: return null
        val marker: Marker = mv.addMarker(markerOptions) ?: return null
        markers[marker.id] = marker
        trace("adding marker id: ${marker.id}")
        trace("have a google mapView")
        return marker
    }

    fun updateMarker(uuid: String, markerOptions: MarkerOptions) {
        val marker = markers[uuid] ?: return
        trace("updateMarker: $uuid")
        marker.position = markerOptions.position
        marker.title = markerOptions.title
        marker.snippet = markerOptions.snippet
        marker.isFlat = markerOptions.isFlat
        marker.isDraggable = markerOptions.isDraggable
        marker.alpha = markerOptions.alpha
        marker.setIcon(markerOptions.icon)
        marker.rotation = markerOptions.rotation

    }

    fun removeMarker(uuid: String) {
        val marker = markers[uuid] ?: return
        marker.remove()
    }

    fun showInfoWindow(uuid: String) {
        val marker = markers[uuid] ?: return
        marker.showInfoWindow()
    }

    fun hideInfoWindow(uuid: String) {
        val marker = markers[uuid] ?: return
        marker.hideInfoWindow()
    }

    override fun onMarkerClick(p0: Marker?): Boolean {
        if (!asListeners.contains(Constants.DID_TAP_MARKER)) return false
        val marker = p0 ?: return true
        sendEvent(Constants.DID_TAP_MARKER, marker.id)
        return false
    }

    override fun onMarkerDragEnd(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_END_DRAGGING)) return
        val marker = p0 ?: return //TODO return marker - as its coordinates will have updated
        sendEvent(Constants.DID_END_DRAGGING, marker.id)
    }

    override fun onMarkerDragStart(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_BEGIN_DRAGGING)) return
        val marker = p0 ?: return
        sendEvent(Constants.DID_BEGIN_DRAGGING, marker.id)
    }

    override fun onMarkerDrag(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_DRAG)) return
        val marker = p0 ?: return
        sendEvent(Constants.DID_DRAG, marker.id)
    }

    override fun onMapClick(p0: LatLng?) {
        if (!asListeners.contains(Constants.DID_TAP_AT)) return
        val coordinate = p0 ?: return
        val props = JSONObject()
        try {
            props.put("latitude", coordinate.latitude)
            props.put("longitude", coordinate.longitude)
            sendEvent(Constants.DID_TAP_AT, props.toString())
        } catch (e: JSONException) {
        }
    }

    override fun onMapLongClick(p0: LatLng?) {
        if (!asListeners.contains(Constants.DID_LONG_PRESS_AT)) return
        val coordinate = p0 ?: return
        val props = JSONObject()
        try {
            props.put("latitude", coordinate.latitude)
            props.put("longitude", coordinate.longitude)
            context.dispatchStatusEventAsync(props.toString(), Constants.DID_LONG_PRESS_AT)
        } catch (e: JSONException) {
        }
    }

    override fun onInfoWindowClick(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_TAP_INFO_WINDOW)) return
        val marker = p0 ?: return
        sendEvent(Constants.DID_TAP_INFO_WINDOW, marker.id)
    }

    override fun onInfoWindowClose(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW)) return
        val marker = p0 ?: return
        sendEvent(Constants.DID_CLOSE_INFO_WINDOW, marker.id)
    }

    override fun onInfoWindowLongClick(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW)) return
        val marker = p0 ?: return
        sendEvent(Constants.DID_LONG_PRESS_INFO_WINDOW, marker.id)
    }

    override fun onCameraMove() {
        if (!asListeners.contains(Constants.ON_CAMERA_MOVE)) return
        val mv: GoogleMap = mapView ?: return
        val props = JSONObject()
        try {
            props.put("latitude", mv.cameraPosition.target.latitude)
            props.put("longitude", mv.cameraPosition.target.longitude)
            props.put("zoom", mv.cameraPosition.zoom)
            props.put("tilt", mv.cameraPosition.tilt)
            props.put("bearing", mv.cameraPosition.bearing)
            sendEvent(Constants.ON_CAMERA_MOVE, props.toString())
        } catch (e: JSONException) {

        }
    }

    override fun onCameraMoveStarted(reason: Int) {
        if (!asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED)) return
        val props = JSONObject()
        try {
            props.put("reason", reason)
            sendEvent(Constants.ON_CAMERA_MOVE_STARTED, props.toString())
        } catch (e: JSONException) {
        }
    }

    override fun onCameraIdle() {
        if (!asListeners.contains(Constants.ON_CAMERA_IDLE)) return
        sendEvent(Constants.ON_CAMERA_IDLE, "")
    }

    override fun onConnectionFailed(p0: ConnectionResult) {
        trace("GoogleApiClient Not Connected")
    }

    override fun onConnected(p0: Bundle?) {
        trace("GoogleApiClient onConnected")
    }

    override fun onConnectionSuspended(p0: Int) {
        trace("GoogleApiClient onConnectionSuspended")
    }

    private fun trace(vararg value: Any?) {
        context.trace(TAG, value)
    }

    private fun sendEvent(name: String, value: String) {
        context.sendEvent(name, value)
    }

    companion object {
        private var TAG = MapController::class.java.canonicalName
    }




}
