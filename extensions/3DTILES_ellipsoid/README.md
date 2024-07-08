
# 3DTILES_ellipsoid

## Contributors

* Mark Dane, Cesium

## Status

In progress

## Optional vs. Required

This extension is optional when the tileset does not contain any region bounding volumes. It should be placed in the tileset JSON extensionsUsed list, but not in the extensionsRequired list.

If the tileset contains region bounding volumes and is defining an ellipsoid that is not the WGS 84 ellipsoid, then this extension is required. It should be placed in both the extensionsUsed and extensionsRequired lists in the tileset JSON.

## Contents

* [Overview](#overview)
* [No Ellipsoid](#no-ellipsoid)
* [Referenced to Ellipsoid](#referenced-to-ellipsoid)
* [Region Bounding Volume Changes](#region-bounding-volume-changes)

## Overview

This extension redefines the reference ellipsoid or declares that a tileset does not require an ellipsoid.

This supports data sets that do not use the WGS 84 ellipsoid. This could be because:

* The data represents something that has no specific location (for example a model of a car) and an ellipsoid should not be assumed.
* The data is located on another body  (like the Moon) where the ellipsoid has a different size than the  WGS 84 ellipsoid.

This extension provides two values:

* body - a string to provide context about what the ellipsoid represents (or declare there is no ellipsoid)
* radii - array of the ellipsoid radii in the X, Y, and Z directions

## No Ellipsoid

To indicate that a tileset is not geo-referenced and is not referenced to a specific location on an ellipsoid, the identifier value should be set to "none". No value for radii should be provided.

Tilesets that use this value must not include any region bounding volumes.

### Example of a tileset not referenced to an ellipsoid

```json
{
  "extensionsUsed":["3DTILES_ellipsoid"],
  "extensions": {
    "3DTILES_ellipsoid": {
      "body": "none"
    }
  }
}
```

## Referenced to Ellipsoid

To indicate that a tileset is georeferenced to an ellipsoid, a set of radii values should be provided.

The body property should be a name recognized by the International Astronomical Union (IAU) . For example, the [IAU names](https://www.iau.org/public/themes/naming/#majorplanetsandmoon) of the major planet’s and Earth’s moon are:  Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune, and Moon.

The radii value should be set to the radii of the ellipsoid in meters. These should also be provided as an array of 3 numbers representing the x, y and z radii in order.

### Example of a tileset located on earth

```json
{
  "extensionsUsed":["3DTILES_ellipsoid"],
  "extensions": {
    "3DTILES_ellipsoid": {
       "body": "Earth",
       "radii":  [6378137.0, 6378137.0, 6356752.3142451793]
    }
  }
}
```

### Example of a tileset that is located on the moon

```json
{
  "extensionsUsed":["3DTILES_ellipsoid"],
  "extensions": {
    "3DTILES_ellipsoid": {
       "body": "Moon",
       "radii":  [1737400.0, 1737400.0, 1737400.0]
    }
  }
}
```

## Region Bounding Volume Changes

Using radii values other than the values for the WGS 84 ellipsoid (`[6378137.0, 6378137.0, 6356752.3142451793]`) will change how the viewer interprets region bounding volumes.  This new behavior will no longer match the behavior defined in the specification.

The longitude and latitude values are now to geographic coordinates on the provided ellipsoid instead of the WGS 84 ellipsoid.  The minimum and maximum height values are now as meters above and below the provided ellipsoid instead of the WGS 84 ellipsoid.
