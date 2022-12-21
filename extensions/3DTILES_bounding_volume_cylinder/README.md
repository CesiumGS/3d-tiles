# 3DTILES_bounding_volume_cylinder

## Contributors

- Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 and 1.1 specifications.

Optionally, this extension may be used in conjunction with [Implicit Tiling](../../specification/ImplicitTiling). When used together, cylinder bounding volumes will be implicitly subdivided in a quadtree or octree. If using 3D Tiles 1.0 instead of 1.1, refer to [3DTILES_implicit_tiling](../3DTILES_implicit_tiling).

## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

## Overview

Unit cylinder centered at (0, 0, 0) with diameter 2 and height 2.

```json
"boundingVolume": {
  "extensions": {
    "3DTILES_bounding_volume_cylinder": {
      "cylinder": [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]
    }
  }
}
```

## Future

* Add min/max angle to create wedge shapes