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
        guard let rv = freObject else {
            return nil
        }
        let fre = FreObjectSwift(rv)
        
        self.init(position: fre.center, radius: fre.radius)
        strokeWidth = fre.strokeWidth
        strokeColor = fre.strokeColor
        fillColor = fre.fillColor
        zIndex = Int32(fre.zIndex as Int)
        isTappable = fre.isTappable
        userData = UUID().uuidString
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "center":
            position = CLLocationCoordinate2D(value) ?? position
        case "strokeWidth":
            strokeWidth = CGFloat(value) ?? strokeWidth
        case "radius":
            radius = Double(value) ?? radius
        case "isTappable":
            isTappable = Bool(value) ?? isTappable
        case "zIndex":
            if let z = Int(value) {
                zIndex = Int32(z)
            }
        case "strokeColor":
            strokeColor = UIColor(value) ?? strokeColor
        case "fillColor":
            fillColor = UIColor(value) ?? fillColor
        default:
            break
        }
    }
}
