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

public extension GMSMarker {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject else {
            return nil
        }
        let fre = FreObjectSwift(rv)
        self.init(position: fre.coordinate)
        self.tracksInfoWindowChanges = true
        self.title = fre.title
        self.snippet = fre.snippet
        self.isDraggable = fre.isDraggable
        self.isFlat = fre.isFlat
        self.isTappable = fre.isTappable
        self.rotation = fre.rotation
        self.opacity = fre.alpha
        self.userData = UUID().uuidString
        
        if let img = UIImage(freObject: fre.icon, scale: UIScreen.main.scale, orientation: .up) {
            self.icon = img
        } else {
            self.icon = GMSMarker.markerImage(with: fre.color)
        }
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "coordinate":
            self.position = CLLocationCoordinate2D(value) ?? self.position
        case "title":
            self.title = String(value) ?? self.title
        case "snippet":
            self.snippet = String(value) ?? self.snippet
        case "isDraggable":
            self.isDraggable = Bool(value) ?? self.isDraggable
        case "isFlat":
            self.isFlat = Bool(value) ?? self.isFlat
        case "isTappable":
            self.isTappable = Bool(value) ?? self.isTappable
        case "rotation":
            self.rotation = CLLocationDegrees(value) ?? self.rotation
        case "color":
            if let color = UIColor(value) {
                self.icon = GMSMarker.markerImage(with: color)
            }
        case "icon":
            if let img = UIImage(freObject: value, scale: UIScreen.main.scale, orientation: .up) {
                self.icon = img
            }
        case "alpha":
            self.opacity = Float(value) ?? self.opacity
        default:
            break
        }
    }
}
