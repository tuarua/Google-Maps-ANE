package com.tuarua.googlemaps {
import com.tuarua.GoogleMapsANEContext;
import com.tuarua.fre.ANEError;
[RemoteClass(alias="com.tuarua.googlemaps.Polyline")]
public class Polyline extends Shape {
    private var _color:uint = ColorARGB.RED;
    private var _width:Number = 10.0;
    private var _geodesic:Boolean = true;
    private var _pattern:StrokePattern = new StrokePattern();
    private var _jointType:int = JointType.DEFAULT;
    private var _startCap:int = CapType.SQUARE;
    private var _endCap:int = CapType.SQUARE;
    private var _points:Vector.<Coordinate> = new Vector.<Coordinate>();

    public function Polyline(points:Vector.<Coordinate>, color:uint, tappable:Boolean = false,
                             visible:Boolean = true, zIndex:Number = 0, width:Number = 10.0, geodesic:Boolean = true,
                             jointType:int = JointType.DEFAULT, startCap:int = CapType.SQUARE,
                             endCap:int = CapType.SQUARE, pattern:StrokePattern = null) {
        _points = points;
        _color = color;
        _isTappable = tappable;
        _visible = visible;
        _zIndex = zIndex;
        _width = width;
        _geodesic = geodesic;
        if (pattern) _pattern = pattern;
        _jointType = jointType;
        _startCap = startCap;
        _endCap = endCap;
    }
    /**
     * Ignored on Apple Maps
     */
    public function set isTappable(value:Boolean):void {
        _isTappable = value;
        setAneValue("isTappable", value);
    }

    public function get color():uint {
        return _color;
    }

    /**
     * The color of the circle outline in ARGB format, the same format used by Color.
     * The default value is red (0xffff0000).
     */
    public function set color(value:uint):void {
        _color = value;
        setAneValue("color", value);
    }

    /**
     * Indicates if the circle is visible or invisible, i.e., whether it is drawn on the map.
     * An invisible polyline is not drawn, but retains all of its other properties.
     * The default is true, i.e., visible.
     *
     * Ignored on iOS
     *
     */
    public function set visible(value:Boolean):void {
        _visible = value;
        setAneValue("visible", value);
    }

    /**
     * The order in which this tile overlay is drawn with respect to other overlays
     * (including GroundOverlays, TileOverlays, Polylines, and Polygons but not Markers).
     * An overlay with a larger z-index is drawn over overlays with smaller z-indices.
     * The order of overlays with the same z-index is arbitrary. The default zIndex is 0.
     *
     * Ignored on Apple Maps
     *
     */
    public function set zIndex(value:Number):void {
        _zIndex = value;
        setAneValue("zIndex", value);
    }

    public function get width():Number {
        return _width;
    }

    public function set width(value:Number):void {
        _width = value;
        setAneValue("width", value);
    }

    public function remove():void {
        if (_isAdded) {
            var theRet:* = GoogleMapsANEContext.context.call("removePolyline", _id);
            if (theRet is ANEError) throw theRet as ANEError;
        }
    }

    public function get geodesic():Boolean {
        return _geodesic;
    }

    /**
     * Sets whether to draw each segment of the line as a geodesic or not.
     *
     * Ignored on Apple Maps
     */
    public function set geodesic(value:Boolean):void {
        _geodesic = value;
        setAneValue("geodesic", value);
    }

    public function get pattern():StrokePattern {
        return _pattern;
    }
    /**
     * Sets the stroke pattern of the polyline.
     *
     * Ignored on iOS
     */
    public function set pattern(value:StrokePattern):void {
        _pattern = value;
        setAneValue("pattern", value);
    }

    public function get jointType():int {
        return _jointType;
    }
    /**
     * Sets the joint type for all vertices of the polyline except the start and end vertices.
     *
     * Ignored on iOS
     */
    public function set jointType(value:int):void {
        _jointType = value;
        setAneValue("jointType", value);
    }

    public function get startCap():int {
        return _startCap;
    }
    /**
     * Sets the cap at the start vertex of this polyline.
     *
     * Ignored on iOS
     */
    public function set startCap(value:int):void {
        _startCap = value;
        setAneValue("startCap", value);
    }

    public function get endCap():int {
        return _endCap;
    }
    /**
     * Sets the cap at the end vertex of this polyline.
     *
     * Ignored on iOS
     */
    public function set endCap(value:int):void {
        _endCap = value;
        setAneValue("endCap", value);
    }

    public function set points(value:Vector.<Coordinate>):void {
        _points = value;
        setAneValue("points", value);
    }

    public function get points():Vector.<Coordinate> {
        return _points;
    }

    /**
     * Adds a point to the Polyline.
     *
     */
    public function add(point:Coordinate):void {
        _points.push(point);
        setAneValue("points", _points);
    }

    /**
     * This method is omitted from the output. * * @private
     */
    private function setAneValue(name:String, value:*):void {
        if (_isAdded) {
            var theRet:* = GoogleMapsANEContext.context.call("setPolylineProp", _id, name, value);
            if (theRet is ANEError) throw theRet as ANEError;
            delete GoogleMapsANEContext.polylines[_id];
        }
    }

}
}
