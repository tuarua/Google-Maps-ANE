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
        
        self.init(position: fre.coordinate, icon: UIImage(freObject: fre.image,
                                                          scale: UIScreen.main.scale,
                                                          orientation: .up), zoomLevel: CGFloat(1))
        self.bearing = fre.bearing
        self.opacity = 1.0 - fre.transparency
        self.isTappable = fre.isTappable
        self.zIndex = Int32(fre.zIndex as Int)
        self.userData = UUID().uuidString
    }
}