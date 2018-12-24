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
public struct Settings {
    public var scrollGestures = true
    public var zoomGestures = true
    public var tiltGestures = true
    public var rotateGestures = true
    public var consumesGesturesInView = true
    public var compassButton = false
    public var myLocationButtonEnabled = false
    public var myLocationEnabled = false
    public var indoorPicker = true
    public var allowScrollGesturesDuringRotateOrZoom = true
    public var buildingsEnabled = true
    
    init(dictionary: [String: AnyObject]) {
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
        if let mlb = dictionary["myLocationButtonEnabled"] as? Bool {
            myLocationButtonEnabled = mlb
        }
        if let ml = dictionary["myLocationEnabled"] as? Bool {
            myLocationEnabled = ml
        }
        if let ip = dictionary["indoorPicker"] as? Bool {
            indoorPicker = ip
        }
        if let asg = dictionary["allowScrollGesturesDuringRotateOrZoom"] as? Bool {
            allowScrollGesturesDuringRotateOrZoom = asg
        }
        if let bld = dictionary["buildingsEnabled"] as? Bool {
            buildingsEnabled = bld
        }
    }
    
}
