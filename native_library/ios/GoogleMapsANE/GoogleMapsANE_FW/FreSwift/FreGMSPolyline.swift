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

public extension GMSPolyline {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject,
            let geodesic = Bool(rv["geodesic"]),
            let zIndex = Int(rv["zIndex"]),
            let isTappable = Bool(rv["isTappable"]),
            let strokeWidth = CGFloat(rv["width"]),
            let strokeColor = UIColor(rv["color"])
            else {
                return nil
        }
        self.init()
        self.geodesic = geodesic
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.zIndex = Int32(zIndex)
        self.isTappable = isTappable
        self.userData = UUID().uuidString
        
        let points = GMSMutablePath()
        if let pointsFre = rv["points"] {
            let pointsArray = FREArray(pointsFre)
            for frePoint in pointsArray {
                if let point = CLLocationCoordinate2D(frePoint) {
                    points.add(point)
                } 
            }
        }
        self.path = points
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "geodesic":
            self.geodesic = Bool(value) ?? self.geodesic
        case "width":
            self.strokeWidth = CGFloat(value) ?? self.strokeWidth
        case "isTappable":
            self.isTappable = Bool(value) ?? self.isTappable
        case "zIndex":
            if let z = Int(value) {
                self.zIndex = Int32(z)
            }
        case "color":
            self.strokeColor = UIColor(value) ?? self.strokeColor
        case "points":
            let points = GMSMutablePath()
            let pointsArray = FREArray(value)
            for frePoint in pointsArray {
                if let point = CLLocationCoordinate2D(frePoint) {
                    points.add(point)
                }
            }
            self.path = points
        default:
            break
        }
    }
}
