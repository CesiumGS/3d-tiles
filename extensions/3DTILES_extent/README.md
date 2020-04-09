# 3DTILES_extent

## Contributors

* Samuel Vargas [@Samulus](https://github.com/Samulus)
* Sean Lilley, [@lilleyse](https://github.com/lilleyse)

## Contents

* [Overview](#overview)
* [Defining Extents](#defining-extents)
* [Holes in Extents](#holes-in-extents)
* [Arc Types](#arc-types)
* [Coordinate System](#coordinate-system)

## Overview

This extension allows the user to annotate the existence of a 2D region(s) (an extent) in a given tileset JSON via a 2D array of decimal coordinate pairs. The first two elements of each coordinate are the longitude (easting) followed by the latitude (northing). The elevation / altitude may be provided as an optional third component for **each** extent coordinate pair: If one coordinate has an explicit elevation, all coordinates must also have explicit elevations. The extension is useful for a variety of scenarios such as: Overlaying high resolution geometry ontop of low level geometry, insetting one tileset into another tileset, or clipping excess geometry inside of a provided tileset.

## Defining Extents

An extent is a collection of longitude and latitude coordinate pairs. Extents are two dimensional in nature, but an optional third component can be specified for **each** extent coordinate to specify its height (in meters) above the WGS84 ellipsoid. The coordinate pairs should be provided in **counterclockwise** winding order. Multiple extents can be specified. Convex and concave extents are both supported. At least three coordinates must be provided for an extent to be valid. Extends may overlap each other, but self-intersecting extens are forbidden.

The extent region definitions can be directly embedded in the `tileset JSON` or located in a separate file and referred to using a `uri` reference in the corresponding `tileset JSON` file.

### External extent definition

`tileset JSON`

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": [
    "3DTILES_extent"
  ],
  "extensions": {
    "3DTILES_extent": {
      "uri": "extent.json"
    }
  },
  "geometricError": 100.0,
  "root": {...}
}
```

### `extent.json`

```json
{
  "polygons": [
    {
      "coordinates": [
        [-116.61512629247555, 32.511166344475825],
        [-116.61385130521423, 32.514456825587125],
        [-116.61829305963617, 32.515638616140173],
        [-116.61944030086889, 32.513154268152434],
        [-116.61512629247555, 32.511166344475825]
      ]
    }
  ]
}
```

### Embedded extent definition

`tileset JSON`

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": [
    "3DTILES_extent"
  ],
  "extensions": {
    "3DTILES_extent": {
      "extent": {
        "polygons": [
          {
            "coordinates": [
              [-116.61512629247555, 32.511166344475825],
              [-116.61385130521423, 32.514456825587125],
              [-116.61829305963617, 32.515638616140173],
              [-116.61944030086889, 32.513154268152434],
              [-116.61512629247555, 32.511166344475825]
            ]
          }
        ]
      }
    }
  },
  "geometricError": 100.0,
  "root": {...}
}
```

## Holes in Extents

Holes are also supported, simpliy provide a `holes` object for a given polygon, e.g:

```json
  "extensions": {
    "3DTILES_extent": {
      "extent": {
        "polygons": [
          {
            "coordinates": [
              [-116.61512629247555, 32.511166344475825],
              [-116.61385130521423, 32.514456825587125],
              [-116.61829305963617, 32.515638616140173],
              [-116.61944030086889, 32.513154268152434],
              [-116.61512629247555, 32.511166344475825]
            ],
            "holes": [
              [
                [-116.61521629247, 32.2032301338380],
                [-116.323208320832, 32.3482030238302],
                [-116.4830243804380, 32.7382033280322]
              ]
            ]
          }
        ]
      }
    }
  }
```

Holes should be provided in **counterclockwise** winding order, and at least three coordinates must be provided. Holes may overlap each other, but self-intersecting holes are forbidden. Any overlapping holes are treated as a boolean union.

## Arc Types

Lines formed by consecutive coordinates represent **geodesic** lines. These are straight lines in 3D space, but curved when looking at their 2D projection.

## Coordinate System

Coordinates specified in the extent / holes section should adhere to the Cartographic ESPG:4326 standard (lattitude, then longitude).
