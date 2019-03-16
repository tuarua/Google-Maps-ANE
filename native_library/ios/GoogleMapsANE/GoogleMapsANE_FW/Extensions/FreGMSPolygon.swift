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
        self.geodesic = fre.geodesic
        self.strokeWidth = fre.strokeWidth
        self.strokeColor = fre.strokeColor
        self.fillColor = fre.fillColor
        self.zIndex = Int32(fre.zIndex as Int)
        self.userData = UUID().uuidString
        self.isTappable = fre.isTappable
        self.path = GMSMutablePath(rv["points"]) ?? GMSMutablePath()
        self.holes = fre.holes
        
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "geodesic":
            self.geodesic = Bool(value) ?? self.geodesic
        case "strokeWidth":
            self.strokeWidth = CGFloat(value) ?? self.strokeWidth
        case "isTappable":
            self.isTappable = Bool(value) ?? self.isTappable
        case "zIndex":
            if let z = Int(value) {
                self.zIndex = Int32(z)
            }
        case "strokeColor":
            self.strokeColor = UIColor(value) ?? self.strokeColor
        case "fillColor":
            self.fillColor = UIColor(value) ?? self.fillColor
        case "points":
            if let points = GMSMutablePath(value) {
                self.path = points
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
