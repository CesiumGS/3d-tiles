# Cesium Metadata Semantic Reference

This document defines a general set of semantics for 3D Tiles and glTF. Tileset authors may define their own application- or domain-specific semantics separately.

Semantics describe how properties should be interpreted. For example, an application that sees the `TILE_HORIZON_OCCLUSION_POINT` semantic would use the property for horizon occlusion culling as defined below.

```jsonc
{
  "properties": {
    "horizonOcclusionPoint": {
      "type": "ARRAY",
      "componentType": "FLOAT64",
      "componentCount": 4,
      "semantic": "TILE_HORIZON_OCCLUSION_POINT",
    },
    "name": {
      "type": "STRING",
      "semantic": "NAME"
    }
  }
}
```

For full usage see:

* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata) - 3D Tiles extension that assigns metadata to various components of 3D Tiles
* [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) - glTF extension that assigns metadata to features in a model on a per-vertex, per-texel, or per-instance basis

<!-- omit in toc -->
### **TILE_BOUNDING_BOX**

The bounding volume of the tile, expressed as a [box (as defined by 3D Tiles 1.0)](../../../specification#box). This property may be used to describe a tighter bounding volume for a tile than is implicitly calculated by [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). This property is equivalent to `tile.boundingVolume.box`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `12`

<!-- omit in toc -->
### **TILE_BOUNDING_REGION**

The bounding volume of the tile, expressed as a [region (as defined by 3D Tiles 1.0)](../../../specification#region). This property may be used to describe a tighter bounding volume for a tile than is implicitly calculated by [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). This property is equivalent to `tile.boundingVolume.region`.

* Type: `ARRAY`
* Component type: `FLOAT64`
* Component count: `6`

<!-- omit in toc -->
### **TILE_BOUNDING_SPHERE**

The bounding volume of the tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](../../../specification#sphere). This property is equivalent to `tile.boundingVolume.sphere`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

> **Implementation Note**: If multiple tile bounding volumes are specified the implementation may decide which bounding volume to use.

<!-- omit in toc -->
### **CONTENT_BOUNDING_BOX**

The bounding volume of the content of a tile, expressed as a [box (as defined by 3D Tiles 1.0)](../../../specification#box). This property may be used to describe a tighter bounding volume for the content of a tile than is implicitly calculated by [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). This property is equivalent to `tile.content.boundingVolume.box`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `12`

<!-- omit in toc -->
### **CONTENT_BOUNDING_REGION**

The bounding volume of the content of a tile, expressed as a [region (as defined by 3D Tiles 1.0)](../../../specification#region). This property may be used to describe a tighter bounding volume for the content of a tile than is implicitly calculated by [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). This property is equivalent to `tile.content.boundingVolume.region`.

* Type: `ARRAY`
* Component type: `FLOAT64`
* Component count: `6`

<!-- omit in toc -->
### **CONTENT_BOUNDING_SPHERE**

The bounding volume of the content of  tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](../../../specification#sphere). This property is equivalent to `tile.content.boundingVolume.sphere`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

> **Implementation Note**: If multiple content bounding volumes are specified the implementation may decide which bounding volume to use.

<!-- omit in toc -->
### **TILE_MINIMUM_HEIGHT**

The minimum height of the tile above (or below) the WGS84 ellipsoid.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **TILE_MAXIMUM_HEIGHT**

The maximum height of the tile above (or below) the WGS84 ellipsoid.

* Type: `FLOAT32` or `FLOAT64`

> **Implementation Note**: `TILE_MINIMUM_HEIGHT` and `TILE_MAXIMUM_HEIGHT` may be ignored if `TILE_BOUNDING_REGION` is specified or if the tile has an explicit bounding volume.

<!-- omit in toc -->
### **CONTENT_MINIMUM_HEIGHT**

The minimum height of the content of a tile above (or below) the WGS84 ellipsoid.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **CONTENT_MAXIMUM_HEIGHT**

The maximum height of the content of a tile above (or below) the WGS84 ellipsoid.

* Type: `FLOAT32` or `FLOAT64`

> **Implementation Note**: `CONTENT_MINIMUM_HEIGHT` and `CONTENT_MAXIMUM_HEIGHT` may be ignored if `CONTENT_BOUNDING_REGION` is specified or if the tile has an explicit content bounding volume.

<!-- omit in toc -->
### **TILE_HORIZON_OCCLUSION_POINT**

The horizon occlusion point of the tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire tile is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `3`

<!-- omit in toc -->
### **CONTENT_HORIZON_OCCLUSION_POINT**

The horizon occlusion point of the content of a tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire content is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `3`

> **Implementation Note**: Just as tile bounding volumes provide spatial coherence for traversal while content bounding volumes enable finer grained culling, the computation of `TILE_HORIZON_OCCLUSION_POINT` should account for all content in a tile and its descendants whereas `CONTENT_HORIZON_OCCLUSION_POINT` should only account for content in a tile. When the two values are equivalent only `TILE_HORIZON_OCCLUSION_POINT` should be specified.

<!-- omit in toc -->
### **TILE_GEOMETRIC_ERROR**

The geometric error of the tile that overrides the geometric error implicitly calculated by [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). This property is equivalent to `tile.geometricError`.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **NAME**

The name of the entity. Names do not have to be unique.

* Type: `STRING`

<!-- omit in toc -->
### **ID**

A unique identifier for the entity.

* Type: `STRING`
