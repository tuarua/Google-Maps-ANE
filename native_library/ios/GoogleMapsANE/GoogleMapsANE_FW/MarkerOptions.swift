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

import UIKit
import GoogleMaps
import FreSwift

class MarkerOptions: FreObjectSwift {
    var coordinate: CLLocationCoordinate2D?
    var rotation: CLLocationDegrees = CLLocationDegrees.init(0)
    var color:UIColor?
    var opacity: CGFloat = CGFloat.init(1)
    var title: String?
    var snippet: String?
    var isDraggable: Bool = false
    var isFlat: Bool = false
    var isTappable: Bool = false
    var icon: UIImage?
    
    override public init(freObject: FREObject?) {
        super.init(freObject: freObject)
        
        do {
            if let _coordinate = try CLLocationCoordinate2D.init(self.getProperty(name: "coordinate")) {
                coordinate = _coordinate
                
                if let _title = try String(self.getProperty(name: "title")) {
                    title = _title
                }

                if let _snippet = try String(self.getProperty(name: "snippet")) {
                    snippet = _snippet
                }
                if let freColor = try self.getProperty(name: "color")?.rawValue {
                    let _color = UIColor.init(freObject: freColor)
                    color = _color
                }
                
                if let _isDraggable = try Bool(self.getProperty(name: "isDraggable")) {
                    isDraggable = _isDraggable
                }
                
                if let _isFlat = try Bool(self.getProperty(name: "isFlat")) {
                    isFlat = _isFlat
                }
                
                if let _isTappable = try Bool(self.getProperty(name: "isTappable")) {
                    isTappable = _isTappable
                }
                
                
                if let rotationInt: Int = try Int(self.getProperty(name: "rotation")) {
                    rotation = CLLocationDegrees.init(rotationInt)
                }
                
                
                if let _opacity = try CGFloat(self.getProperty(name: "opacity")) {
                    opacity = _opacity
                }
                
                let asBitmapData = try FreBitmapDataSwift.init(freObjectSwift: self.getProperty(name: "icon"))
                defer {
                    asBitmapData.releaseData()
                }
                do {
                    if let cgimg = try asBitmapData.getAsImage() {
                        icon = UIImage.init(cgImage: cgimg, scale: UIScreen.main.scale, orientation: .up)
                    }
                } catch {
                }
                
                
            }
        } catch _ as FreError {
        } catch {
        }
        
    }

}
