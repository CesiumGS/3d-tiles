# 3D Metadata Semantic Reference

## Overview

This document provides common definitions of meaning ("semantics") used by metadata properties in 3D Tiles and glTF. Tileset authors may define their own application- or domain-specific semantics separately.

Semantics describe how properties should be interpreted. For example, an application that encounters the `ID` or `NAME` semantics while parsing a dataset may use these values as unique identifiers or human-readable labels, respectively.

Each semantic is defined in terms of its meaning, and the datatypes it may assume. Datatype specifications include "type" as defined by the [3D Metadata Specification](../). When applicable they may also include "component type", "array", and "count".

For use of semantics in extensions of specific standards, see:

* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata) (3D Tiles 1.0)
* [`EXT_structural_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_structural_metadata) (glTF 2.0)

## General

#### Overview

Throughout this section, the term "entity" refers to any conceptual object with which a property value (as defined in the [3D Metadata Specification](../)) may be associated. Examples of entities include tilesets, tiles, and tile contents in 3D Tiles, or groups of vertices and texels in glTF 2.0 assets. Additional types of entities may be defined by other specifications or applications.

#### General Semantics

Semantic|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description
--|--|--
`ID`|<ul><li>Type: `STRING`</li></ul>|The unique identifier for the entity.
`NAME`|<ul><li>Type: `STRING`</li></ul>|The name of the entity. Names should be human-readable, and do not have to be unique.
`DESCRIPTION`|<ul><li>Type: `STRING`</li></ul>|Description of the entity. Typically at least a phrase, and possibly several sentences or paragraphs.
`ATTRIBUTION_IDS`|<ul><li>Type: `SCALAR`</li><li>Component type: `UINT8`, `UINT16`, `UINT32`, or `UINT64`</li><li>Array: `true`</li></ul>|List of attribution IDs that index into a global list of attribution strings. This semantic may be assigned to metadata at any level of granularity including tileset, group, subtree, tile, content, feature, vertex, and texel granularity. The global list of attribution strings is located in a tileset or subtree with the property semantic `ATTRIBUTION_STRINGS`. The following precedence order is used to locate the attribution strings: first the containing subtree (if applicable), then the containing external tileset (if applicable), and finally the root tileset.
`ATTRIBUTION_STRINGS`|<ul><li>Type: `STRING`</li><li>Array: `true`</li></ul>|List of attribution strings. Each string contains information about a data provider or copyright text. Text may include embedded markup languages such as HTML. This semantic may be assigned to metadata at any granularity (wherever `STRING` property values can be encoded). When used in combination with `ATTRIBUTION_IDS` it is assigned to subtrees and tilesets.

## 3D Tiles

### Overview

Semantics for 3D Tiles are assigned in relationship to a tileset, subtree, tile, or tile content, as defined by the 3D Tiles specification. When associated with other types of entities, these semantics may have invalid or undefined meanings.

Units for all linear distances are meters, and all angles are radians.

### Tileset

#### Overview

`TILESET_*` semantics provide meaning for properties associated with a tileset.

#### Tileset Semantics

Semantic|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description
--|--|--
`TILESET_FEATURE_ID_LABELS`|<ul><li>Type: `STRING`</li><li>Array: `true`</li></ul>|The union of all the feature ID labels in glTF content using the [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) and [`EXT_instance_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_instance_features) extensions.
`TILESET_CRS_GEOCENTRIC`|<ul><li>Type: `STRING`</li></ul>|The geocentric coordinate reference system (CRS) of the tileset. Known values include, but are not limited to:<ul><li>`"EPSG:4978"` - WGS 84</li><li>`"EPSG:7656"` - WGS 84 (G730)</li><li>`"EPSG:7658"` - WGS 84 (G873)</li><li>`"EPSG:7660"` - WGS 84 (G1150)</li><li>`"EPSG:7662"` - WGS 84 (G1674)</li><li>`"EPSG:7664"` - WGS 84 (G1762)</li><li>`"EPSG:9753"` - WGS 84 (G2139)</li></ul>`region` bounding volumes are assumed to use the same reference ellipsoid as the geocentric coordinate reference system specified here.<br><br>For more details on coordinate reference systems in 3D Tiles, see [Coordinate Reference System (CRS)](../../#coordinate-reference-system-crs).
`TILESET_CRS_COORDINATE_EPOCH`|<ul><li>Type: `STRING`</li>|The coordinate epoch for coordinates that are referenced to a dynamic CRS such as WGS 84. Coordinates include glTF vertex positions after transforms have been applied — see [glTF transforms](https://github.com/CesiumGS/3d-tiles/tree/main/specification#gltf-transforms). Expressed as a decimal year (e.g. `"2019.81"`). See [WKT representation of coordinate epoch and coordinate metadata](http://docs.opengeospatial.org/is/18-010r7/18-010r7.html#128) for more details.

### Tile

#### Overview

`TILE_*` semantics provide meaning for properties associated with a particular tile, and should take precedence over equivalent metadata on parent objects, as well as over values derived from subdivision schemes like [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling).

If property values are missing, either because the property is omitted or the property table contains `noData` values, the original tile properties are used, such as those explicitly defined in tileset JSON or implicitly computed from subdivision schemes like [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling).

In particular, `TILE_BOUNDING_BOX`, `TILE_BOUNDING_REGION`, and `TILE_BOUNDING_SPHERE` semantics each define a more specific bounding volume for a tile than is implicitly calculated from [3DTILES_implicit_tiling](../../../extensions/3DTILES_implicit_tiling). If more than one of these semantics are available for a tile, clients may select the most appropriate option based on use case and performance requirements.

#### Tile Semantics

Semantic|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description
--|--|--
`TILE_BOUNDING_BOX`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Array: `true`</li><li>Count: `12`</li></ul>|The bounding volume of the tile, expressed as a [box](../../../specification#box). Equivalent to `tile.boundingVolume.box`.
`TILE_BOUNDING_REGION`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT64`</li><li>Array: `true`</li><li>Count: `6`</li></ul>|The bounding volume of the tile, expressed as a [region](../../../specification#region). Equivalent to `tile.boundingVolume.region`.
`TILE_BOUNDING_SPHERE`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Array: `true`</li><li>Count: `4`</li></ul>|The bounding volume of the tile, expressed as a [sphere](../../../specification#sphere). Equivalent to `tile.boundingVolume.sphere`.
`TILE_BOUNDING_S2_CELL`|<ul><li>Type: `SCALAR`</li><li>Component type: `UINT64`</li></ul>|The bounding volume of the tile, expressed as an [S2 Cell ID](../../../extensions/3DTILES_bounding_volume_S2#cell-ids) using the 64-bit representation instead of the hexadecimal representation.
`TILE_MINIMUM_HEIGHT`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The minimum height of the tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `TILE_BOUNDING_REGION` and `tile.boundingVolume.region`. Also equivalent to `tile.boundingVolume.s2.minimumHeight`.
`TILE_MAXIMUM_HEIGHT`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The maximum height of the tile above (or below) the WGS84 ellipsoid. Equivalent to maximum height component of `TILE_BOUNDING_REGION` and `tile.boundingVolume.region`. Also equivalent to `tile.boundingVolume.s2.maximumHeight`.
`TILE_HORIZON_OCCLUSION_POINT`<sup>1</sup>|<ul><li>Type: `VEC3`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The horizon occlusion point of the tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire tile is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.
`TILE_GEOMETRIC_ERROR`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The geometric error of the tile. Equivalent to `tile.geometricError`.
`TILE_REFINE`|<ul><li>Type: `SCALAR`</li><li>Component type: `UINT8`</li></ul>|The tile refinement type. Valid values are `0` (`"ADD"`) and `1` (`"REPLACE"`). Equivalent to `tile.refine`.
`TILE_TRANSFORM`|<ul><li>Type: `MAT4`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The tile transform. Equivalent to `tile.transform`.


<small><sup>1</sup> `TILE_HORIZON_OCCLUSION_POINT` should account for all content in a tile and its descendants, whereas `CONTENT_HORIZON_OCCLUSION_POINT` should only account for content in a tile. When the two values are equivalent, only `TILE_HORIZON_OCCLUSION_POINT` should be specified.</small>

### Content

#### Overview

`CONTENT_*` semantics provide meaning for properties associated with the content of a tile, and may be more specific to that content than properties of the containing tile.

`CONTENT_BOUNDING_BOX`, `CONTENT_BOUNDING_REGION`, and `CONTENT_BOUNDING_SPHERE` semantics each define a more specific bounding volume for tile contents than the bounding volume of the tile. If more than one of these semantics are available for the same content, clients may select the most appropriate option based on use case and performance requirements.

#### Content Semantics

Semantic|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description
--|--|--
`CONTENT_BOUNDING_BOX`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Array: `true`</li><li>Count: `12`</li></ul>|The bounding volume of the content of a tile, expressed as a [box](../../../specification#box). Equivalent to `tile.content.boundingVolume.box`.
`CONTENT_BOUNDING_REGION`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT64`</li><li>Array: `true`</li><li>Count: `6`</li></ul>|The bounding volume of the content of a tile, expressed as a [region](../../../specification#region). Equivalent to `tile.content.boundingVolume.region`.
`CONTENT_BOUNDING_SPHERE`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li><li>Array: `true`</li><li>Count: `4`</li></ul>|The bounding volume of the content of a tile, expressed as a [sphere](../../../specification#sphere). Equivalent to `tile.content.boundingVolume.sphere`.
`CONTENT_BOUNDING_S2_CELL`|<ul><li>Type: `SCALAR`</li><li>Component type: `UINT64`</li></ul>|The bounding volume of the content of a tile, expressed as an [S2 Cell ID](../../../extensions/3DTILES_bounding_volume_S2#cell-ids) using the 64-bit representation instead of the hexadecimal representation.
`CONTENT_MINIMUM_HEIGHT`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The minimum height of the content of a tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `CONTENT_BOUNDING_REGION` and `tile.content.boundingVolume.region`. Also equivalent to `tile.content.boundingVolume.s2.minimumHeight`.
`CONTENT_MAXIMUM_HEIGHT`|<ul><li>Type: `SCALAR`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The minimum height of the content of a tile above (or below) the WGS84 ellipsoid. Equivalent to minimum height component of `CONTENT_BOUNDING_REGION` and `tile.content.boundingVolume.region`. Also equivalent to `tile.content.boundingVolume.s2.maximumHeight`.
<sub>`CONTENT_HORIZON_OCCLUSION_POINT`</sub><sup>1</sup>|<ul><li>Type: `VEC3`</li><li>Component type: `FLOAT32` or `FLOAT64`</li></ul>|The horizon occlusion point of the content of a tile expressed in an ellipsoid-scaled fixed frame. If this point is below the horizon, the entire content is below the horizon. See [Horizon Culling](https://cesium.com/blog/2013/04/25/horizon-culling/) for more information.
`CONTENT_URI`|<ul><li>Type: `STRING`</li></ul>|The content uri. Overrides the implicit tile's generated content uri. Equivalent to `tile.content.uri`.
`CONTENT_GROUP_ID`|<ul><li>Type: `SCALAR`</li><li>Component type: `UINT8`, `UINT16`, `UINT32`, or `UINT64`</li></ul>|The content group ID. Equivalent to `tile.content.group`.

<small><sup>1</sup>`TILE_HORIZON_OCCLUSION_POINT` should account for all content in a tile and its descendants, whereas `CONTENT_HORIZON_OCCLUSION_POINT` should only account for content in a tile. When the two values are equivalent, only `TILE_HORIZON_OCCLUSION_POINT` should be specified.</small>
