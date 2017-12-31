package com.tuarua.googlemaps {
public class CameraPosition {
	/**
	 * 
	 */	
    public var centerAt:Coordinate = null;
	/**
	 * ignored on Apple Maps
	 */	
    public var zoom:Number = -9999;
	/**
	 * 
	 */	
    public var tilt:Number = -9999;
	/**
	 * aka heading
	 */	
    public var bearing:Number = -9999;
	/**
	 * This method is omitted from the output. * * @private
	 */
	public function CameraPosition() {
	}
	
}
}
