# 3DTILES_bounding_volume_cylinder

## Contributors

- Sean Lilley, Cesium
- Janine Liu, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.1 specification.

## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

## Overview

This extension defines a cylinder bounding volume type.

```json
"boundingVolume": {
  "extensions": {
    "3DTILES_bounding_volume_cylinder": {
      "cylinder": [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]
    }
  }
}
```
_Example: Cylinder with radius 1.0, height 2.0, and no rotation_

The `cylinder` property is an array of 12 numbers that define an oriented bounding cylinder in a right-handed 3-axis (x, y, z) Cartesian coordinate system where the z-axis is up. The first three elements define the x, y, and z values for the center of the cylinder. The next three elements (with indices 3, 4, and 5) define the x-axis direction and half-length. The next three elements (indices 6, 7, and 8) define the y-axis direction and half-length. The last three elements (indices 9, 10, and 11) define the z-axis direction and half-length.

The half-axes must be orthogonal to each other.


## Implicit Subdivision

When used with [Implicit Tiling](../../specification/ImplicitTiling), a `QUADTREE` subdivision will subdivide along the radius and angle axes. An `OCTREE` subdivision will subdivide along the radius, angle, and height axes.

| Root Cylinder  | Quadtree | Octree |
|---|---|---|
| ![Parent Cell](figures/root.png)  | ![Quadtree Cells](figures/quadtree.png)  | ![Octree Cells](figures/octree.png)  |

Implicit tile coordinates:

Coordinate|Positive Direction
--|--
x| From the center (increasing radius)
y| From `-pi` to `pi` clockwise (see figure below)
z| From bottom to top (increasing height)

![Cylinder Coordinates](figures/cylinder-coordinates.png)
