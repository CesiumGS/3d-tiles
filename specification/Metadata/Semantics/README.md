# Cesium Metadata Semantic Reference

This document defines a general set of semantics for 3D Tiles and glTF. Tileset authors may define their own application- or domain-specific semantics separately.

Semantics describe how properties should be interpreted. For example, an application that sees the `HORIZON_OCCLUSION_POINT` semantic would use the property for horizon occlusion culling as defined below.

```jsonc
{
  "properties": {
    "horizonOcclusionPoint": {
      "type": "ARRAY",
      "componentType": "FLOAT64",
      "componentCount": 4,
      "semantic": "HORIZON_OCCLUSION_POINT",
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
### **HORIZON_OCCLUSION_POINT**

The horizon occlusion point expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire entity is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information. This semantic is often used with tile metadata.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `3`

<!-- omit in toc -->
### **MINIMUM_HEIGHT**

The minimum height relative to some ellipsoid.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **MAXIMUM_HEIGHT**

The maximum height relative to some ellipsoid.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **BOUNDING_SPHERE**

A bounding sphere as `[x, y, z, radius]`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

<!-- omit in toc -->
### **NAME**

The name of the entity. Names do not have to be unique.

* Type: `STRING`

<!-- omit in toc -->
### **ID**

A unique identifier for the entity.

* Type: `STRING`
