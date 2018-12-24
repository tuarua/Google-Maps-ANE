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
import Foundation
import MapKit
import UIKit

class CustomMKAnnotation: NSObject, MKAnnotation {
    var identifier: String = UUID().uuidString
    var color: UIColor?
    var icon: UIImage?
    var userData: Any?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
    var isDraggable: Bool = false
    var isTappable: Bool = false
    var opacity: CGFloat = 1.0

    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject,
            let coordinate = CLLocationCoordinate2D(rv["coordinate"]),
            let title = String(rv["title"]),
            let snippet = String(rv["snippet"]),
            let isDraggable = Bool(rv["isDraggable"]),
            let isTappable = Bool(rv["isTappable"]),
            let alpha = CGFloat(rv["alpha"]),
            let color = UIColor(rv["color"])
            else {
                return nil
        }
        
        self.init()

        self.userData = identifier
        self.coordinate = coordinate
        self.title = title
        self.opacity = alpha
        self.isTappable = isTappable
        self.isDraggable = isDraggable
        self.color = color
        self.subtitle = snippet
        if let icon = rv["icon"],
            let img = UIImage(freObject: icon, scale: UIScreen.main.scale, orientation: .up) {
            self.icon = img
        }
    }
    
    func setProp(name: String, value: FREObject) {
        switch name {
        case "coordinate":
            self.coordinate = CLLocationCoordinate2D(value) ?? self.coordinate
        case "title":
            self.title = String(value) ?? self.title
        case "snippet":
            self.subtitle = String(value) ?? self.subtitle
        case "isDraggable":
            self.isDraggable = Bool(value) ?? self.isDraggable
        case "isTappable":
            self.isTappable = Bool(value) ?? self.isTappable
        case "color":
            if let color = UIColor(value) {
                self.color = color
            }
        case "icon":
            if let img = UIImage(freObject: value, scale: UIScreen.main.scale, orientation: .up) {
                self.icon = img
            }
        case "alpha":
            self.opacity = CGFloat(value) ?? self.opacity
        default:
            break
        }
    }
    
}
