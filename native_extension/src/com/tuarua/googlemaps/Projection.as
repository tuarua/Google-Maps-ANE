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
package com.tuarua.googlemaps {
import com.tuarua.GoogleMapsANEContext;
import com.tuarua.fre.ANEError;

import flash.geom.Point;

public class Projection {
    public function Projection() {
    }

    /** Maps an Earth coordinate to a point coordinate in the map's view. */
    public function pointForCoordinate(coordinate:Coordinate):Point {
        var ret:* = GoogleMapsANEContext.context.call("projection_pointForCoordinate", coordinate);
        if (ret is ANEError) throw ret as ANEError;
        return ret as Point;
    }

    /** Maps a point coordinate in the map's view to an Earth coordinate. */
    public function coordinateForPoint(point:Point):Coordinate {
        var ret:* = GoogleMapsANEContext.context.call("projection_coordinateForPoint", point);
        if (ret is ANEError) throw ret as ANEError;
        return ret as Coordinate;
    }

    /** Converts a distance in meters to content size. iOS only.*/
    public function pointsForMeters(forMeters:Number, at:Coordinate):Number {
        var ret:* = GoogleMapsANEContext.context.call("projection_pointsForMeters", forMeters, at);
        if (ret is ANEError) throw ret as ANEError;
        return ret as Number;
    }

    /** Returns whether a given coordinate (lat/lng) is contained within the projection. iOS only.*/
    public function containsCoordinate(coordinate:Coordinate):Boolean {
        var ret:* = GoogleMapsANEContext.context.call("projection_containsCoordinate", coordinate);
        if (ret is ANEError) throw ret as ANEError;
        return ret as Boolean;
    }

    /** Returns the region (four location coordinates) that is visible according to the projection. */
    public function get visibleRegion():VisibleRegion {
        var ret:* = GoogleMapsANEContext.context.call("projection_visibleRegion");
        if (ret is ANEError) throw ret as ANEError;
        return ret as VisibleRegion;
    }

}
}