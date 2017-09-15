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

import Foundation
import GoogleMaps
import FreSwift


class FreCoordinateSwift: FreObjectSwift {
    override public init(freObject: FREObject?) {
        super.init(freObject: freObject)
    }
    
    override public init(freObjectSwift: FreObjectSwift?) {
        super.init(freObjectSwift: freObjectSwift)
    }
    
    public init(value: CLLocationCoordinate2D) {
        var freObject: FREObject? = nil
        do {
            freObject = try FREObject.init(className: "fcom.tuarua.googlemaps.Coordinate",
                                           args: CGFloat.init(value.latitude), CGFloat.init(value.longitude))
        } catch {
        }
        
        super.init(freObject: freObject)
    }
    
    override public var value: Any? {
        get {
            do {
                if let raw = rawValue {
                    let idRes = try getAsCLLocationCoordinate2D(raw) as Any?
                    return idRes
                }
            } catch {
            }
            return nil
        }
    }
    
    private func getAsCLLocationCoordinate2D(_ rawValue: FREObject) throws -> CLLocationCoordinate2D {
        var ret: CLLocationCoordinate2D = CLLocationCoordinate2D.init()
        if let lat = try CLLocationDegrees.init(rawValue.getProp(name: "latitude")),
            let lng = try CLLocationDegrees.init(rawValue.getProp(name: "longitude"))
        {
            ret = CLLocationCoordinate2D.init(latitude: lat, longitude: lng)
        }
        
        return ret
    }
    
}

public extension CLLocationCoordinate2D {
    init?(_ freObject: FREObject?) {
        guard let rv = freObject else {
            return nil
        }
        if let coo = FreCoordinateSwift.init(freObject: rv).value as? CLLocationCoordinate2D {
            self.init(latitude: coo.latitude, longitude: coo.longitude)
        } else {
            return nil
        }
    }
}

