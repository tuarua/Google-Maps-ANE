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
    public function StrokePattern(type:int = StrokePatternType.SOLID, dashLength:int = 50, gapLength:int=50) {
        this.type = type;
        this.dashLength = dashLength;
        this.gapLength = gapLength;
    }
}
}
