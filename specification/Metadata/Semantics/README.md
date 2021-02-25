# Cesium Metadata Semantic Reference

This document defines semantics that may be used in the following specifications:

* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata/1.0.0) - 3D Tiles extension that assigns metadata to various components of 3D Tiles
* [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/master/extensions/2.0/Vendor/EXT_feature_metadata/1.0.0) - glTF extension that assigns metadata to features in a model on a per-vertex, per-texel, or per-instance basis

<!-- omit in toc -->
### **HORIZON_OCCLUSION_POINT**

The horizon occlusion point of a tile expressed in the ellipsoid-scaled fixed frame. If this point is below the horizon, the entire tile is below the horizon. See https://cesium.com/blog/2013/04/25/horizon-culling/ for more information.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `3`

<!-- omit in toc -->
### **BOUNDING_SPHERE**

The bounding sphere of a tile as `[x, y, z, radius]`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

<!-- omit in toc -->
### **MINIMUM_HEIGHT**

The minimum height of a tile.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **MAXIMUM_HEIGHT**

The maximum height of a tile.

* Type: `FLOAT32` or `FLOAT64`

<!-- omit in toc -->
### **NAME**

The name of the entity. Names do not have to be unique.

* Type: `STRING`

<!-- omit in toc -->
### **ID**

A unique identifier for the entity.

* Type: `STRING`
