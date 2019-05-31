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
[RemoteClass(alias="com.tuarua.googlemaps.VisibleRegion")]
public class VisibleRegion {
    private var _nearLeft:Coordinate;
    private var _nearRight:Coordinate;
    private var _farLeft:Coordinate;
    private var _farRight:Coordinate;

    public function VisibleRegion(nearLeft:Coordinate, nearRight:Coordinate, farLeft:Coordinate, farRight:Coordinate) {
        this._nearLeft = nearLeft;
        this._nearRight = nearRight;
        this._farLeft = farLeft;
        this._farRight = farRight;
    }

    public function get nearLeft():Coordinate {
        return _nearLeft;
    }

    public function get nearRight():Coordinate {
        return _nearRight;
    }

    public function get farLeft():Coordinate {
        return _farLeft;
    }

    public function get farRight():Coordinate {
        return _farRight;
    }

    public function toString():String {
        return "(nearLeft=" + _nearLeft + ", nearRight=" + _nearRight + ", farLeft=" + _farLeft + ", farRight=" + _farRight + ")";
    }
}
}
