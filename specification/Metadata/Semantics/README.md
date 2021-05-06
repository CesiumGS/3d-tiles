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

* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata/1.0.0) - 3D Tiles extension that assigns metadata to various components of 3D Tiles
* [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/master/extensions/2.0/Vendor/EXT_feature_metadata/1.0.0) - glTF extension that assigns metadata to features in a model on a per-vertex, per-texel, or per-instance basis

<!-- omit in toc -->
### **TILE_BOUNDING_BOX**

The bounding volume of the tile, expressed as a [box (as defined by 3D Tiles 1.0)](https://github.com/CesiumGS/3d-tiles/tree/master/specification#box). This property may be used to describe a tighter bounding volume for a tile than is implicitly calculated by [3DTILES_implicit_tiling](https://github.com/CesiumGS/3d-tiles/blob/3d-tiles-next/extensions/3DTILES_implicit_tiling/0.0.0/README.md).

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `12`

<!-- omit in toc -->
### **TILE_BOUNDING_REGION**

The bounding volume of the tile, expressed as a [region (as defined by 3D Tiles 1.0)](https://github.com/CesiumGS/3d-tiles/tree/master/specification#region). This property may be used to describe a tighter bounding volume for a tile than is implicitly calculated by [3DTILES_implicit_tiling](https://github.com/CesiumGS/3d-tiles/blob/3d-tiles-next/extensions/3DTILES_implicit_tiling/0.0.0/README.md).

* Type: `ARRAY`
* Component type: `FLOAT64`
* Component count: `6`

<!-- omit in toc -->
### **TILE_BOUNDING_SPHERE**

The bounding volume of the tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](https://github.com/CesiumGS/3d-tiles/tree/master/specification#sphere).

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

*Note: Only one type of tile bounding volume may be specified at a time.*

<!-- omit in toc -->
### **CONTENT_BOUNDING_BOX**

The bounding volume of the content of a tile, expressed as a [box (as defined by 3D Tiles 1.0)](https://github.com/CesiumGS/3d-tiles/tree/master/specification#box). This property may be used to describe a tighter bounding volume for the content of a tile than is implicitly calculated by [3DTILES_implicit_tiling](https://github.com/CesiumGS/3d-tiles/blob/3d-tiles-next/extensions/3DTILES_implicit_tiling/0.0.0/README.md). This property is equivalent to `tile.content.boundingVolume.box`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `12`

<!-- omit in toc -->
### **CONTENT_BOUNDING_REGION**

The bounding volume of the content of a tile, expressed as a [region (as defined by 3D Tiles 1.0)](https://github.com/CesiumGS/3d-tiles/tree/master/specification#region). This property may be used to describe a tighter bounding volume for the content of a tile than is implicitly calculated by [3DTILES_implicit_tiling](https://github.com/CesiumGS/3d-tiles/blob/3d-tiles-next/extensions/3DTILES_implicit_tiling/0.0.0/README.md). This property is equivalent to `tile.content.boundingVolume.region`.

* Type: `ARRAY`
* Component type: `FLOAT64`
* Component count: `6`

<!-- omit in toc -->
### **CONTENT_BOUNDING_SPHERE**

The bounding volume of the content of  tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](https://github.com/CesiumGS/3d-tiles/tree/master/specification#sphere). This property is equivalent to `tile.content.boundingVolume.sphere`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

*Note: Only one type of content bounding volume may be specified at a time.*

<!-- omit in toc -->
### **TILE_HORIZON_OCCLUSION_POINT**

The horizon occlusion point of the tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire entity is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information. This semantic is often used with tile metadata.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `3`

<!-- omit in toc -->
### **TILE_MINIMUM_HEIGHT**

The minimum height of the tile above (or below) the WGS84 ellipsoid. When a tile bounding volume is explicitly defined for a tile, this property will be be ignored.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **TILE_MAXIMUM_HEIGHT**

The maximum height of the tile above (or below) the WGS84 ellipsoid. When a tile bounding volume is explicitly defined for a tile, this property will be be ignored.

* Type: `FLOAT32` or `FLOAT64`

> **Implementation Note**: If `TILE_BOUNDING_REGION` is specified along with a `TILE_MAXIMIUM_HEIGHT` or `TILE_MINIMUM_HEIGHT`, the heights will be ignored.

<!-- omit in toc -->
### **CONTENT_MINIMUM_HEIGHT**

The minimum height of the content of a tile above (or below) the WGS84 ellipsoid. When a content bounding volume is explicitly defined for a tile, this property will be be ignored.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **CONTENT_MAXIMUM_HEIGHT**

The maximum height of the content of a tile above (or below) the WGS84 ellipsoid. When a content bounding volume is explicitly defined for a tile, this property will be be ignored.

* Type: `FLOAT32` or `FLOAT64`

> **Implementation Note**: If `CONTENT_BOUNDING_REGION` is specified along with a `CONTENT_MAXIMIUM_HEIGHT` or `CONTENT_MINIMUM_HEIGHT`, the heights will be ignored.

<!-- omit in toc -->
### **NAME**

The name of the entity. Names do not have to be unique.

* Type: `STRING`

<!-- omit in toc -->
### **ID**

A unique identifier for the entity.

* Type: `STRING`
