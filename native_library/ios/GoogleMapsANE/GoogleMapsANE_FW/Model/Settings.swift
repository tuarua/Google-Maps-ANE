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
import FreSwift

public struct Settings {
    public var scrollGestures = true
    public var zoomGestures = true
    public var tiltGestures = true
    public var rotateGestures = true
    public var consumesGesturesInView = true
    public var compassButton = false
    public var myLocationButtonEnabled = false
    public var indoorPicker = true
    public var allowScrollGesturesDuringRotateOrZoom = true
    
    init?(freObject: FREObject?) {
        guard let rv = freObject else { return nil }
        let fre = FreObjectSwift(rv)
        scrollGestures = fre.scrollGestures
        zoomGestures = fre.zoomGestures
        tiltGestures = fre.tiltGestures
        rotateGestures = fre.tiltGestures
        consumesGesturesInView = fre.consumesGesturesInView
        compassButton = fre.compassButton
        myLocationButtonEnabled = fre.myLocationButtonEnabled
        indoorPicker = fre.indoorPicker
        allowScrollGesturesDuringRotateOrZoom = fre.allowScrollGesturesDuringRotateOrZoom
    }
    
}
