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

class FreCircleOptionsSwift: FreObjectSwift {
    override public init(freObject: FREObject?) {
        super.init(freObject: freObject)
    }
    
    override public init(freObjectSwift: FreObjectSwift?) {
        super.init(freObjectSwift: freObjectSwift)
    }
    
    override public var value: Any? {
        get {
            do {
                if let raw = rawValue {
                    let idRes = try getAsGMSCircle(raw) as Any?
                    return idRes
                }
            } catch {
            }
            return nil
        }
    }
    
    private func getAsGMSCircle(_ rawValue: FREObject) throws -> GMSCircle {
        var ret: GMSCircle = GMSCircle.init()
        
        if let centerFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "center"),
            let center: CLLocationCoordinate2D = FreCoordinateSwift.init(freObject: centerFre).value as? CLLocationCoordinate2D,
            let radiusFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "radius"),
            let radius = Double(radiusFre),
            let strokeWidthFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "strokeWidth"),
            let strokeWidth = CGFloat(strokeWidthFre),
            let strokeColorFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "strokeColor"),
            let strokeAlphaFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "strokeAlpha"),
            let fillColorFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "fillColor"),
            let fillAlphaFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "fillAlpha")
            {
            ret = GMSCircle(position: center, radius: radius)
            ret.strokeWidth = strokeWidth
            ret.strokeColor = UIColor.init(freObject: strokeColorFre, alpha: strokeAlphaFre)
            ret.fillColor = UIColor.init(freObject: fillColorFre, alpha: fillAlphaFre) 
        }
        return ret
    }
    
}


public extension GMSCircle {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject else {
            return nil
        }
        if let circ = FreCircleOptionsSwift.init(freObject: rv).value as? GMSCircle {
            self.init(position: circ.position, radius: circ.radius)
            self.fillColor = circ.fillColor
            self.strokeColor = circ.strokeColor
            self.strokeWidth = circ.strokeWidth
        } else {
            return nil
        }
    }
}
