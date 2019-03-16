package com.tuarua.googlemaps {
import com.tuarua.GoogleMapsANEContext;
import com.tuarua.fre.ANEError;

import flash.display.BitmapData;

[RemoteClass(alias="com.tuarua.googlemaps.Marker")]
public class Marker {
    private var _isAdded:Boolean = false;
    private var _id:String;
    private var _coordinate:Coordinate = new Coordinate(0, 0);
    private var _title:String = "";
    private var _color:uint = ColorARGB.RED;
    private var _snippet:String = "";
    private var _isDraggable:Boolean = false;
    private var _isFlat:Boolean = false;
    private var _isTappable:Boolean = true;
    private var _alpha:Number = 1.0;
    private var _rotation:int = 0;
    private var _icon:BitmapData;

    /**
     *
     * @param coordinate
     * @param title
     * @param snippet
     * @param color ARGB format
     * @param icon
     * @param isDraggable
     * @param isFlat Ignored when using Apple Maps
     * @param isTappable Ignored on Android
     * @param rotation Ignored when using Apple Maps
     * @param alpha
     *
     */
    public function Marker(coordinate:Coordinate, title:String = null, snippet:String = null, color:uint = ColorARGB.RED,
                           icon:BitmapData = null, isDraggable:Boolean = false, isFlat:Boolean = false,
                           isTappable:Boolean = true, rotation:int = 0, alpha:Number = 1.0) {
        this._coordinate = coordinate;
        this._title = title ? title : "";
        this._snippet = snippet ? snippet : "";
        this._isDraggable = isDraggable;
        this._isFlat = isFlat;
        this._isTappable = isTappable;
        this._color = color;
        this._alpha = alpha;
        this._rotation = rotation;
        this._icon = icon;
    }

    public function remove():void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("removeMarker", _id);
        if (ret is ANEError) throw ret as ANEError;
        delete GoogleMapsANEContext.markers[_id];
    }

    public function get id():String {
        return _id;
    }

    public function set id(value:String):void {
        _id = value;
    }

    public function get coordinate():Coordinate {
        return _coordinate;
    }

    public function set coordinate(value:Coordinate):void {
        _coordinate = value;
        setAneValue("coordinate", value);
    }

    public function get title():String {
        return _title;
    }

    public function set title(value:String):void {
        _title = value;
        setAneValue("title", value);
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

    public function get snippet():String {
        return _snippet;
    }

    public function set snippet(value:String):void {
        _snippet = value;
        setAneValue("snippet", value);
    }

    public function get isDraggable():Boolean {
        return _isDraggable;
    }

    public function set isDraggable(value:Boolean):void {
        _isDraggable = value;
        setAneValue("isDraggable", value);
    }

    public function get isFlat():Boolean {
        return _isFlat;
    }

    /**
     * Ignored when using Apple Maps
     */
    public function set isFlat(value:Boolean):void {
        _isFlat = value;
        setAneValue("isFlat", value);
    }

    public function get isTappable():Boolean {
        return _isTappable;
    }

    public function set isTappable(value:Boolean):void {
        _isTappable = value;
        setAneValue("isTappable", value);
    }

    public function get alpha():Number {
        return _alpha;
    }

    public function set alpha(value:Number):void {
        _alpha = value;
        setAneValue("alpha", value);
    }

    public function get rotation():int {
        return _rotation;
    }

    /**
     * Ignored when using Apple Maps
     */
    public function set rotation(value:int):void {
        _rotation = value;
        setAneValue("rotation", value);
    }

    public function get icon():BitmapData {
        return _icon;
    }

    public function set icon(value:BitmapData):void {
        _icon = value;
        setAneValue("icon", value);
    }

    private function setAneValue(name:String, value:*):void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("setMarkerProp", _id, name, value);
        if (ret is ANEError) throw ret as ANEError;
    }

    public function set isAdded(value:Boolean):void {
        _isAdded = value;
    }
}
}
