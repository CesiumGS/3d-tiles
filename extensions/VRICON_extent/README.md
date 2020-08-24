# VRICON_extent

## Contributors

* Erik Dahlström, [@erikdahlstrom](https://github.com/erikdahlstrom)
* Johan Borg, [@jo-borg]( https://github.com/jo-borg)

## Contents

- [VRICON_extent](#vriconextent)
  - [Contributors](#contributors)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Defining Extents](#defining-extents)
    - [Extent definition](#extent-definition)
    - [`extent.geojson`](#extentgeojson)

## Overview

This extension allows the user to annotate the existence of a 2D region(s) (an extent) in a given tileset JSON via a reference to a [GeoJSON](https://tools.ietf.org/html/rfc7946) file.

The GeoJSON must contain Polygon or MultiPolygon shapes only.

The extension is useful for a variety of scenarios such as: Overlaying high resolution geometry on top of low level geometry, defining a 2D collision boundary, or clipping excess geometry inside of a provided tileset.

**Note: this specification is deprecated and is here for documentation only, the replacement specification is [3DTILES_extent](https://github.com/CesiumGS/3d-tiles/tree/3DTILES_extent/extensions/3DTILES_extent).**

## Defining Extents

An extent is a collection of longitude and latitude coordinate pairs. Extents are two-dimensional in nature, but an optional third component can be specified for **each** extent coordinate to specify its height (in meters) above the WGS84 ellipsoid.

The [GeoJSON](https://tools.ietf.org/html/rfc7946) specification for the details.

At least three coordinates must be provided for an extent to be valid. Extents may overlap each other, but self-intersecting extents are forbidden. Overlapping extents are treated as a boolean union.

The extent region definition must be located in a separate file and referred to using a `uri` reference in the corresponding tileset JSON file.

### Extent definition

#### `tileset JSON`

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": [
    "VRICON_extent"
  ],
  "extensions": {
    "VRICON_extent": {
      "uri": "extent.geojson"
    }
  },
  "geometricError": 100.0,
  "root": {}
}
```

#### `extent.geojson`

```json

{
  "features": [
    {
      "geometry": {
        "coordinates": [
          [
            [-116.61512629247555, 32.511166344475825],
            [-116.61385130521423, 32.514456825587125],
            [-116.61829305963617, 32.515638616140173],
            [-116.61944030086889, 32.513154268152434]
          ]
        ],
        "type": "Polygon"
      },
      "properties": {},
      "type": "Feature"
    }
  ],
  "type": "FeatureCollection"
}
```
