package com.tuarua.googlemaps {
import com.tuarua.GoogleMapsANEContext;
import com.tuarua.fre.ANEError;

[RemoteClass(alias="com.tuarua.googlemaps.Circle")]
public class Circle extends Shape {
    private var _center:Coordinate;
    private var _radius:Number = 1.0;
    private var _strokeWidth:Number = 10.0;
    private var _strokeColor:uint = ColorARGB.BLACK;
    private var _strokePattern:StrokePattern = new StrokePattern();
    private var _fillColor:uint = ColorARGB.BLACK;

    /**
     *
     * @param center
     * @param radius
     * @param isTappable
     * @param strokeWidth
     * @param strokeColor
     * @param strokePattern
     * @param fillColor
     * @param zIndex
     * @param visible
     *
     */
    public function Circle(center:Coordinate, radius:Number = 1000.0, isTappable:Boolean = false, strokeWidth:Number = 10.0,
                           strokeColor:uint = ColorARGB.BLACK, strokePattern:StrokePattern = null,
                           fillColor:uint = ColorARGB.BLACK, zIndex:uint = 0, visible:Boolean = true) {
        _center = center;
        _radius = radius;
        _isTappable = isTappable;
        _strokeWidth = strokeWidth;
        _strokeColor = strokeColor;
        _strokePattern = strokePattern;
        _fillColor = fillColor;
        _zIndex = zIndex;
        _visible = visible;
    }

    /**
     * Ignored on Apple Maps
     */
    public function set isTappable(value:Boolean):void {
        _isTappable = value;
        setAneValue("isTappable", value);
    }

    public function get center():Coordinate {
        return _center;
    }

    /**
     * The center of the Circle is specified as a LatLng.
     */
    public function set center(value:Coordinate):void {
        _center = value;
        setAneValue("center", value);
    }

    public function get radius():Number {
        return _radius;
    }

    /**
     * The radius of the circle, specified in meters. It should be zero or greater.
     */
    public function set radius(value:Number):void {
        _radius = value;
        setAneValue("radius", value);
    }

    public function get strokeWidth():Number {
        return _strokeWidth;
    }

    /**
     * The width of the circle's outline in screen pixels.
     * The width is constant and independent of the camera's zoom level.
     * The default value is 10.
     */
    public function set strokeWidth(value:Number):void {
        _strokeWidth = value;
        setAneValue("strokeWidth", value);
    }

    public function get strokeColor():uint {
        return _strokeColor;
    }

    /**
     * The color of the circle outline in ARGB format, the same format used by Color.
     * The default value is black (0xff000000).
     */
    public function set strokeColor(value:uint):void {
        _strokeColor = value;
        setAneValue("strokeColor", value);
    }

    public function get strokePattern():StrokePattern {
        return _strokePattern;
    }

    /**
     * Ignored on iOS
     */
    public function set strokePattern(value:StrokePattern):void {
        _strokePattern = value;
        setAneValue("strokePattern", value);
    }

    public function get fillColor():uint {
        return _fillColor;
    }

    /**
     * The color in ARGB format of the circle fill.
     */
    public function set fillColor(value:uint):void {
        _fillColor = value;
        setAneValue("fillColor", value);
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
     * Indicates if the circle is visible or invisible, i.e., whether it is drawn on the map.
     * An invisible circle is not drawn, but retains all of its other properties.
     * The default is true, i.e., visible.
     *
     * Ignored on iOS
     *
     */
    public function set visible(value:Boolean):void {
        _visible = value;
        setAneValue("visible", value);
    }

    public function remove():void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("removeCircle", _id);
        if (ret is ANEError) throw ret as ANEError;
        delete GoogleMapsANEContext.circles[_id];
    }

    /**
     * This method is omitted from the output. * * @private
     */
    private function setAneValue(name:String, value:*):void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("setCircleProp", _id, name, value);
        if (ret is ANEError) throw ret as ANEError;
    }

}
}