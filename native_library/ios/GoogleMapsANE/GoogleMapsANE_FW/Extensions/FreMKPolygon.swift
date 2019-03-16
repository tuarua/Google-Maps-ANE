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

import FreSwift
import MapKit

extension CustomMKPolygon {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject else {
            return nil
        }
        let fre = FreObjectSwift(rv)
        let identifier = UUID().uuidString
        
        var holes: [[CLLocationCoordinate2D]] = [[]]
        if let holesFre = rv["holes"] {
            let holesArray = FREArray(holesFre)
            for freItem in holesArray {
                let holePoints = [CLLocationCoordinate2D](freItem) ?? []
                if holePoints.count > 0 {
                    holes.append(holePoints)
                }
            }
        }
        
        self.init(points: fre.points, holes: holes, identifier: identifier)
        self.fillColor = fre.fillColor
        self.strokeColor = fre.strokeColor
        self.strokeWidth = fre.strokeWidth
    }
    
    convenience init?(_ freObject: FREObject?, polygon: CustomMKPolygon) {
        guard let rv = freObject else {
            return nil
        }
        let fre = FreObjectSwift(rv)
        self.init(points: fre.points, holePolygons: polygon.interiorPolygons, identifier: polygon.identifier)
        self.fillColor = polygon.fillColor
        self.strokeColor = polygon.strokeColor
        self.strokeWidth = polygon.strokeWidth
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "strokeWidth":
            self.strokeWidth = CGFloat(value) ?? self.strokeWidth
        case "strokeColor":
            self.strokeColor = UIColor(value) ?? self.strokeColor
        case "fillColor":
            self.fillColor = UIColor(value) ?? self.fillColor
        default:
            break
        }
    }
}
