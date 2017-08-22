package com.tuarua.googlemaps {
import flash.display.BitmapData;

[RemoteClass(alias="com.tuarua.googlemaps.Marker")]
public class Marker {
    public var coordinate:Coordinate = new Coordinate(0, 0);
    public var title:String = "";
    public var color:uint = Color.RED;
    public var snippet:String = "";
    public var isDraggable:Boolean = false;
    public var isFlat:Boolean = false;
    public var isTappable:Boolean = true;
    public var opacity:Number = 1.0;
    public var rotation:int = 0;
    public var icon:BitmapData;

    public function Marker(coordinate:Coordinate, title:String = null, snippet:String = null, color:uint = Color.RED,
                           icon:BitmapData = null, isDraggable:Boolean = false, isFlat:Boolean = false,
                           isTappable:Boolean = true, rotation:int = 0, opacity:Number = 1.0) {
        this.coordinate = coordinate;
        this.title = title ? title : "";
        this.snippet = snippet ? snippet : "";
        this.isDraggable = isDraggable;
        this.isFlat = isFlat;
        this.isTappable = isTappable;
        this.color = color;
        this.opacity = opacity;
        this.rotation = rotation;
        this.icon = icon;
    }



}
}
