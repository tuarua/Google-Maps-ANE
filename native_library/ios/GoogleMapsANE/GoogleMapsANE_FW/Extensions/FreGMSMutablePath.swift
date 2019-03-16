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

public extension FreObjectSwift {
    public subscript(dynamicMember name: String) -> GMSMutablePath {
        return GMSMutablePath(rawValue?[name]) ?? GMSMutablePath()
    }
    public subscript(dynamicMember name: String) -> [GMSMutablePath] {
        return [GMSMutablePath](rawValue?[name]) ?? []
    }
}

public extension GMSMutablePath {
    convenience init?(_ freObject: FREObject?) {
        guard let rv = freObject else { return nil }
        self.init()
        for frePoint in FREArray(rv) {
            if let point = CLLocationCoordinate2D(frePoint) {
                self.add(point)
            }
        }
    }
}

public extension Array where Element == GMSMutablePath {
    init?(_ freObject: FREObject?) {
        self.init()
        guard let rv = freObject else {
            return
        }
        var ret = [GMSMutablePath]()
        let array = FREArray(rv)
        for item in array {
            if let v = GMSMutablePath(item) {
                ret.append(v)
            }
        }
        self = ret
    }
}
