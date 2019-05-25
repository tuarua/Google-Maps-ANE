/*
 *  Copyright 2017 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.tuarua.location {
import com.tuarua.googlemaps.Coordinate;

import flash.events.Event;

public class LocationEvent extends Event {
    public static const LOCATION_UPDATED:String = "Location.LocationUpdated";
    public static const ON_ADDRESS_LOOKUP:String = "Location.OnAddressLookup";
    public static const ON_ADDRESS_LOOKUP_ERROR:String = "Location.OnAddressLookupError";
    public var coordinate:Coordinate;
    public var address:Address;
    public var error:String;

    public function LocationEvent(type:String, coordinate:Coordinate = null, address:Address = null,
                                  error:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.coordinate = coordinate;
        this.address = address;
        this.error = error;
    }

    public override function clone():Event {
        return new LocationEvent(type, this.coordinate, this.address, this.error, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("LocationEvent", "coordinate", "address", "error", "type", "bubbles", "cancelable");
    }
}
}
