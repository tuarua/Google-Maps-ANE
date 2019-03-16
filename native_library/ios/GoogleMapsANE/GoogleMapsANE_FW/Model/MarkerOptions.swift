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

import UIKit
import GoogleMaps
import FreSwift

class MarkerOptions: NSObject {
    var coordinate: CLLocationCoordinate2D?
    var rotation = CLLocationDegrees(0)
    var color: UIColor?
    var alpha = CGFloat(1)
    var title: String?
    var snippet: String?
    var isDraggable = false
    var isFlat = false
    var isTappable = false
    var icon: UIImage?
    
    public init(freObject: FREObject?) {
        guard let rv = freObject else { return }
        let fre = FreObjectSwift(rv)
        coordinate = fre.coordinate
        title = fre.title
        snippet = fre.snippet
        color = fre.color
        isDraggable = fre.isDraggable
        isFlat = fre.isFlat
        isTappable = fre.isTappable
        rotation = CLLocationDegrees(Int(rv["rotation"]) ?? 0)
        alpha = fre.alpha ?? CGFloat(1)
        
        if let _icon = rv["icon"] {
            let asBitmapData = FreBitmapDataSwift(freObject: _icon)
            if let cgimg = asBitmapData.asCGImage() {
                icon = UIImage(cgImage: cgimg, scale: UIScreen.main.scale, orientation: .up)
            }
        }
    }
}
