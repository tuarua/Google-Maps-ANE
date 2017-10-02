package com.tuarua.googlemaps.permissions {
import com.tuarua.location.*;

import flash.events.Event;

public class PermissionEvent extends Event {
    public static const ON_PERMISSION_STATUS:String = "Permission.OnStatus";
    public var params:*;

    public function PermissionEvent(type:String, params:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.params = params;
    }

    public override function clone():Event {
        return new PermissionEvent(type, this.params, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("PermissionEvent", "params", "type", "bubbles", "cancelable");
    }
}
}
