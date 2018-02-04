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
