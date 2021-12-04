# 3D Metadata Semantic Reference

## Overview

This document provides common definitions of meaning ("semantics") used by metadata properties in 3D Tiles 1.0 and glTF 2.0. Tileset authors may define their own application- or domain-specific semantics separately.

Semantics describe how properties should be interpreted. For example, an application that encounters the `ID` or `NAME` semantics while parsing a dataset may use these values as unique identifiers or human-readable labels, respectively.

Each semantic is defined in terms of its meaning, and the datatypes it may assume. Datatype specifications include "type", "component type", and "component count" attributes as defined by the [3D Metadata Specification](../).

For use of semantics in extensions of specific standards, see:

* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata) (3D Tiles 1.0) — Assigns metadata to tilesets, tiles, or tile contents
* [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) (glTF 2.0) —  Assigns metadata to subcomponents ("features") of geometry or textures

## General

#### Overview

Throughout this section, the term "entity" refers to any conceptual object with which a property value (as defined in the [3D Metadata Specification](../)) may be associated. Examples of entities include tilesets, tiles, and tile contents in 3D Tiles, or groups of vertices and texels in glTF 2.0 assets. Additional types of entities may be defined by other specifications or applications.

#### General Semantics

Semantic|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description
--|--|--
`ID`|<ul><li>Type: `SINGLE`</li><li>Component type: `STRING`</li></ul>|The unique identifier for the entity.
`NAME`|<ul><li>Type: `SINGLE`</li><li>Component type: `STRING`</li></ul>|The name of the entity. Names should be human-readable, and do not have to be unique.
`DESCRIPTION`|<ul><li>Type: `SINGLE`</li><li>Component type: `STRING`</li></ul>|Description of the entity. Typically at least a phrase, and possibly several sentences or paragraphs.

## 3D Tiles

### Overview

Semantics for 3D Tiles are assigned in relationship to a tile or tile content, as defined by the 3D Tiles 1.0 specification. When associated with other types of entities, these semantics may have invalid or undefined meanings.

Units for all linear distances are meters, and all angles are radians.

### Tile

#### Overview

`TILE_*` semantics provide meaning for properties associated with a particular tile, and should take precedence over equivalent metadata on parent objects, as well as over values derived from subdivision schemes like [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling).

In particular, `TILE_BOUNDING_BOX`, `TILE_BOUNDING_REGION`, and `TILE_BOUNDING_SPHERE` semantics each define a more specific bounding volume for a tile than is implicitly calculated from [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). If more than one of these semantics are available for a tile, clients may select the most appropriate option based on use case and performance requirements.

#### Tile Semantics

