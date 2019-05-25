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
package com.tuarua.googlemaps {
public class Shape {
    protected var _visible:Boolean = true;
    protected var _isAdded:Boolean = false;
    protected var _id:String;
    protected var _isTappable:Boolean = false;
    protected var _zIndex:Number = 0;
    public function Shape() {
    }

    public function get id():String {
        return _id;
    }

    public function set id(value:String):void {
        _id = value;
    }

    public function get zIndex():Number {
        return _zIndex;
    }

    public function get visible():Boolean {
        return _visible;
    }

    public function get isTappable():Boolean {
        return _isTappable;
    }

    public function set isAdded(value:Boolean):void {
        _isAdded = value;
    }
}
}
