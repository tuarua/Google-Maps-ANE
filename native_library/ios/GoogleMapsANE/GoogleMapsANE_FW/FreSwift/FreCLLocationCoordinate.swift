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

public extension CLLocationCoordinate2D {
    init?(_ freObject: FREObject?) {
        guard let rv = freObject,
        let lat = CLLocationDegrees(rv["latitude"]),
        let lng = CLLocationDegrees(rv["longitude"])
        else {
            return nil
        }
        self.init(latitude: lat, longitude: lng)
    }
    func toFREObject() -> FREObject? {
        return FREObject(className: "com.tuarua.googlemaps.Coordinate",
                                                       args: CGFloat(latitude), CGFloat(longitude))
    }
}