Semantic|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description
--|--|--
`TILE_BOUNDING_BOX`|<ul><li>Type: `ARRAY`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Component count: `12`</li></ul>|The bounding volume of the tile, expressed as a [box (as defined by 3D Tiles 1.0)](../../../specification#box). Equivalent to `tile.boundingVolume.box`.
`TILE_BOUNDING_REGION`|<ul><li>Type: `ARRAY`</li><li>Component type: `FLOAT64`</li><li>Component count: `6`</li></ul>|The bounding volume of the tile, expressed as a [region (as defined by 3D Tiles 1.0)](../../../specification#region). Equivalent to `tile.boundingVolume.region`.
`TILE_BOUNDING_SPHERE`|<ul><li>Type: `ARRAY`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Component count: `4`</li></ul>|The bounding volume of the tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](../../../specification#sphere). Equivalent to `tile.boundingVolume.sphere`.
`TILE_MINIMUM_HEIGHT`|<ul><li>Type: `SINGLE`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The minimum height of the tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `TILE_BOUNDING_REGION` and `tile.boundingVolume.region`.
`TILE_MAXIMUM_HEIGHT`|<ul><li>Type: `SINGLE`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The maximum height of the tile above (or below) the WGS84 ellipsoid. Equivalent to maximum height component of `TILE_BOUNDING_REGION` and `tile.boundingVolume.region`.
`TILE_HORIZON_OCCLUSION_POINT`<sup>1</sup>|<ul><li>Type: `VEC3`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The horizon occlusion point of the tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire tile is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.
`TILE_GEOMETRIC_ERROR`|<ul><li>Type: `SINGLE`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The geometric error of the tile. Equivalent to `tile.geometricError`.

<small><sup>1</sup> `TILE_HORIZON_OCCLUSION_POINT` should account for all content in a tile and its descendants, whereas `CONTENT_HORIZON_OCCLUSION_POINT` should only account for content in a tile. When the two values are equivalent, only `TILE_HORIZON_OCCLUSION_POINT` should be specified.</small>

### Content

#### Overview

`CONTENT_*` semantics provide meaning for properties associated with the content of a tile, and may be more specific to that content than properties of the containing tile. When a tile has multiple contents (e.g. with [3DTILES_multiple_contents](../../../extensions/3DTILES_multiple_contents)), a `CONTENT_*` property may describe all tile contents or a single content entry, depending on whether the property is located in the tile or tile content definition.

`CONTENT_BOUNDING_BOX`, `CONTENT_BOUNDING_REGION`, and `CONTENT_BOUNDING_SPHERE` semantics each define a more specific bounding volume for tile contents than the bounding volume of the tile. If more than one of these semantics are available for the same content, clients may select the most appropriate option based on use case and performance requirements.

#### Content Semantics

Semantic|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description
--|--|--
`CONTENT_BOUNDING_BOX`|<ul><li>Type: `ARRAY`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Component count: `12`</li></ul>|The bounding volume of the content of a tile, expressed as a [box (as defined by 3D Tiles 1.0)](../../../specification#box). Equivalent to `tile.content.boundingVolume.box`.
`CONTENT_BOUNDING_REGION`|<ul><li>Type: `ARRAY`</li><li>Component type: `FLOAT64`</li><li>Component count: `6`</li></ul>|The bounding volume of the content of a tile, expressed as a [region (as defined by 3D Tiles 1.0)](../../../specification#region). Equivalent to `tile.content.boundingVolume.region`.
`CONTENT_BOUNDING_SPHERE`|<ul><li>Type: `ARRAY`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Component count: `4`</li></ul>|The bounding volume of the content of a tile, expressed as a [sphere (as defined by 3D Tiles 1.0)](../../../specification#sphere). Equivalent to `tile.content.boundingVolume.sphere`.
`CONTENT_MINIMUM_HEIGHT`|<ul><li>Type: `SINGLE`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The minimum height of the content of a tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `CONTENT_BOUNDING_REGION` and `tile.content.boundingVolume.region`.
`CONTENT_MAXIMUM_HEIGHT`|<ul><li>Type: `SINGLE`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The minimum height of the content of a tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `CONTENT_BOUNDING_REGION` and `tile.content.boundingVolume.region`.
`CONTENT_HORIZON_OCCLUSION_POINT`<sup>1</sup>|<ul><li>Type: `VEC3`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The horizon occlusion point of the content of a tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire content is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.

<small><sup>1</sup>`TILE_HORIZON_OCCLUSION_POINT` should account for all content in a tile and its descendants, whereas `CONTENT_HORIZON_OCCLUSION_POINT` should only account for content in a tile. When the two values are equivalent, only `TILE_HORIZON_OCCLUSION_POINT` should be specified.</small>

## Revision History

* **Version 1.0.0** February 25, 2021
  * Initial draft
* **Version 2.0.0** October 2021
  * Reorganize document to distinguish general and 3D Tiles-specific semantics
  * Added clarification for units of distance and angles
  * Added `DESCRIPTION` semantic
  * Changed `TILE_HORIZON_OCCLUSION_POINT` and `CONTENT_HORIZON_OCCLUSION_POINT` type from `ARRAY` to `VEC3`
