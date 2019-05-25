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
import com.tuarua.GoogleMapsANEContext;
import com.tuarua.fre.ANEError;

import flash.display.BitmapData;

[RemoteClass(alias="com.tuarua.googlemaps.GroundOverlay")]
public class GroundOverlay {
    private var _isAdded:Boolean = false;
    private var _id:String;
    private var _isTappable:Boolean = false;
    private var _bounds:CoordinateBounds;
    private var _bearing:Number = 0;
    private var _visible:Boolean = true;
    private var _zIndex:Number = 0;
    private var _transparency:Number = 0;
    private var _image:BitmapData;

    /**
     *
     * @param bounds
     * @param image
     * @param bearing
     * @param isTappable
     * @param visible
     * @param zIndex
     * @param transparency
     */
    public function GroundOverlay(bounds:CoordinateBounds, image:BitmapData, bearing:Number = 0,
                                  isTappable:Boolean = false, visible:Boolean = true, zIndex:Number = 0,
                                  transparency:Number = 0) {
        this._bounds = bounds;
        this._image = image;
        this._bearing = bearing;
        this._isTappable = isTappable;
        this._visible = visible;
        this._zIndex = zIndex;
        this._transparency = transparency;
    }

    public function remove():void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("removeGroundOverlay", _id);
        if (ret is ANEError) throw ret as ANEError;
        delete GoogleMapsANEContext.groundOverlays[_id];
    }

    public function set isAdded(value:Boolean):void {
        _isAdded = value;
    }

    public function get id():String {
        return _id;
    }

    public function set id(value:String):void {
        _id = value;
    }

    public function get bounds():CoordinateBounds {
        return _bounds;
    }

    public function set bounds(value:CoordinateBounds):void {
        _bounds = value;
        setAneValue("bounds", value);
    }

    public function get bearing():Number {
        return _bearing;
    }

    /**
     * The amount that the image should be rotated in a clockwise direction. The center of the rotation will be
     * the image's anchor. This is optional and the default bearing is 0, i.e., the image is aligned so that up is north.
     */
    public function set bearing(value:Number):void {
        _bearing = value;
        setAneValue("bearing", value);
    }


    public function get isTappable():Boolean {
        return _isTappable;
    }

    /**
     * If you want to handle events fired when the user clicks the ground overlay, set this property to true. You can
     * change this value at any time. The default is false.
     *
     */
    public function set isTappable(value:Boolean):void {
        _isTappable = value;
        setAneValue("isTappable", value);
    }

    public function get visible():Boolean {
        return _visible;
    }

    /**
     * Ignored on iOS
     */
    public function set visible(value:Boolean):void {
        _visible = value;
        setAneValue("visible", value);
    }

    public function get zIndex():Number {
        return _zIndex;
    }

    public function set zIndex(value:Number):void {
        _zIndex = value;
        setAneValue("zIndex", value);
    }

    public function get transparency():Number {
        return _transparency;
    }

    /**
     * Transparency of the ground overlay in the range [0..1] where 0 means the overlay is opaque and 1 means the
     * overlay is fully transparent.
     */
    public function set transparency(value:Number):void {
        _transparency = value;
        setAneValue("transparency", value);
    }

    public function get image():BitmapData {
        return _image;
    }

    public function set image(value:BitmapData):void {
        _image = value;
        setAneValue("image", value);
    }

    private function setAneValue(name:String, value:*):void {
        if (!_isAdded) return;
        var ret:* = GoogleMapsANEContext.context.call("setGroundOverlayProp", _id, name, value);
        if (ret is ANEError) throw ret as ANEError;
    }
}
}
