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

extension CustomMKPolyline {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject,
            let width = CGFloat(rv["width"]),
            let color = UIColor(rv["color"])
            else {
                return nil
        }
        let identifier = UUID().uuidString
        var points: [CLLocationCoordinate2D] = []
        if let pointsFre = rv["points"] {
            let pointsArray = FREArray(pointsFre)
            for frePoint in pointsArray {
                if let point = CLLocationCoordinate2D(frePoint) {
                    points.append(point)
                }
            }
        }
        self.init(points: points, identifier: identifier)
        self.color = color
        self.width = width
    }
    
    convenience init?(_ freObject: FREObject?, polyline: CustomMKPolyline) {
        guard let rv = freObject
            else {
                return nil
        }
        var points: [CLLocationCoordinate2D] = []
        let pointsArray = FREArray(rv)
        for frePoint in pointsArray {
            if let point = CLLocationCoordinate2D(frePoint) {
                points.append(point)
            }
        }
        self.init(points: points, identifier: polyline.identifier)
        self.color = polyline.color
        self.width = polyline.width
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "width":
            self.width = CGFloat(value) ?? self.width
        case "color":
            self.color = UIColor(value) ?? self.color
        default:
            break
        }
    }
}
