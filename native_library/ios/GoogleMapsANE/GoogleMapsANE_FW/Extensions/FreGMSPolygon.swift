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

public extension GMSPolygon {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject else {
                return nil
        }
        let fre = FreObjectSwift(rv)
        self.init()
        geodesic = fre.geodesic
        strokeWidth = fre.strokeWidth
        strokeColor = fre.strokeColor
        fillColor = fre.fillColor
        zIndex = Int32(fre.zIndex as Int)
        userData = UUID().uuidString
        isTappable = fre.isTappable
        path = GMSMutablePath(rv["points"]) ?? GMSMutablePath()
        holes = fre.holes
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "geodesic":
            geodesic = Bool(value) ?? geodesic
        case "strokeWidth":
            strokeWidth = CGFloat(value) ?? strokeWidth
        case "isTappable":
            isTappable = Bool(value) ?? isTappable
        case "zIndex":
            if let z = Int(value) {
                self.zIndex = Int32(z)
            }
        case "strokeColor":
            strokeColor = UIColor(value) ?? strokeColor
        case "fillColor":
            fillColor = UIColor(value) ?? fillColor
        case "points":
            if let points = GMSMutablePath(value) {
                path = points
            }
        case "holes":
            if let holes = [GMSMutablePath](value) {
                self.holes = holes
            }
        default:
            break
        }
    }
}
