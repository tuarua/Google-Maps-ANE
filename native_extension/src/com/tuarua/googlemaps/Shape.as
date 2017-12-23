package com.tuarua.googlemaps {
public class Shape {
    protected var _visible:Boolean = true;
    protected var _isAdded:Boolean = false;
    protected var _id:String;
    protected var _clickable:Boolean = false;
    protected var _zIndex:Number = 0;
    public function Shape() {
    }

    public function get id():String {
        return _id;
    }

    public function set id(value:String):void {
        _id = value;
    }

    public function get zIndex():Number {
        return _zIndex;
    }

    public function get visible():Boolean {
        return _visible;
    }

    public function get clickable():Boolean {
        return _clickable;
    }

    public function set isAdded(value:Boolean):void {
        _isAdded = value;
    }
}
}
