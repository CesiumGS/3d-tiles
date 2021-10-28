# Cesium Metadata Semantic Reference

### Overview

This document provides common definitions of meaning ("semantics") used by metadata properties in 3D Tiles 1.0 and glTF 2.0. Tileset authors may define their own application- or domain-specific semantics separately.

Semantics describe how properties should be interpreted. For example, an application that encounters the `ID` or `NAME` semantics while parsing a dataset may use these values as unique identifiers or human-readable labels, respectively.

Each semantic is defined in terms of its meaning, and the datatypes it may assume. Datatype specifications include "type", "component type", and "component count" attributes as defined by the [Cesium 3D Metadata Specification](../).

For use of semantics in extensions of specific standards, see:

* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata) (3D Tiles 1.0) — Assigns metadata to tilesets, tiles, or tile contents
* [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) (glTF 2.0) —  Assigns metadata to subcomponents ("features") of geometry or textures

## Contents

- [Cesium Metadata Semantic Reference](#cesium-metadata-semantic-reference)
    - [Overview](#overview)
  - [Contents](#contents)
  - [General](#general)
    - [Overview](#overview-1)
    - [`ID`](#id)
    - [`NAME`](#name)
  - [3D Tiles](#3d-tiles)
    - [Overview](#overview-2)
    - [Tile](#tile)
      - [Overview](#overview-3)
      - [`TILE_BOUNDING_BOX`](#tile_bounding_box)
      - [`TILE_BOUNDING_REGION`](#tile_bounding_region)
      - [`TILE_BOUNDING_SPHERE`](#tile_bounding_sphere)
      - [`TILE_MINIMUM_HEIGHT`](#tile_minimum_height)
      - [`TILE_MAXIMUM_HEIGHT`](#tile_maximum_height)
      - [`TILE_HORIZON_OCCLUSION_POINT`](#tile_horizon_occlusion_point)
      - [`TILE_GEOMETRIC_ERROR`](#tile_geometric_error)
    - [Content](#content)
      - [Overview](#overview-4)
      - [`CONTENT_BOUNDING_BOX`](#content_bounding_box)
      - [`CONTENT_BOUNDING_REGION`](#content_bounding_region)
      - [`CONTENT_BOUNDING_SPHERE`](#content_bounding_sphere)
      - [`CONTENT_MINIMUM_HEIGHT`](#content_minimum_height)
      - [`CONTENT_MAXIMUM_HEIGHT`](#content_maximum_height)
      - [`CONTENT_HORIZON_OCCLUSION_POINT`](#content_horizon_occlusion_point)
  - [Revision History](#revision-history)

## General

### Overview

Throughout this section, the term "entity" refers to any conceptual object with which a property value (as defined in the [Cesium 3D Metadata Specification](../)) may be associated. Examples of entities include tilesets, tiles, and tile contents in 3D Tiles, or groups of vertices and texels in glTF 2.0 assets. Additional types of entities may be defined by other specifications or applications.

### `ID`

The unique identifier for the entity.

* Type: `STRING`

### `NAME`

The name of the entity. Names should be human-readable, and do not have to be unique.

* Type: `STRING`

## 3D Tiles

### Overview

Semantics for 3D Tiles are assigned in relationship to a tile or tile content, as defined by the 3D Tiles 1.0 specification. When associated with other types of entities, these semantics may have invalid or undefined meanings.

Units for all linear distances are meters, and all angles are radians.

### Tile

#### Overview

`TILE_*` semantics provide meaning for properties associated with a particular tile, and should take precedence over equivalent metadata on parent objects, as well as over values derived from subdivision schemes like [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling).

In particular, `TILE_BOUNDING_BOX`, `TILE_BOUNDING_REGION`, and `TILE_BOUNDING_SPHERE` semantics each define a tighter bounding volume for a tile than is implicitly calculated from [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). If more than one of these semantics are available for a tile, clients may select the most appropriate option based on use case and performance requirements.

#### `TILE_BOUNDING_BOX`

The bounding volume of the tile, expressed as a [box (as defined by 3D Tiles 1.0)](../../../specification#box). Equivalent to `tile.boundingVolume.box`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `12`

#### `TILE_BOUNDING_REGION`

The bounding volume of the tile, expressed as a [region (as defined by 3D Tiles 1.0)](../../../specification#region). Equivalent to `tile.boundingVolume.region`.

* Type: `ARRAY`
* Component type: `FLOAT64`
* Component count: `6`

#### `TILE_BOUNDING_SPHERE`

The bounding volume of the tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](../../../specification#sphere). Equivalent to `tile.boundingVolume.sphere`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

#### `TILE_MINIMUM_HEIGHT`

The minimum height of the tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `TILE_BOUNDING_REGION` and `tile.boundingVolume.region`.

* Type: `FLOAT32` or `FLOAT64`

#### `TILE_MAXIMUM_HEIGHT`

The maximum height of the tile above (or below) the WGS84 ellipsoid. Equivalent to maximum height component of `TILE_BOUNDING_REGION` and `tile.boundingVolume.region`.

* Type: `FLOAT32` or `FLOAT64`

#### `TILE_HORIZON_OCCLUSION_POINT`

The horizon occlusion point of the tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire tile is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.

* Type: `VEC3`
* Component type: `FLOAT32` or `FLOAT64`

> **Implementation Note**: `TILE_HORIZON_OCCLUSION_POINT` should account for all content in a tile and its descendants, whereas `CONTENT_HORIZON_OCCLUSION_POINT` should only account for content in a tile. When the two values are equivalent, only `TILE_HORIZON_OCCLUSION_POINT` should be specified.

#### `TILE_GEOMETRIC_ERROR`

The geometric error of the tile. Equivalent to `tile.geometricError`.

* Type: `FLOAT32` or `FLOAT64`

### Content

#### Overview

`CONTENT_*` semantics provide meaning for properties associated with a particular tile content, and should take precedence over equivalent metadata on the containing tile.

`CONTENT_BOUNDING_BOX`, `CONTENT_BOUNDING_REGION`, and `CONTENT_BOUNDING_SPHERE` semantics each define a tighter bounding volume for tile contents than the bounding volume of the tile. If more than one of these semantics are available for the same content, clients may select the most appropriate option based on use case and performance requirements.

#### `CONTENT_BOUNDING_BOX`

The bounding volume of the content of a tile, expressed as a [box (as defined by 3D Tiles 1.0)](../../../specification#box). Equivalent to `tile.content.boundingVolume.box`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `12`

#### `CONTENT_BOUNDING_REGION`

The bounding volume of the content of a tile, expressed as a [region (as defined by 3D Tiles 1.0)](../../../specification#region). Equivalent to `tile.content.boundingVolume.region`.

* Type: `ARRAY`
* Component type: `FLOAT64`
* Component count: `6`

#### `CONTENT_BOUNDING_SPHERE`

The bounding volume of the content of  tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](../../../specification#sphere). Equivalent to `tile.content.boundingVolume.sphere`.

* Type: `ARRAY`
* Component type: `FLOAT32` or `FLOAT64`
* Component count: `4`

#### `CONTENT_MINIMUM_HEIGHT`

The minimum height of the content of a tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `CONTENT_BOUNDING_REGION` and `tile.content.boundingVolume.region`.

* Type: `FLOAT32` or `FLOAT64`

#### `CONTENT_MAXIMUM_HEIGHT`

The maximum height of the content of a tile above (or below) the WGS84 ellipsoid. Equivalent to maximum height component of `CONTENT_BOUNDING_REGION` and `tile.content.boundingVolume.region`.

* Type: `FLOAT32` or `FLOAT64`

#### `CONTENT_HORIZON_OCCLUSION_POINT`

The horizon occlusion point of the content of a tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire content is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.

* Type: `VEC3`
* Component type: `FLOAT32` or `FLOAT64`

> **Implementation Note**: `TILE_HORIZON_OCCLUSION_POINT` should account for all content in a tile and its descendants, whereas `CONTENT_HORIZON_OCCLUSION_POINT` should only account for content in a tile. When the two values are equivalent, only `TILE_HORIZON_OCCLUSION_POINT` should be specified.

## Revision History

* **Version 1.0.0** February 25, 2021
  * Initial draft
* **Version 2.0.0** October 2021
  * Reorganize document to distinguish general and 3D Tiles-specific semantics
  * Added clarification for units of distance and angles
