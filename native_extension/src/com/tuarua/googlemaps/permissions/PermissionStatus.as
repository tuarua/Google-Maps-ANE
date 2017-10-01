package com.tuarua.googlemaps.permissions {
public class PermissionStatus {
    /**
     * User has not yet made a choice with regards to this application
     */
    public static const NOT_DETERMINED:int = 0;
    /**
     * This application is not authorized to use location services.  Due
     * to active restrictions on location services, the user cannot change
     * this status, and may not have personally denied authorization
     */
    public static const RESTRICTED:int = 1;
    /**
     * User has explicitly denied authorization for this application, or
     * location services are disabled in Settings.
     */
    public static const DENIED:int = 2;
    /**
     * User has granted authorization to use their location at any time,
     * including monitoring for regions, visits, or significant location changes.
     */
    public static const ALWAYS:int = 3;
    /**
     * User has granted authorization to use their location only when your app
     * is visible to them (it will be made visible to them if you continue to
     * receive location updates while in the background).  Authorization to use
     * launch APIs has not been granted.
     */
    public static const WHEN_IN_USE:int = 4;

    /**
     * User should be shown rationale to explain why the app needs permissions.
     */
    public static const SHOW_RATIONALE:int = 5;
}
}