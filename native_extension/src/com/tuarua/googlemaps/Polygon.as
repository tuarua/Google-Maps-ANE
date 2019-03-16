package com.tuarua.googlemaps {
import com.tuarua.GoogleMapsANEContext;
import com.tuarua.fre.ANEError;

[RemoteClass(alias="com.tuarua.googlemaps.Polygon")]
public class Polygon extends Shape {
    private var _geodesic:Boolean = true;
    private var _strokeJointType:int = JointType.DEFAULT;
    private var _fillColor:uint = ColorARGB.BLACK;
    private var _strokeWidth:Number = 10.0;
    private var _strokeColor:uint = ColorARGB.BLACK;
    private var _strokePattern:StrokePattern = new StrokePattern();
    private var _points:Vector.<Coordinate>;
    private var _holes:Vector.<Vector.<Coordinate>> = new Vector.<Vector.<Coordinate>>();

    /**
     *
     * @param points
     *
     */
    public function Polygon(points:Vector.<Coordinate>) {
        super();
        this.points = points;
    }

    /**
     * Ignored on Apple Maps
     */
    public function set isTappable(value:Boolean):void {
        _isTappable = value;
        setAneValue("isTappable", value);
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

    /**
     * Indicates if the circle is visible or invisible, i.e., whether it is drawn on the map.
     * An invisible polygon is not drawn, but retains all of its other properties.
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

    /**
     * This method is omitted from the output. * * @private
     */
    private function setAneValue(name:String, value:*):void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("setPolygonProp", _id, name, value);
        if (ret is ANEError) throw ret as ANEError;
    }


    public function get strokeJointType():int {
        return _strokeJointType;
    }

    /**
     * Sets the joint type for all vertices of the polygon's outline.
     *
     * Ignored on iOS
     */
    public function set strokeJointType(value:int):void {
        _strokeJointType = value;
        setAneValue("strokeJointType", value);
    }

    public function get fillColor():uint {
        return _fillColor;
    }

    /**
     * The color in ARGB format of the polygon fill.
     */
    public function set fillColor(value:uint):void {
        _fillColor = value;
        setAneValue("fillColor", value);
    }

    public function get strokeWidth():Number {
        return _strokeWidth;
    }

    /**
     * Sets the stroke width of this polygon.
     */
    public function set strokeWidth(value:Number):void {
        _strokeWidth = value;
        setAneValue("strokeWidth", value);
    }

    public function get strokeColor():uint {
        return _strokeColor;
    }

    /**
     * Sets the stroke color of this polygon.
     */
    public function set strokeColor(value:uint):void {
        _strokeColor = value;
        setAneValue("strokeColor", value);
    }

    public function get strokePattern():StrokePattern {
        return _strokePattern;
    }

    /**
     * Sets the stroke pattern of the polygon's outline.
     *
     * Ignored on iOS
     */
    public function set strokePattern(value:StrokePattern):void {
        _strokePattern = value;
        setAneValue("strokePattern", value);
    }

    public function set points(value:Vector.<Coordinate>):void {
        _points = value;
        setAneValue("points", value);
    }

    public function get points():Vector.<Coordinate> {
        return _points;
    }

    /**
     * Adds a point to the Polygon.
     *
     */
    public function add(point:Coordinate):void {
        _points.push(point);
        setAneValue("points", _points);
    }

    public function set holes(value:Vector.<Vector.<Coordinate>>):void {
        _holes = value;
        setAneValue("holes", value);
    }

    public function get holes():Vector.<Vector.<Coordinate>> {
        return _holes;
    }

    public function addHole(hole:Vector.<Coordinate>):void {
        _holes.push(hole);
        setAneValue("holes", _holes);
    }

    public function remove():void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("removePolygon", _id);
        if (ret is ANEError) throw ret as ANEError;
        delete GoogleMapsANEContext.polygons[_id];
    }

}
}
