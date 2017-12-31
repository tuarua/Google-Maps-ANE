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

public extension GMSMarker {
    convenience init?(_ freObject: FREObject?) {
       guard let rv = freObject,
        let coordinate = CLLocationCoordinate2D.init(rv["coordinate"]),
            let title = String(rv["title"]),
            let snippet = String(rv["snippet"]),
            let isDraggable = Bool(rv["isDraggable"]),
            let isFlat = Bool(rv["isFlat"]),
            let isTappable = Bool(rv["isTappable"]),
            let rotation = CLLocationDegrees(rv["rotation"]),
            let alpha = Float(rv["alpha"]),
            let color = UIColor.init(freObjectARGB: rv["color"])
            else {
                return nil
        }
        self.init(position: coordinate)
        self.tracksInfoWindowChanges = true
        self.title = title
        self.snippet = snippet
        self.isDraggable = isDraggable
        self.isFlat = isFlat
        self.isTappable = isTappable
        self.rotation = rotation
        self.opacity = alpha
        self.userData = UUID.init().uuidString
        
        if let icon = rv["icon"], let img = UIImage.init(freObject: icon) {
            self.icon = img
        } else {
            self.icon = GMSMarker.markerImage(with: color)
        }
    }
    
    func setProp(name:String, value:FREObject) {
        switch name {
        case "coordinate":
            self.position = CLLocationCoordinate2D.init(value) ?? self.position
            break
        case "title":
            self.title = String(value) ?? self.title
            break
        case "snippet":
            self.snippet = String(value) ?? self.snippet
            break
        case "isDraggable":
            self.isDraggable = Bool(value) ?? self.isDraggable
            break
        case "isFlat":
            self.isFlat = Bool(value) ?? self.isFlat
            break
        case "isTappable":
            self.isTappable = Bool(value) ?? self.isTappable
            break
        case "rotation":
            self.rotation = CLLocationDegrees(value) ?? self.rotation
            break
        case "color":
            if let color = UIColor.init(freObjectARGB: value) {
                self.icon = GMSMarker.markerImage(with: color)
            }
            break
        case "icon":
            if let img = UIImage.init(freObject: value) {
                self.icon = img
            }
            break
        case "alpha":
            self.opacity = Float(value) ?? self.opacity
            break
        default:
            break
        }
    }
}
