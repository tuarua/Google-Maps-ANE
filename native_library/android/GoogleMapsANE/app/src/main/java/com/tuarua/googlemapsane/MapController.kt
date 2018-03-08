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
import android.graphics.Bitmap
import android.location.Location
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.adobe.fre.FREContext
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapFragment
import com.google.android.gms.maps.OnMapReadyCallback
import android.support.v4.content.ContextCompat.checkSelfPermission
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.*
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.CircleOptions
import com.google.android.gms.tasks.Task
import com.google.gson.Gson
import com.tuarua.frekotlin.*
import com.tuarua.frekotlin.geom.Rect
import com.tuarua.googlemapsane.data.*

class MapController(override var context: FREContext?, private var airView: ViewGroup, coordinate: LatLng,
                    private var zoomLevel: Float, viewPort: Rect, private var settings: Settings) : FreKotlinController,
        OnMapReadyCallback,
        GoogleMap.OnMarkerClickListener, GoogleMap.OnMarkerDragListener,
        GoogleMap.OnMapClickListener, GoogleMap.OnMapLongClickListener, GoogleMap.OnInfoWindowClickListener,
        GoogleMap.OnInfoWindowCloseListener, GoogleMap.OnInfoWindowLongClickListener,
        GoogleMap.OnCameraMoveListener, GoogleMap.OnCameraMoveStartedListener, GoogleMap.OnCameraIdleListener,
        GoogleMap.OnMapLoadedCallback, GoogleMap.OnGroundOverlayClickListener, GoogleMap.OnPolylineClickListener,
        GoogleMap.OnPolygonClickListener {


    private var fusedLocationProviderClient: FusedLocationProviderClient? = null
    private var _viewPort: Rect = viewPort
    private var _visible: Boolean = false
    private var _style: String? = null
    private var _mapType = 0
    private var centerAt: LatLng = coordinate
    private lateinit var mMapFragment: MapFragment
    private var mapView: GoogleMap? = null
    private var container: FrameLayout? = null
    private var asListeners: MutableList<String> = mutableListOf()
    private val markers = mutableMapOf<String, Marker>()
    private val circles = mutableMapOf<String, Circle>()
    private val overlays = mutableMapOf<String, GroundOverlay>()
    private val polylines = mutableMapOf<String, Polyline>()
    private val polygons = mutableMapOf<String, Polygon>()
    var animationDuration: Int = 2000
    private val gson = Gson()
    private var lastCapture: Bitmap? = null
    override fun onMapReady(googleMap: GoogleMap?) {
        mapView = googleMap
        val mv: GoogleMap = mapView ?: return

        mv.setOnMapLoadedCallback(this)

        val ctx = context
        if (ctx != null) {
            if (ctx.activity != null) {
                if (checkSelfPermission(ctx.activity.applicationContext, ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    mv.uiSettings.isMyLocationButtonEnabled = settings.myLocationButtonEnabled
                    mv.isMyLocationEnabled = settings.myLocationEnabled
                }
            }
        }

        mv.uiSettings.isCompassEnabled = settings.compassButton
        mv.uiSettings.isRotateGesturesEnabled = settings.rotateGestures
        mv.uiSettings.isIndoorLevelPickerEnabled = settings.indoorPicker
        mv.uiSettings.isScrollGesturesEnabled = settings.scrollGestures
        mv.uiSettings.isZoomGesturesEnabled = settings.zoomGestures
        mv.uiSettings.isTiltGesturesEnabled = settings.tiltGestures
        mv.uiSettings.isMapToolbarEnabled = settings.mapToolbarEnabled
        mv.isBuildingsEnabled = settings.buildingsEnabled

        if (asListeners.contains(Constants.DID_TAP_AT)) mv.setOnMapClickListener(this)
        if (asListeners.contains(Constants.DID_LONG_PRESS_AT)) mv.setOnMapLongClickListener(this)
        if (asListeners.contains(Constants.DID_TAP_MARKER)) mv.setOnMarkerClickListener(this)
        if (asListeners.contains(Constants.DID_DRAG)) mv.setOnMarkerDragListener(this)
        if (asListeners.contains(Constants.DID_TAP_INFO_WINDOW)) mv.setOnInfoWindowClickListener(this)
        if (asListeners.contains(Constants.DID_TAP_GROUND_OVERLAY)) mv.setOnGroundOverlayClickListener(this)
        if (asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW)) mv.setOnInfoWindowLongClickListener(this)
        if (asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW)) mv.setOnInfoWindowCloseListener(this)
        if (asListeners.contains(Constants.ON_CAMERA_MOVE)) mv.setOnCameraMoveListener(this)
        if (asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED)) mv.setOnCameraMoveStartedListener(this)
        if (asListeners.contains(Constants.ON_CAMERA_IDLE)) mv.setOnCameraIdleListener(this)

        mv.moveCamera(CameraUpdateFactory.newLatLngZoom(centerAt, zoomLevel))
        sendEvent(Constants.ON_READY, "")
    }

    override fun onMapLoaded() {
        sendEvent(Constants.ON_LOADED, "")
    }

    fun addEventListener(type: String) {
        asListeners.add(type)
        val mv: GoogleMap = mapView ?: return

        when {
            type == Constants.DID_TAP_AT && asListeners.contains(Constants.DID_TAP_AT) -> mv.setOnMapClickListener(this)
            type == Constants.DID_LONG_PRESS_AT && asListeners.contains(Constants.DID_LONG_PRESS_AT) -> mv.setOnMapLongClickListener(this)
            type == Constants.DID_TAP_MARKER && asListeners.contains(Constants.DID_TAP_MARKER) -> mv.setOnMarkerClickListener(this)
            type == Constants.DID_DRAG && asListeners.contains(Constants.DID_DRAG) -> mv.setOnMarkerDragListener(this)
            type == Constants.DID_TAP_INFO_WINDOW && asListeners.contains(Constants.DID_TAP_INFO_WINDOW) -> mv.setOnInfoWindowClickListener(this)
            type == Constants.DID_TAP_GROUND_OVERLAY && asListeners.contains(Constants.DID_TAP_GROUND_OVERLAY) -> mv.setOnGroundOverlayClickListener(this)
            type == Constants.DID_TAP_POLYLINE && asListeners.contains(Constants.DID_TAP_POLYLINE) -> mv.setOnPolylineClickListener(this)
            type == Constants.DID_TAP_POLYGON && asListeners.contains(Constants.DID_TAP_POLYGON) -> mv.setOnPolygonClickListener(this)
            type == Constants.DID_LONG_PRESS_INFO_WINDOW && asListeners.contains(Constants.DID_LONG_PRESS_INFO_WINDOW) -> mv.setOnInfoWindowLongClickListener(this)
            type == Constants.DID_CLOSE_INFO_WINDOW && asListeners.contains(Constants.DID_CLOSE_INFO_WINDOW) -> mv.setOnInfoWindowCloseListener(this)
            type == Constants.ON_CAMERA_MOVE && asListeners.contains(Constants.ON_CAMERA_MOVE) -> mv.setOnCameraMoveListener(this)
            asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED) && asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED) -> mv.setOnCameraMoveStartedListener(this)
            asListeners.contains(Constants.ON_CAMERA_IDLE) && asListeners.contains(Constants.ON_CAMERA_IDLE) -> mv.setOnCameraIdleListener(this)
        }
    }

    fun removeEventListener(type: String) {
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
        if (type == Constants.DID_TAP_POLYLINE) {
            mv.setOnPolylineClickListener(null)
            return
        }
        if (type == Constants.DID_TAP_POLYGON) {
            mv.setOnPolygonClickListener(null)
            return
        }
        if (type == Constants.DID_TAP_GROUND_OVERLAY) {
            mv.setOnGroundOverlayClickListener(null)
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

    fun showUserLocation() {
        val mv: GoogleMap = mapView ?: return
        val ctx = this.context ?: return
        if (checkSelfPermission(ctx.activity.applicationContext, ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            if (fusedLocationProviderClient == null) {
                fusedLocationProviderClient = FusedLocationProviderClient(ctx.activity.applicationContext)
            }
            val fusedProvider = fusedLocationProviderClient ?: return

            val locationResult = fusedProvider.lastLocation
            locationResult.addOnCompleteListener(ctx.activity, { task: Task<Location> ->
                if (task.isSuccessful) {
                    mv.isMyLocationEnabled = settings.myLocationEnabled
                    mv.uiSettings?.isMyLocationButtonEnabled = settings.myLocationButtonEnabled
                    val lastKnownLocation = task.result
                    if (lastKnownLocation != null) {
                        sendEvent(Constants.LOCATION_UPDATED, gson.toJson(MapEvent(
                                lastKnownLocation.latitude,
                                lastKnownLocation.longitude)))
                    }
                } else {
                    mv.isMyLocationEnabled = false
                    mv.uiSettings?.isMyLocationButtonEnabled = false
                }
            })

        }
    }

    fun add() {
        val newId = View.generateViewId()
        val ctx = this.context ?: return
        container = FrameLayout(ctx.activity)
        val frame = container ?: return
        frame.layoutParams = FrameLayout.LayoutParams(viewPort.width.toInt(), viewPort.height.toInt())
        frame.x = viewPort.x.toFloat()
        frame.y = viewPort.y.toFloat()
        frame.id = newId
        airView.addView(frame)

        mMapFragment = MapFragment.newInstance()
        val fragmentTransaction: FragmentTransaction = ctx.activity.fragmentManager.beginTransaction()
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
            frame.layoutParams = FrameLayout.LayoutParams(viewPort.width.toInt(), viewPort.height.toInt())
            frame.x = viewPort.x.toFloat()
            frame.y = viewPort.y.toFloat()
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

    fun moveCamera(centerAt: LatLng?, zoom: Float?, tilt: Float?, bearing: Float?, animates: Boolean) {
        val mv: GoogleMap = this.mapView ?: return
        val currentCamera = mv.cameraPosition
        val cameraPositionBuilder: CameraPosition.Builder = CameraPosition.builder()
        when (centerAt) {
            null -> cameraPositionBuilder.target(currentCamera.target)
            else -> cameraPositionBuilder.target(centerAt)
        }
        when (zoom) {
            null -> cameraPositionBuilder.zoom(currentCamera.zoom)
            else -> cameraPositionBuilder.zoom(zoom)
        }
        when (tilt) {
            null -> cameraPositionBuilder.tilt(currentCamera.tilt)
            else -> cameraPositionBuilder.tilt(tilt)
        }
        when (bearing) {
            null -> cameraPositionBuilder.bearing(currentCamera.bearing)
            else -> cameraPositionBuilder.bearing(bearing)
        }

        val position = cameraPositionBuilder.build()
        when {
            animates -> mv.animateCamera(CameraUpdateFactory.newCameraPosition(position), animationDuration, null)
            else -> mv.moveCamera(CameraUpdateFactory.newCameraPosition(position))
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

    fun scrollBy(x: Float, y: Float, animates: Boolean) {
        val mv: GoogleMap = this.mapView ?: return
        if (animates) {
            mv.animateCamera(CameraUpdateFactory.scrollBy(x, y), animationDuration, null)
        } else {
            mv.moveCamera(CameraUpdateFactory.scrollBy(x, y))
        }
    }

    fun addCircle(circleOptions: CircleOptions): Circle? {
        val mv: GoogleMap = mapView ?: return null
        val circle: Circle = mv.addCircle(circleOptions)
        circles[circle.id] = circle
        return circle
    }

    fun setCircleProp(id: String, name: String, value: FREObject?) {
        val circle = circles[id] ?: return
        when (name) {
            "center" -> circle.setCenter(value)
            "radius" -> circle.setRadius(value)
            "strokeWidth" -> circle.setStrokeWidth(value)
            "strokeColor" -> circle.setStrokeColor(value)
            "strokePattern" -> circle.setStrokePattern(value)
            "fillColor" -> circle.setFillColor(value)
            "zIndex" -> circle.setZIndex(value)
            "visible" -> circle.setVisible(value)
            "isTappable" -> circle.setClickable(value)
        }
    }

    fun removeCircle(id: String) {
        val circle = circles[id] ?: return
        markers.remove(id)
        circle.remove()
        circles.remove(id)
    }

    fun addMarker(markerOptions: MarkerOptions): Marker? {
        val mv: GoogleMap = mapView ?: return null
        val marker: Marker = mv.addMarker(markerOptions) ?: return null
        markers[marker.id] = marker
        return marker
    }

    fun setMarkerProp(id: String, name: String, value: FREObject?) {
        val marker = markers[id] ?: return
        when (name) {
            "isFlat" -> marker.setFlat(value)
            "title" -> marker.setTitle(value)
            "snippet" -> marker.setSnippet(value)
            "isDraggable" -> marker.setDraggable(value)
            "alpha" -> marker.setAlpha(value)
            "rotation" -> marker.setRotation(value)
            "icon" -> marker.setIcon(value)
            "color" -> marker.setColor(value)
            "coordinate" -> marker.setPosition(value)
        }
    }

    fun removeMarker(id: String) {
        val marker = markers[id] ?: return
        marker.remove()
        markers.remove(id)
    }

    fun addGroundOverlay(options: GroundOverlayOptions): GroundOverlay? {
        val mv: GoogleMap = mapView ?: return null
        val overlay: GroundOverlay = mv.addGroundOverlay(options)
        overlays[overlay.id] = overlay
        return overlay
    }

    fun setGroundOverlayProp(id: String, name: String, value: FREObject?) {
        val overlay = overlays[id] ?: return
        when (name) {
            "bearing" -> overlay.setBearing(value)
            "isTappable" -> overlay.setClickable(value)
            "visible" -> overlay.setVisible(value)
            "transparency" -> overlay.setTransparency(value)
            "zIndex" -> overlay.setZIndex(value)
            "image" -> overlay.setImage(value)
            "coordinate" -> overlay.setPosition(value)
        }
    }

    fun removeGroundOverlay(id: String) {
        val overlay = overlays[id] ?: return
        overlay.remove()
        overlays.remove(id)
    }

    fun addPolyline(options: PolylineOptions): Polyline? {
        val mv: GoogleMap = mapView ?: return null
        val polyline: Polyline = mv.addPolyline(options)
        polylines[polyline.id] = polyline
        return polyline
    }

    fun setPolylineProp(id: String, name: String, value: FREObject?) {
        val polyline = polylines[id] ?: return
        when (name) {
            "isTappable" -> polyline.setClickable(value)
            "color" -> polyline.setColor(value)
            "visible" -> polyline.setVisible(value)
            "zIndex" -> polyline.setZIndex(value)
            "width" -> polyline.setWidth(value)
            "geodesic" -> polyline.setGeodesic(value)
            "jointType" -> polyline.setJointType(value)
            "pattern" -> polyline.setPattern(value)
            "points" -> polyline.addAll(value)
        }
    }

    fun removePolyline(id: String) {
        val polyline = polylines[id] ?: return
        polyline.remove()
        polylines.remove(id)
    }

    fun addPolygon(options: PolygonOptions): Polygon? {
        val mv: GoogleMap = mapView ?: return null
        val polygon: Polygon = mv.addPolygon(options)
        polygons[polygon.id] = polygon
        return polygon
    }

    fun setPolygonProp(id: String, name: String, value: FREObject?) {
        val polygon = polygons[id] ?: return
        when (name) {
            "isTappable" -> polygon.setClickable(value)
            "visible" -> polygon.setVisible(value)
            "zIndex" -> polygon.setZIndex(value)
            "geodesic" -> polygon.setGeodesic(value)
            "fillColor" -> polygon.setFillColor(value)
            "strokeWidth" -> polygon.setStrokeWidth(value)
            "strokeColor" -> polygon.setStrokeColor(value)
            "strokePattern" -> polygon.setStrokePattern(value)
            "strokeJointType" -> polygon.setStrokeJointType(value)
            "points" -> polygon.addAll(value)
            "holes" -> polygon.addHoles(value)
        }
    }

    fun removePolygon(id: String) {
        val polygon = polygons[id] ?: return
        polygon.remove()
        polygons.remove(id)
    }

    fun showInfoWindow(id: String) {
        val marker = markers[id] ?: return
        marker.showInfoWindow()
    }

    fun hideInfoWindow(id: String) {
        val marker = markers[id] ?: return
        marker.hideInfoWindow()
    }

    fun capture(x: Int, y: Int, w: Int, h: Int) {
        val mv: GoogleMap = mapView ?: return
        var theW = w
        var theH = h

        mv.snapshot { _bitmap ->

            if ((x + theW) > _bitmap.width) {
                theW = _bitmap.width - x
            }

            if ((y + theH) > _bitmap.height) {
                theH = _bitmap.height - y
            }

            lastCapture = when {
                w > 0 && h > 0 -> Bitmap.createBitmap(_bitmap, x, y, theW, theH)
                else -> _bitmap
            }
            sendEvent(Constants.ON_BITMAP_READY, "")
        }
    }

    fun getCapture(): Bitmap? {
        return lastCapture
    }

    override fun onMarkerClick(p0: Marker?): Boolean {
        if (!asListeners.contains(Constants.DID_TAP_MARKER)) return false
        val marker = p0 ?: return true
        sendEvent(Constants.DID_TAP_MARKER, marker.id)
        return false
    }

    override fun onMarkerDragEnd(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_END_DRAGGING)) return
        val marker = p0 ?: return
        val coordinate = marker.position
        sendEvent(Constants.DID_END_DRAGGING, gson.toJson(MapEvent(
                coordinate.latitude,
                coordinate.longitude, marker.id)))
    }

    override fun onMarkerDragStart(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_BEGIN_DRAGGING)) return
        val marker = p0 ?: return
        sendEvent(Constants.DID_BEGIN_DRAGGING, marker.id)
    }

    override fun onMarkerDrag(p0: Marker?) {
        if (!asListeners.contains(Constants.DID_DRAG)) return
        val marker = p0 ?: return
        sendEvent(Constants.DID_DRAG, marker.id) //TODO coordinates ?
    }

    override fun onMapClick(p0: LatLng?) {
        if (!asListeners.contains(Constants.DID_TAP_AT)) return
        val coordinate = p0 ?: return

        sendEvent(Constants.DID_TAP_AT, gson.toJson(MapEvent(
                coordinate.latitude,
                coordinate.longitude)))
    }

    override fun onMapLongClick(p0: LatLng?) {
        if (!asListeners.contains(Constants.DID_LONG_PRESS_AT)) return
        val coordinate = p0 ?: return
        sendEvent(Constants.DID_LONG_PRESS_AT, gson.toJson(MapEvent(
                coordinate.latitude,
                coordinate.longitude)))
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

        sendEvent(Constants.ON_CAMERA_MOVE, gson.toJson(CameraMoveEvent(
                mv.cameraPosition.target.latitude,
                mv.cameraPosition.target.longitude,
                mv.cameraPosition.zoom,
                mv.cameraPosition.tilt,
                mv.cameraPosition.bearing)))
    }

    fun dispose() {
        airView.removeView(container)
        container = null
        mapView = null
    }

    override fun onCameraMoveStarted(reason: Int) {
        if (!asListeners.contains(Constants.ON_CAMERA_MOVE_STARTED)) return
        sendEvent(Constants.ON_CAMERA_MOVE_STARTED, gson.toJson(CameraMoveStartedEvent(reason)))
    }

    override fun onCameraIdle() {
        if (!asListeners.contains(Constants.ON_CAMERA_IDLE)) return
        sendEvent(Constants.ON_CAMERA_IDLE, "")
    }

    override fun onGroundOverlayClick(p0: GroundOverlay?) {
        if (!asListeners.contains(Constants.DID_TAP_GROUND_OVERLAY)) return
        val overlay = p0 ?: return
        sendEvent(Constants.DID_TAP_GROUND_OVERLAY, overlay.id)
    }

    override fun onPolylineClick(p0: Polyline?) {
        if (!asListeners.contains(Constants.DID_TAP_POLYLINE)) return
        val polyline = p0 ?: return
        sendEvent(Constants.DID_TAP_POLYLINE, polyline.id)
    }

    override fun onPolygonClick(p0: Polygon?) {
        if (!asListeners.contains(Constants.DID_TAP_POLYGON)) return
        val polygon = p0 ?: return
        sendEvent(Constants.DID_TAP_POLYGON, polygon.id)
    }

    override val TAG: String
        get() = this::class.java.simpleName




}




