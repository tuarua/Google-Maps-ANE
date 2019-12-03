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
import Foundation
import GoogleMaps
import FreSwift

public extension GMSGroundOverlay {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject
            else {
                return nil
        }
        let fre = FreObjectSwift(rv)
        self.init(bounds: fre.bounds,
                  icon: UIImage(freObject: fre.image, scale: UIScreen.main.scale, orientation: .up))
        bearing = fre.bearing
        opacity = 1.0 - fre.transparency
        isTappable = fre.isTappable
        zIndex = Int32(fre.zIndex as Int)
        userData = UUID().uuidString
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "bounds":
            bounds = GMSCoordinateBounds(value) ?? bounds
        case "bearing":
            bearing = CLLocationDirection(value) ?? bearing
        case "transparency":
            if let v = Float(value) {
                opacity = 1.0 - v
            }
        case "isTappable":
            isTappable = Bool(value) ?? isTappable
        case "zIndex":
            if let z = Int(value) {
                zIndex = Int32(z)
            }
        case "image":
            if let img = UIImage(freObject: value, scale: UIScreen.main.scale, orientation: .up) {
                icon = img
            }
        default:
            break
        }
    }
}
