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
[RemoteClass(alias="com.tuarua.googlemaps.StrokePattern")]
public class StrokePattern {
	/**
	 * 
	 */	
    public var type:int;
	/**
	 * 
	 */	
    public var dashLength:int;
	/**
	 * 
	 */	
    public var gapLength:int;
	/**
	 * 
	 * @param type
	 * @param dashLength
	 * @param gapLength
	 * 
	 */	
    public function StrokePattern(type:int = 0, dashLength:int = 50, gapLength:int=50) {
        this.type = type;
        this.dashLength = dashLength;
        this.gapLength = gapLength;
    }
}
}
