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
public struct Settings {
    public var scrollGestures: Bool = true
    public var zoomGestures: Bool = true
    public var tiltGestures: Bool = true
    public var rotateGestures: Bool = true
    public var consumesGesturesInView: Bool = true
    public var compassButton: Bool = true
    public var myLocationButton: Bool = true
    public var indoorPicker: Bool = true
    public var allowScrollGesturesDuringRotateOrZoom: Bool = true
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let sg = dictionary["scrollGestures"] as? Bool {
            scrollGestures = sg
        }
        if let zg = dictionary["zoomGestures"] as? Bool {
            zoomGestures = zg
        }
        if let tg = dictionary["tiltGestures"] as? Bool {
            tiltGestures = tg
        }
        if let rg = dictionary["rotateGestures"] as? Bool {
            rotateGestures = rg
        }
        if let cg = dictionary["consumesGesturesInView"] as? Bool {
            rotateGestures = cg
        }
        if let cb = dictionary["compassButton"] as? Bool {
            compassButton = cb
        }
        if let ml = dictionary["myLocationButton"] as? Bool {
            myLocationButton = ml
        }
        if let ip = dictionary["indoorPicker"] as? Bool {
            indoorPicker = ip
        }
        if let asg = dictionary["allowScrollGesturesDuringRotateOrZoom"] as? Bool {
            allowScrollGesturesDuringRotateOrZoom = asg
        }
    }
    
}
