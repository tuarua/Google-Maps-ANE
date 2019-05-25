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
public class CameraPosition {
    /**
     *
     */
    public var centerAt:Coordinate = null;
    /**
     * ignored on Apple Maps
     */
    public var zoom:Number = -9999;
    /**
     *
     */
    public var tilt:Number = -9999;
    /**
     * aka heading
     */
    public var bearing:Number = -9999;

    /**
     * This method is omitted from the output. * * @private
     */
    public function CameraPosition() {
    }

}
}
