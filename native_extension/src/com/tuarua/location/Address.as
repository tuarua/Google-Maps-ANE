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
package com.tuarua.location {
public class Address {
    private var _formattedAddress:String;
    private var _name:String;
    private var _street:String;
    private var _city:String;
    private var _postalCode:String;
    private var _country:String;

    public function Address(formattedAddress:String, name:String, street:String, city:String,
                            postalCode:String, country:String) {
        this._formattedAddress = formattedAddress;
        this._name = name;
        this._street = street;
        this._city = city;
        this._postalCode = postalCode;
        this._country = country;
    }

    public function get formattedAddress():String {
        return _formattedAddress;
    }

    public function get name():String {
        return _name;
    }

    public function get street():String {
        return _street;
    }

    public function get city():String {
        return _city;
    }

    public function get postalCode():String {
        return _postalCode;
    }

    public function get country():String {
        return _country;
    }
}
}
