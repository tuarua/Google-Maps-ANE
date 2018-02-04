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

import GoogleMaps
import FreSwift
import MapKit

public extension GMSCircle {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject,
        let center = CLLocationCoordinate2D(rv["center"]),
        let radius = Double(rv["radius"]),
        let isTappable = Bool(rv["isTappable"]),
        let zIndex = Int(rv["zIndex"]),
        let strokeWidth = CGFloat(rv["strokeWidth"]),
        let strokeColor = UIColor(freObjectARGB: rv["strokeColor"]),
        let fillColor = UIColor(freObjectARGB: rv["fillColor"])
        else {
            return nil
        }
        self.init(position: center, radius: radius)
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.zIndex = Int32(zIndex)
        self.isTappable = isTappable
        self.userData = UUID().uuidString
        
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "center":
            self.position = CLLocationCoordinate2D.init(value) ?? self.position
        case "strokeWidth":
            self.strokeWidth = CGFloat(value) ?? self.strokeWidth
        case "radius":
            self.radius = Double(value) ?? self.radius
        case "isTappable":
            self.isTappable = Bool(value) ?? self.isTappable
        case "zIndex":
            if let z = Int(value) {
                self.zIndex = Int32(z)
            }
        case "strokeColor":
            self.strokeColor = UIColor(freObjectARGB: value) ?? self.strokeColor
        case "fillColor":
            self.fillColor = UIColor(freObjectARGB: value) ?? self.fillColor
        default:
            break
        }
    }
}
