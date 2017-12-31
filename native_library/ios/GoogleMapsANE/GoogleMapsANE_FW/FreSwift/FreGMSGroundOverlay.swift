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
import Foundation
import GoogleMaps
import FreSwift

public extension GMSGroundOverlay {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject,
            let coordinate = CLLocationCoordinate2D.init(rv["coordinate"]),
            let zIndex = Int(rv["zIndex"]),
            let img = UIImage.init(freObject: rv["image"]),
            let transparency = Float(rv["transparency"]),
            let isTappable = Bool(rv["isTappable"]),
            let bearing = Double(rv["bearing"])
            else {
                return nil
        }
        self.init(position: coordinate, icon: img, zoomLevel: CGFloat.init(1))
        self.bearing = bearing
        self.opacity = 1.0 - transparency
        self.isTappable = isTappable
        self.zIndex = Int32(zIndex)
        self.userData = UUID.init().uuidString
    }
}
