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

import FreSwift
import MapKit

public extension CustomMKPolygon {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject,
            let strokeWidth = CGFloat(rv["strokeWidth"]),
            let strokeColor = UIColor.init(freObjectARGB: rv["strokeColor"]),
            let fillColor = UIColor.init(freObjectARGB: rv["fillColor"])
            
            else {
                return nil
        }
        let identifier = UUID.init().uuidString
        
        var points:Array<CLLocationCoordinate2D> = []
        if let pointsFre = rv["points"] {
            let pointsArray = FREArray.init(pointsFre)
            for i in 0..<pointsArray.length {
                if let point = CLLocationCoordinate2D.init(pointsArray[i]) {
                    points.append(point)
                }
            }
        }
        
        var holes:Array<Array<CLLocationCoordinate2D>> = [[]]
        if let holesFre = rv["holes"] {
            let holesArray = FREArray.init(holesFre)
            for i in 0..<holesArray.length {
                if let freItem = holesArray[i] {
                    var holePoints:Array<CLLocationCoordinate2D> = []
                    let holePointsArray = FREArray.init(freItem)
                    for j in 0..<holePointsArray.length {
                        if let point = CLLocationCoordinate2D.init(holePointsArray[j]) {
                            holePoints.append(point)
                        }
                    }
                    if holePoints.count > 0 {
                        holes.append(holePoints)
                    }
                }
            }
        }
        
        self.init(points: points, holes: holes, identifier: identifier)
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }
    
    convenience init?(_ freObject: FREObject?, polygon:CustomMKPolygon) {
        guard let rv = freObject
            else {
                return nil
        }
        var points:Array<CLLocationCoordinate2D> = []
        let pointsArray = FREArray.init(rv)
        for i in 0..<pointsArray.length {
            if let point = CLLocationCoordinate2D.init(pointsArray[i]) {
                points.append(point)
            }
        }
        self.init(points: points, holePolygons: polygon.interiorPolygons, identifier: polygon.identifier)
        self.fillColor = polygon.fillColor
        self.strokeColor = polygon.strokeColor
        self.strokeWidth = polygon.strokeWidth
    }
    
    func setProp(name:String, value:FREObject) {
        switch name {
        case "strokeWidth":
            self.strokeWidth = CGFloat(value) ?? self.strokeWidth
            break
        case "strokeColor":
            self.strokeColor = UIColor.init(freObjectARGB: value) ?? self.strokeColor
            break
        case "fillColor":
            self.fillColor = UIColor.init(freObjectARGB: value) ?? self.fillColor
            break
        default:
            break
        }
    }
}
