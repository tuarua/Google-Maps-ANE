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

class MarkerOptions: NSObject {
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
    
    public init(freObject: FREObject?) {
        //super.init(freObject: freObject)
        
        do {
            if let _coordinate = try CLLocationCoordinate2D.init(freObject?.getProp(name: "coordinate")) {
                coordinate = _coordinate
                
                if let _title = try String(freObject?.getProp(name: "title")) {
                    title = _title
                }

                if let _snippet = try String(freObject?.getProp(name: "snippet")) {
                    snippet = _snippet
                }
                if let freColor = try freObject?.getProp(name: "color") {
                    let _color = UIColor.init(freObject: freColor)
                    color = _color
                }
                
                if let _isDraggable = try Bool(freObject?.getProp(name: "isDraggable")) {
                    isDraggable = _isDraggable
                }
                
                if let _isFlat = try Bool(freObject?.getProp(name: "isFlat")) {
                    isFlat = _isFlat
                }
                
                if let _isTappable = try Bool(freObject?.getProp(name: "isTappable")) {
                    isTappable = _isTappable
                }
                
                
                if let rotationInt: Int = try Int(freObject?.getProp(name: "rotation")) {
                    rotation = CLLocationDegrees.init(rotationInt)
                }
                
                
                if let _opacity = try CGFloat(freObject?.getProp(name: "opacity")) {
                    opacity = _opacity
                }
                
                if let _icon = try freObject?.getProp(name: "icon") {
                    let asBitmapData = FreBitmapDataSwift.init(freObject: _icon)
                    defer {
                        asBitmapData.releaseData()
                    }
                    do {
                        if let cgimg = try asBitmapData.getAsImage() {
                            icon = UIImage.init(cgImage: cgimg, scale: UIScreen.main.scale, orientation: .up)
                        }
                    }
                    catch {}
                }
                
                
                
                
            }
        } catch _ as FreError {
        } catch {
        }
        
    }

}
