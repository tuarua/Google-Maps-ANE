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

    public function set clickable(value:Boolean):void {
        _clickable = value;
        setAneValue("clickable", value);
    }

    public function get geodesic():Boolean {
        return _geodesic;
    }

    public function set geodesic(value:Boolean):void {
        _geodesic = value;
        setAneValue("geodesic", value);
    }

    public function set visible(value:Boolean):void {
        _visible = value;
        setAneValue("visible", value);
    }

    public function set zIndex(value:Number):void {
        _zIndex = value;
        setAneValue("zIndex", value);
    }

    private function setAneValue(name:String, value:*):void {
        if (_isAdded) {
            var theRet:* = GoogleMapsANEContext.context.call("setPolygonProp", _id, name, value);
            if (theRet is ANEError) throw theRet as ANEError;
        }
    }

    public function get strokeJointType():int {
        return _strokeJointType;
    }

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

    public function set strokeWidth(value:Number):void {
        _strokeWidth = value;
        setAneValue("strokeWidth", value);
    }

    public function get strokeColor():uint {
        return _strokeColor;
    }

    public function set strokeColor(value:uint):void {
        _strokeColor = value;
        setAneValue("strokeColor", value);
    }

    public function get strokePattern():StrokePattern {
        return _strokePattern;
    }

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
        if (_isAdded) {
            var theRet:* = GoogleMapsANEContext.context.call("removePolygon", _id);
            if (theRet is ANEError) throw theRet as ANEError;
            delete GoogleMapsANEContext.polygons[_id];
        }
    }

}
}
