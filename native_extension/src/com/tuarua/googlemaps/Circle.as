package com.tuarua.googlemaps {
[RemoteClass(alias="com.tuarua.googlemaps.Circle")]
public class Circle {
    /**
     * The center of the Circle is specified as a LatLng.
     */
    public var center:Coordinate;
    /**
     * The radius of the circle, specified in meters. It should be zero or greater.
     */
    public var radius:Number = 1.0;
    /**
     * The width of the circle's outline in screen pixels. 
	 * The width is constant and independent of the camera's zoom level. 
	 * The default value is 10.
     */
    public var strokeWidth:Number = 10.0;
    /**
     * The color of the circle outline in RGB format, the same format used by Color. 
	 * The default value is black (0xff000000).
     */
    public var strokeColor:uint = 0x000000;

    /**
     * The alpha of the circle outline.
     */
    public var strokeAlpha:Number = 1.0;

    /**
     * Ignored on Apple Maps
     */
    public var strokePattern:StrokePattern = new StrokePattern();

    /**
     * The color of the circle fill.
     */
    public var fillColor:uint = 0x000000;
    /**
     * The alpha of the circle fill.
     */
    public var fillAlpha:Number = 0.0;

    /**
     * The order in which this tile overlay is drawn with respect to other overlays 
	 * (including GroundOverlays, TileOverlays, Polylines, and Polygons but not Markers). 
	 * An overlay with a larger z-index is drawn over overlays with smaller z-indices. 
	 * The order of overlays with the same z-index is arbitrary. The default zIndex is 0.
     *
     * Ignored on Apple Maps
     *
     */
    public var zIndex:uint = 0;
    /**
     * Indicates if the circle is visible or invisible, i.e., whether it is drawn on the map. 
	 * An invisible circle is not drawn, but retains all of its other properties. 
	 * The default is true, i.e., visible.
     *
     * Ignored on Apple Maps
     *
     */
    public var visible:Boolean = true;
	/**
	 * 
	 * @param center
	 * @param radius
	 * @param strokeWidth
	 * @param strokeColor
	 * @param strokeAlpha
	 * @param strokePattern
	 * @param fillColor
	 * @param fillAlpha
	 * @param zIndex
	 * @param visible
	 * 
	 */
    public function Circle(center:Coordinate, radius:Number = 1000.0, strokeWidth:Number = 10.0,
                           strokeColor:uint = 0x000000, strokeAlpha:Number = 1.0, strokePattern:StrokePattern = null, fillColor:uint = 0x000000,
                           fillAlpha:Number = 0.0, zIndex:uint = 0, visible:Boolean = true) {
        this.center = center;
        this.radius = radius;
        this.strokeWidth = strokeWidth;
        this.strokeColor = strokeColor;
        this.strokeAlpha = strokeAlpha;
        this.strokePattern = strokePattern;
        this.fillColor = fillColor;
        this.fillAlpha = fillAlpha;
        this.zIndex = zIndex;
        this.visible = visible;
    }
}
}