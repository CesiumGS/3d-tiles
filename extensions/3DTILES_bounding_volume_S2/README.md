# 3DTILES_bounding_volume_S2

## Contributors

- Sam Suhag, Cesium
- Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 spec.

## Contents

- [Overview](#overview)
- [Coordinate System Conversion](#coordinate-system-conversion)

## Overview

This extension to 3D Tiles enables using an [S2Cell](http://s2geometry.io/devguide/s2cell_hierarchy) as a bounding volume for a tile.

The S2 Geometry library provides a method of spatially organizing a data over a sphere, using quadrilateral sphere mapping to project from a cube to the sphere. On the cube, space can be divided trivially into a quadtree and that uniform size of the tiles is retained on the sphere, using the curvilinear transform applied to the gnomonic projection.

| S2 Curve on Cube  |  S2 Curve on WGS84 Ellipsoid |
|---|---|
| ![Math](figures/plane.png)  | ![Math](figures/ellipsoid.png)  |

## Coordinate System Conversion

The following diagram illustrates the system to convert from `S2CellID` to a bounded region on the WGS84 ellipsoid:

![Math](figures/math.png)
