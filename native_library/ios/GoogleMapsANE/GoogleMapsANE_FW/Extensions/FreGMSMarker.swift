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
        tracksInfoWindowChanges = true
        title = fre.title
        snippet = fre.snippet
        isDraggable = fre.isDraggable
        isFlat = fre.isFlat
        isTappable = fre.isTappable
        rotation = fre.rotation
        opacity = fre.alpha
        userData = UUID().uuidString
        
        if let img = UIImage(freObject: fre.icon, scale: UIScreen.main.scale, orientation: .up) {
            icon = img
        } else {
            icon = GMSMarker.markerImage(with: fre.color)
        }
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "coordinate":
            position = CLLocationCoordinate2D(value) ?? position
        case "title":
            title = String(value) ?? title
        case "snippet":
            snippet = String(value) ?? snippet
        case "isDraggable":
            isDraggable = Bool(value) ?? isDraggable
        case "isFlat":
            isFlat = Bool(value) ?? isFlat
        case "isTappable":
            isTappable = Bool(value) ?? isTappable
        case "rotation":
            rotation = CLLocationDegrees(value) ?? rotation
        case "color":
            if let color = UIColor(value) {
                icon = GMSMarker.markerImage(with: color)
            }
        case "icon":
            if let img = UIImage(freObject: value, scale: UIScreen.main.scale, orientation: .up) {
                icon = img
            }
        case "alpha":
            opacity = Float(value) ?? opacity
        default:
            break
        }
    }
}
