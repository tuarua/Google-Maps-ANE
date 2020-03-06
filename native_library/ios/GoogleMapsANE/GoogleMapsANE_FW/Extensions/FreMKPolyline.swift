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
        guard let rv = freObject else {
            return nil
        }
        let fre = FreObjectSwift(rv)
        self.init(points: fre.points, identifier: UUID().uuidString)
        color = fre.color
        width = fre.width
    }
    
    convenience init?(_ freObject: FREObject?, polyline: CustomMKPolyline) {
        guard let rv = freObject else {
            return nil
        }
        let fre = FreObjectSwift(rv)
        self.init(points: fre.points, identifier: polyline.identifier)
        color = polyline.color
        width = polyline.width
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "width":
            width = CGFloat(value) ?? width
        case "color":
            color = UIColor(value) ?? color
        default:
            break
        }
    }
}
