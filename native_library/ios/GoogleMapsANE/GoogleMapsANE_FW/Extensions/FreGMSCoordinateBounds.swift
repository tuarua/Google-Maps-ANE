/*
 *  Copyright 2018 Tua Rua Ltd.
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

import Foundation
import GoogleMaps
import FreSwift

public extension GMSCoordinateBounds {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject,
            let northEast = CLLocationCoordinate2D(rv["northEast"]),
            let southWest = CLLocationCoordinate2D(rv["southWest"])
            else {
                return nil
        }
        self.init(coordinate: southWest, coordinate: northEast)
    }
    func toFREObject() -> FREObject? {
        return FREObject(className: "com.tuarua.googlemaps.CoordinateBounds",
                         args: southWest.toFREObject(), northEast.toFREObject())
    }
}

public extension FreObjectSwift {
    public subscript(dynamicMember name: String) -> GMSCoordinateBounds? {
        get { return GMSCoordinateBounds(rawValue?[name]) }
        set { rawValue?[name] = newValue?.toFREObject() }
    }
    public subscript(dynamicMember name: String) -> GMSCoordinateBounds {
        get { return GMSCoordinateBounds(rawValue?[name]) ?? GMSCoordinateBounds() }
        set { rawValue?[name] = newValue.toFREObject() }
    }
}
