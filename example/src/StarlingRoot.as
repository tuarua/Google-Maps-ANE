package {
import com.tuarua.GoogleMapsANE;
import com.tuarua.fre.ANEError;
import com.tuarua.googlemaps.CameraPosition;
import com.tuarua.googlemaps.Circle;
import com.tuarua.googlemaps.Color;
import com.tuarua.googlemaps.Coordinate;
import com.tuarua.googlemaps.GoogleMapsEvent;
import com.tuarua.googlemaps.MapType;
import com.tuarua.googlemaps.Marker;
import com.tuarua.googlemaps.Settings;
import com.tuarua.googlemaps.StrokePattern;
import com.tuarua.googlemaps.StrokePatternType;
import com.tuarua.location.AuthorizationStatus;
import com.tuarua.location.LocationEvent;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.Rectangle;

import starling.core.Starling;
import starling.display.Sprite;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.AssetManager;

import views.SimpleButton;

public class StarlingRoot extends Sprite {
    private var googleMaps:GoogleMapsANE;
    [Embed(source="pin_b.png")]
    public static const pinImage:Class;

    private var firstMarkerId:String;

    private var btn:SimpleButton = new SimpleButton("clear me");
    private var btn2:SimpleButton = new SimpleButton("set viewPort");
    private var btn3:SimpleButton = new SimpleButton("toggle visible");
    private var btn4:SimpleButton = new SimpleButton("Dublin");
    private var btn5:SimpleButton = new SimpleButton("Night");
    private var btn6:SimpleButton = new SimpleButton("Satellite");
    private var btn7:SimpleButton = new SimpleButton("Find me");

    private static const nightStyle:String = "[{\"featureType\":\"all\",\"elementType\":\"geometry\"," +
            "\"stylers\":[{\"color\":\"#242f3e\"}]},{\"featureType\":\"all\",\"elementType\":\"labels.text.stroke\"," +
            "\"stylers\":[{\"lightness\":-80}]},{\"featureType\":\"administrative\",\"elementType\":\"labels.text.fill\"," +
            "\"stylers\":[{\"color\":\"#746855\"}]},{\"featureType\":\"administrative.locality\"," +
            "\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi\"," +
            "\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi.park\"," +
            "\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#263c3f\"}]},{\"featureType\":\"poi.park\"," +
            "\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#6b9a76\"}]},{\"featureType\":\"road\"," +
            "\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#2b3544\"}]},{\"featureType\":\"road\"," +
            "\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#9ca5b3\"}]},{\"featureType\":\"road.arterial\"," +
            "\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#38414e\"}]},{\"featureType\":\"road.arterial\"," +
            "\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#212a37\"}]},{\"featureType\":\"road.highway\"," +
            "\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#746855\"}]},{\"featureType\":\"road.highway\"," +
            "\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#1f2835\"}]},{\"featureType\":\"road.highway\"," +
            "\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#f3d19c\"}]},{\"featureType\":\"road.local\"," +
            "\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#38414e\"}]},{\"featureType\":\"road.local\"," +
            "\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#212a37\"}]},{\"featureType\":\"transit\"," +
            "\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2f3948\"}]},{\"featureType\":\"transit.station\"," +
            "\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"water\"," +
            "\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#17263c\"}]},{\"featureType\":\"water\"," +
            "\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#515c6d\"}]},{\"featureType\":\"water\"," +
            "\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"lightness\":-20}]}]";

    public function StarlingRoot() {
    }

    public function start(assets:AssetManager):void {
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
        var _assets:AssetManager = assets;

        googleMaps = new GoogleMapsANE();
        googleMaps.init("");
        var viewPort:Rectangle = new Rectangle(0, 100, stage.stageWidth, stage.stageHeight - 100);

        trace("as viewPort", viewPort);

        var coordinate:Coordinate = new Coordinate(53.836549, -6.393717);
        trace("coordinate passed into ANE", coordinate.latitude, coordinate.longitude);

        googleMaps.initMap(viewPort, coordinate, 12.0, new Settings(), Starling.current.contentScaleFactor);
        googleMaps.addEventListener(GoogleMapsEvent.ON_READY, onMapReady);
        googleMaps.addEventListener(GoogleMapsEvent.DID_TAP_AT, onDidTapAt);
        googleMaps.addEventListener(GoogleMapsEvent.DID_LONG_PRESS_AT, onDidLongPressAt);
        googleMaps.addEventListener(GoogleMapsEvent.DID_TAP_MARKER, onDidTapMarker);
        googleMaps.addEventListener(GoogleMapsEvent.DID_BEGIN_DRAGGING, onDidBeginDragging);
        googleMaps.addEventListener(GoogleMapsEvent.DID_END_DRAGGING, onDidEndDragging);
        googleMaps.addEventListener(GoogleMapsEvent.DID_DRAG, onDidDrag);
        googleMaps.addEventListener(GoogleMapsEvent.ON_CAMERA_MOVE_STARTED, onCameraMoveStarted);
        //googleMaps.addEventListener(GoogleMapsEvent.ON_CAMERA_MOVE, onCameraMove);
        googleMaps.addEventListener(GoogleMapsEvent.ON_CAMERA_IDLE, onCameraIdle);
        googleMaps.addEventListener(LocationEvent.LOCATION_UPDATED, onLocationUpdated);
        googleMaps.addEventListener(LocationEvent.AUTHORIZATION_STATUS, onLocationAuthStatus);
        googleMaps.visible = true; //map is invisible by default when inited


        btn.x = 10;
        btn7.y = btn3.y = btn2.y = btn.y = 10;
        btn6.y = btn5.y = btn4.y = 60;
        btn.addEventListener(TouchEvent.TOUCH, onZoomIn);
        addChild(btn);

        btn2.x = 100;
        btn2.addEventListener(TouchEvent.TOUCH, onSetViewPort);
        addChild(btn2);

        btn3.x = 190;
        btn3.addEventListener(TouchEvent.TOUCH, onToggleVisible);
        addChild(btn3);

        btn4.x = 10;
        btn4.addEventListener(TouchEvent.TOUCH, onDublin);
        addChild(btn4);

        btn5.x = 100;
        btn5.addEventListener(TouchEvent.TOUCH, onNightStyle);
        addChild(btn5);

        btn6.x = 190;
        btn6.addEventListener(TouchEvent.TOUCH, onMapType);
        addChild(btn6);

        btn7.x = 280;
        btn7.addEventListener(TouchEvent.TOUCH, onFindMe);
        addChild(btn7);

        stage.addEventListener(Event.RESIZE, onResize);

    }

    private static function onCameraMoveStarted(event:GoogleMapsEvent):void {
        switch (event.params.reason) {
            case GoogleMapsEvent.CAMERA_MOVE_REASON_GESTURE:
                trace("Camera move started", "CAMERA_MOVE_REASON_GESTURE");
                break;
            case GoogleMapsEvent.CAMERA_MOVE_REASON_API_ANIMATION:
                trace("Camera move started", "CAMERA_MOVE_REASON_API_ANIMATION");
                break;
            case GoogleMapsEvent.CAMERA_MOVE_REASON_DEVELOPER_ANIMATION:
                trace("Camera move started", "CAMERA_MOVE_REASON_DEVELOPER_ANIMATION");
                break;
        }
    }

    private static function onCameraMove(event:GoogleMapsEvent):void {
        var props:Object = event.params;
        trace("latlng:", props.latitude, props.longitude, "zoom", props.zoom, "tilt", props.tilt, "bearing", props.bearing);

    }

    private static function onCameraIdle(event:GoogleMapsEvent):void {
        trace(event);
    }

    private function onMapReady(event:GoogleMapsEvent):void {
        var coordinate:Coordinate = new Coordinate(53.836549, -6.393717);
        var marker:Marker = new Marker(coordinate, "Dunleer", "Home");
        marker.color = Color.YELLOW;
        marker.icon = (new pinImage() as Bitmap).bitmapData;
        marker.isFlat = false;
        marker.isDraggable = true;
        firstMarkerId = googleMaps.addMarker(marker);
        trace("uuid for marker", firstMarkerId);
    }


    private function onDidEndDragging(event:GoogleMapsEvent):void {
        trace(event);
        var uuid:String = event.params as String;
        var marker:Marker = googleMaps.markers[uuid] as Marker;
        trace("end drag marker", uuid, marker.title);
    }

    private function onDidBeginDragging(event:GoogleMapsEvent):void {
        trace(event);
        var uuid:String = event.params as String;
        var marker:Marker = googleMaps.markers[uuid] as Marker;
        trace("begin drag marker", uuid, marker.title);
    }

    private function onDidDrag(event:GoogleMapsEvent):void {
        //trace(event);
    }

    private function onLocationUpdated(event:LocationEvent):void {
        var coordinate:Coordinate = event.params as Coordinate;
        trace("user found at", coordinate.latitude, coordinate.longitude);
        var cameraPosition:CameraPosition = new CameraPosition();
        cameraPosition.target = coordinate;
        googleMaps.moveCamera(cameraPosition);
    }

    private static function onLocationAuthStatus(event:LocationEvent):void {
        var status:int = event.params.status;
        switch (status) {
            case AuthorizationStatus.ALWAYS:
                trace("Location status: Always");
                break;
            case AuthorizationStatus.WHEN_IN_USE:
                trace("Location status: When in use");
                break;
            case AuthorizationStatus.RESTRICTED:
                trace("Location status: Restricted");
                break;
            case AuthorizationStatus.DENIED:
                trace("Location status: Denied");
                break;
            case AuthorizationStatus.NOT_DETERMINED:
                trace("Location status: Not determined");
                break;
        }
    }

    private function onUpdateMarker(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            var marker:Marker = googleMaps.markers[firstMarkerId];
            marker.color = Color.GREEN;
            marker.title = "Updated title";
            googleMaps.updateMarker(firstMarkerId);
        }
    }

    private function onZoomIn(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            googleMaps.animationDuration = 500;
            googleMaps.zoomIn(true); // googleMaps.zoomOut();
        }
    }

    private function onAddCircle(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            var circle:Circle = new Circle(new Coordinate(53.836549, -6.393717));
            circle.fillAlpha = 0.2;
            circle.fillColor = Color.PURPLE;
            circle.radius = 2000;
            circle.strokeWidth = 8.0;
            circle.strokeColor = Color.GREEN;
            circle.strokePattern = new StrokePattern(StrokePatternType.DOTTED, 100, 100);
            googleMaps.addCircle(circle);
        }
    }

    private function onClear(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            googleMaps.clear();
        }
    }

    private function onSetViewPort(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn2);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            trace("set viewpport the map");
            googleMaps.viewPort = new Rectangle(0, 200, 400, 400);
        }
    }

    private function onToggleVisible(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn3);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            googleMaps.visible = !googleMaps.visible;
        }
    }

    private function onDublin(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn4);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            var dublin:Coordinate = new Coordinate(53.341273, -6.2887817);
            var newPosition:CameraPosition = new CameraPosition();
            newPosition.target = dublin;
            newPosition.zoom = 10.0;
            newPosition.bearing = 90;
            newPosition.tilt = 30;
            googleMaps.moveCamera(newPosition, true);
        }
    }

    private function onNightStyle(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn5);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            googleMaps.style = nightStyle;
        }
    }

    private function onMapType(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn6);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            googleMaps.mapType = MapType.SATELLITE;
        }
    }

    private function onFindMe(event:TouchEvent):void {
        var touch:Touch = event.getTouch(btn7);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            googleMaps.requestLocation();
        }
    }

    private function onDidTapMarker(event:GoogleMapsEvent):void {
        var uuid:String = event.params as String;
        var marker:Marker = googleMaps.markers[uuid] as Marker;
        trace("tapped marker", uuid, marker.title);
    }

    private static function onDidTapAt(event:GoogleMapsEvent):void {
        var coordinate:Coordinate = event.params as Coordinate;
        trace("tapped at", coordinate.latitude, coordinate.longitude);
    }

    private static function onDidLongPressAt(event:GoogleMapsEvent):void {
        var coordinate:Coordinate = event.params as Coordinate;
        trace("long pressed at", coordinate.latitude, coordinate.longitude);
    }

    public function onResize(event:ResizeEvent):void {

        var current:Starling = Starling.current;
        var scale:Number = current.contentScaleFactor;

        stage.stageWidth = event.width / scale;
        stage.stageHeight = event.height / scale;

        current.viewPort.width = stage.stageWidth * scale;
        current.viewPort.height = stage.stageHeight * scale;

        trace(current.viewPort);

        googleMaps.viewPort = new Rectangle(0, 100, stage.stageWidth, stage.stageHeight - 100);

    }

    /**
     * It's very important to call webView.dispose(); when the app is exiting.
     */
    private function onExiting(event:Event):void {
        googleMaps.dispose();
    }
}
}