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
        guard let rv = freObject,
            let geodesic = Bool(rv["geodesic"]),
            let zIndex = Int(rv["zIndex"]),
            let isTappable = Bool(rv["isTappable"]),
            let strokeWidth = CGFloat(rv["strokeWidth"]),
            let strokeColor = UIColor(freObjectARGB: rv["strokeColor"]),
            let fillColor = UIColor(freObjectARGB: rv["fillColor"])
            else {
                return nil
        }
        self.init()
        self.geodesic = geodesic
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.zIndex = Int32(zIndex)
        self.userData = UUID().uuidString
        self.isTappable = isTappable
        
        let points = GMSMutablePath()
        if let pointsFre = rv["points"] {
            let pointsArray = FREArray(pointsFre)
            for i in 0..<pointsArray.length {
                if let point = CLLocationCoordinate2D(pointsArray[i]) {
                    points.add(point)
                }
            }
        }
        self.path = points
        
        var holes: [GMSMutablePath] = []
        if let holesFre = rv["holes"] {
            let holesArray = FREArray(holesFre)
            for i in 0..<holesArray.length {
                if let freItem = holesArray[i] {
                    let holePoints = GMSMutablePath()
                    let holePointsArray = FREArray(freItem)
                    for j in 0..<holePointsArray.length {
                        if let point = CLLocationCoordinate2D(holePointsArray[j]) {
                            holePoints.add(point)
                        }
                    }
                    if holePoints.count() > 0 {
                        holes.append(holePoints)
                    } 
                }
            }
        } 
        self.holes = holes
        
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
            self.strokeColor = UIColor(freObjectARGB: value) ?? self.strokeColor
        case "fillColor":
            self.fillColor = UIColor(freObjectARGB: value) ?? self.fillColor
        case "points":
            let points = GMSMutablePath()
            let pointsArray = FREArray(value)
            for i in 0..<pointsArray.length {
                if let point = CLLocationCoordinate2D(pointsArray[i]) {
                    points.add(point)
                }
            }
            self.path = points
        case "holes":
            var holes: [GMSMutablePath] = []
            let holesArray = FREArray(value)
            for i in 0..<holesArray.length {
                if let freItem = holesArray[i] {
                    let holePoints = GMSMutablePath()
                    let holePointsArray = FREArray(freItem)
                    for j in 0..<holePointsArray.length {
                        if let point = CLLocationCoordinate2D(holePointsArray[j]) {
                            holePoints.add(point)
                        }
                    }
                    if holePoints.count() > 0 {
                        holes.append(holePoints)
                    }
                }
            }
            self.holes = holes
        default:
            break
        }
    }
}
