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
import MapKit

class FreMKCircle: FreObjectSwift {
    override public init(freObject: FREObject?) {
        super.init(freObject: freObject)
    }

    override public var value: Any? {
        get {
            do {
                if let raw = rawValue {
                    let idRes = try getAsMKCircle(raw) as Any?
                    return idRes
                }
            } catch {
            }
            return nil
        }
    }

    private func getAsMKCircle(_ rawValue: FREObject) throws -> CustomMKCircle? {
        if let centerFre = try FreSwiftHelper.getProperty(rawValue: rawValue, name: "center"),
           let center: CLLocationCoordinate2D = FreCLLocationCoordinate.init(freObject: centerFre).value as? CLLocationCoordinate2D,
           let radiusFre = try rawValue.getProp(name: "radius"),
           let radius = Double(radiusFre),
           let strokeWidth = try CGFloat(rawValue.getProp(name: "strokeWidth")),
           let strokeColorFre = try rawValue.getProp(name: "strokeColor"),
           let strokeAlphaFre = try rawValue.getProp(name: "strokeAlpha"),
           let fillColorFre = try rawValue.getProp(name: "fillColor"),
           let fillAlphaFre = try rawValue.getProp(name: "fillAlpha") {
            let identifier = UUID.init().uuidString
            let ret = CustomMKCircle.init(center: center, radius: radius, identifier: identifier)
            ret.strokeWidth = strokeWidth
            ret.strokeColor = UIColor.init(freObject: strokeColorFre, alpha: strokeAlphaFre)
            ret.fillColor = UIColor.init(freObject: fillColorFre, alpha: fillAlphaFre)
            return ret
        }
        return nil
    }

}

public extension CustomMKCircle {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject else {
            return nil
        }
        if let circ = FreMKCircle.init(freObject: rv).value as? CustomMKCircle {
            let identifier = UUID.init().uuidString
            self.init(center: circ.coordinate, radius: circ.radius, identifier: identifier)
            self.fillColor = circ.fillColor
            self.strokeColor = circ.strokeColor
            self.strokeWidth = circ.strokeWidth
        } else {
            return nil
        }
    }
}
