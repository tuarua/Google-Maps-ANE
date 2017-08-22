package com.tuarua.location {

import flash.events.Event;

public class LocationEvent extends Event {
    public static const LOCATION_UPDATED:String = "Location.LocationUpdated";
    public static const AUTHORIZATION_STATUS:String = "Location.AuthorizationStatus";
    public var params:*;

    public function LocationEvent(type:String, params:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.params = params;
    }

    public override function clone():Event {
        return new LocationEvent(type, this.params, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("LocationEvent", "params", "type", "bubbles", "cancelable");
    }
}
}
