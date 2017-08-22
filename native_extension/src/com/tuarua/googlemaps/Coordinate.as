package com.tuarua.googlemaps {
[RemoteClass(alias="com.tuarua.googlemaps.Coordinate")]
public class Coordinate extends Object {
    public var latitude:Number;
    public var longitude:Number;

    public function Coordinate(latitude:Number, longitude:Number) {
        this.latitude = latitude;
        this.longitude = longitude;
    }
}
}
