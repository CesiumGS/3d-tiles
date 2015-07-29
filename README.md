# 3D Tiles

Specification for streaming massive heterogeneous 3D geospatial datasets.

Contents:

* [Status](#status)
* [Introduction](#introduction)
* [Tile Formats](#tileFormats)
* [Q&A](#qa)

Discuss 3D Tiles on the [Cesium forum](http://cesiumjs.org/forum.html).

<p align="center">
Created by the <a href="http://cesiumjs.org/">Cesium team</a> and built on <a href="https://www.khronos.org/gltf">glTF</a>.<br/>

<a href="http://cesiumjs.org/"><img src="figures/cesium.jpg" height="40" /></a> <a href="https://www.khronos.org/gltf"><img src="figures/gltf.png" height="40" /></a>
</p>

---

<a name="status">
## Status

Topic  | Status
---|---
tiles.json  | :white_check_mark: **Pretty solid**, but will expand as we add new tile formats
Batched 3D Model ([b3dm](b3dm/README.md))  | :white_check_mark: **Pretty solid**, only minor changes expected
Points ([pnts](pnts/README.md))  | :rocket: **Prototype**, needs compression and additional attributes
Composite Tile  | :white_circle: **Not started**
Instanced 3D Model  | :white_circle: **Not started**
Vector Data  | :white_circle: **Not started**
Massive Model  | :white_circle: **Not started**
Terrain  | :white_circle: **Not started**, [quantized-mesh](https://cesiumjs.org/data-and-assets/terrain/formats/quantized-mesh-1.0.html) is a good starting point
Imposters  | :white_circle: **Not started**, could be covered by Vector Data
Stars  | :white_circle: **Not started**

<a name="introduction">
## Introduction

For an introduction to the motivation and principles of 3D Tiles, see [Introducing 3D Tiles](http://cesiumjs.org//2015/08/10/Introducing-3D-Tiles/) on the Cesium blog.  Here, we start with the format.

In 3D Tiles, a _tileset_ is a set of _tiles_ organized in a hierarchical spatial data structure, the _tree_.  Each tile has a bounding volume completely enclosing its contents, and the tree has spatial coherence; the bounding volume for child tiles are completely inside the parent's bounding volume.  To allow flexibility, the tree can be any data structure with this property, including quadtrees, octrees, k-d trees, multi-way k-d trees, and grids.

_TODO: tree and BV image_

Currently, the bounding volume is a "box" defined by minimum and maximum longitude, latitude, and height (relative to the WGS84 ellipsoid).  We expect 3D Tiles will different bounding volumes ([see the Q&A below](What-bounding-volume-do-tiles-use)).

The metadata for each tile - not the actual contents - are defined in JSON.  For example:
```json


<a name="tileFormats">
## Tile Formats
* [Batched 3D Model](b3dm/README.md) - 3D cities
* [Points](pnts/README.md) - point clouds

<a name="qa">
## Roadmap Q&A

_TODO: TOC_

<a name="General-qa">
### General Q&A

<a name="Can-I-use-3D-Tiles-today">
#### Can I use 3D Tiles today?

We expect the initial 3D Tiles spec to evolve until spring 2016.  If you are OK with things changing, then, yes, jump in.  The Cesium implementation is in the [3d-tiles](https://github.com/AnalyticalGraphicsInc/cesium/tree/3d-tiles) branch.

<a name="Are-3D-Tiles-specific-to-Cesium">
#### Are 3D Tiles specific to Cesium?

No, 3D Tiles are a general spec for streaming massive heterogeneous 3D geospatial datasets.  The Cesium team started this initiative because we need an open format optimized for streaming 3D content to Cesium.  [AGI](http://www.agi.com/), the founders of Cesium, is also developing tools for creating 3D Tiles.  We expect to see other visualization engines and conversion tools use 3D Tiles.

<a name="What-is-the-relationship-between-3D-Tiles-and-glTF">
#### What is the relationship between 3D Tiles and glTF

[glTF](https://www.khronos.org/gltf), the runtime asset format for WebGL, is an emerging open-standard for 3D models from Khronos (the same group who does WebGL and COLLADA).  Cesium uses glTF as its 3D model format, and the Cesium team contributes heavily to the glTF spec and open-source COLLADA2GLTF converter.  We recommend using glTF in Cesium for individual assets, e.g., an aircraft, a character, or a 3D building.

We created 3D Tiles for streaming massive geospatial datasets where a single glTF model would be prohibitive.  Given that glTF is optimized for rendering, Cesium has a well-tested glTF loader, and there are existing conversion tools for glTF, 3D Tiles use glTF for some tile types formats [b3dm](b3dm/README.md) (used for 3D buildings).  In particular, we introduced a binary extension ([CESIUM_binary_glTF](https://github.com/KhronosGroup/glTF/blob/new-extensions/extensions/CESIUM_binary_glTF/README.md)) in order to embed glTF into binary tiles and avoid base64-encoding or multiple file overhead.

Taking this approach allows us to improve Cesium, glTF, and 3D Tiles at the same time, e.g., when we add mesh compression to glTF, it benefits 3D models in Cesium, the glTF ecosystem, and 3D Tiles.

<a name="Do-3D-Tiles-support-runtime-editing">
#### Do 3D Tiles support runtime editing?

A common use case for 3D buildings is to stream a city dataset, color each building based on one or more properties, e.g., its height, and then hide a few buildings, and replace them with high-resolution 3D buildings.  With 3D Tiles, this type of editing can be done at runtime.

The general case runtime editing of geometry on a building, vector data, etc., and then efficiently saving those changes in a 3D Tile will be possible, but unlikely to be in the 1.0 spec.  Stylization is much easier since it can be applied at runtime without modification to the 3D Tiles tree.

<a name="Will-3D-Tiles-include-terrain">
#### Will 3D Tiles include terrain?

Yes, a [quantized-mesh](https://cesiumjs.org/data-and-assets/terrain/formats/quantized-mesh-1.0.html)-like tile would fit well with 3D Tiles and allow Cesium to use the same streaming code (we say _quantized-mesh-like_ because some of the metadata, e.g., for bounding volumes and horizon culling, may be organized differently or moved to tiles.json).

However, since Cesium already streams terrain well, we are not focused on this in the short-term.

<a name="Will-3D-Tiles-include-imagery">
#### Will 3D Tiles include imagery?

Yes, there is an opportunity to provide an optimized base layer of terrain and imagery (similar to how a 3D model contains both geometry and textures).  There is also the open research problem of how to tile imagery for 3D?  In 2D, only one LOD (`z` layer) is used for a given view.  In 3D, especially when looking towards the horizon, tiles from multiple LODs are adjacent to each other.  How do we make the seams look good?  This will likely require tool and runtime support.

Similar to terrain, since Cesium already streams imagery, we are not focused on this in the short-term.

<a name="Will-3D-Tiles-replace-KML">
#### Will 3D Tiles replace KML?

Conservatively, by the end of 2016, we believe 3D Tiles can replace KML.  KML regions and network links are a clunky approach to streaming massive 3D geospatial datasets on the web.  3D Tiles are built for the web and optimized for streaming; true HLOD is used, polygons do not need to be triangulated, and so on.

<a name="Technical-qa">
### Technical Q&A

<a name="How-do-3D-Tiles-support-heterogeneous-datasets">
#### How do 3D Tiles support heterogeneous datasets?

Geospatial datasets are heterogeneous; 3D buildings are different from terrain, which is different from point clouds, which are different from vector data, and so on.

3D Tiles support heterogeneous data by allowing a different content type for each tile in a tileset, e.g., a tileset may contain tiles for 3D buildings, tiles for instanced 3D trees, and tiles for point clouds, all using different tile types.

We expect 3D Tiles will also support heterogeneous datasets by concatenating different tile types into one tile, a_composite_; in the example above, a tile may have a short header followed by the contents for the 3D buildings, instanced 3D trees, and point clouds.

Supporting heterogeneous datasets with both inter-tile (different tile types in the same tileset) and intra-tile (different tile types in the same tile) options will allow conversion tools to make trade-offs between number of requests, optimal type-specific subdivision, and how visible/hidden layers are streamed.

<a name="Will-tiles.json-be-part-of-the-final-3D-Tiles-spec">
#### Will tiles.json be part of the final 3D Tiles spec?

Yes, in one form or another.  There will always be a need to know metadata about the tileset and about tiles that are not yet loaded, e.g., so only visible tiles are request.  However, when scaling to millions of tiles, a single tiles.json with metadata for the entire tree will be prohibitively big.

There's a few ways we may solve this:
* Trees of trees.  A content type of `"3dtile"` is already planned and will allow conversion tools to chunk up a tileset into any number of tiles.json files that reference each other.
* Moving subtree metadata to the tile payload instead of tiles.json.  Each tile would have a header with, for example, the bounding volumes of each child, and perhaps grandchildren and so on.
* Explicit tile layout like traditional tiling schemes (e.g., TMS's `z/y/x`).  The challenge is that this implicitly assumes a spatial subdivision, where as 3D Tiles strive to be general enough to support quadtrees, octrees, k-d trees, and so on.

<a name="What-bounding-volume-do-tiles-use">
#### What bounding volume do tiles use?

Currently, tiles use a box defined by minimum and maximum longitude, latitude, and height (relative to the WGS84 ellipsoid).  Note that this is not actually a box in Cartesian coordinates since the planes perpendicular to the ground are along the geodetic surface normal.

This bounding volume works OK for the general case, but 3D Tiles will likely support other bounding volumes such as bounding spheres and oriented bounding boxes defined in WGS84 Cartesian coordinates.  The later will allow, for example, better fit bounding volumes for cities not aligned with a line of longitude or latitude, and for arbitrary point clouds.

_TODO: screenshot_

<a name="Will-3D-Tiles-support-horizon-culling">
#### Will 3D Tiles support horizon culling?

Since [horizon culling](http://cesiumjs.org/2013/04/25/Horizon-culling/) is useful for terrain, 3D Tiles will likely support the metadata needed for it.  We haven't considered it yet since our initial work with 3D Tiles was for 3D buildings where horizon culling is not effective.

<a name="How-do-I-request-the-tiles-for-Level-n">
#### How do I request the tiles for Level `n`?

More generally, how do we support the use case for when the viewer is zoom in very close to terrain, for example, and we do not want to load all the parent tiles toward the root of the tree; instead, we want to skip right to the high-resolution tiles needed for the current 3D view?

This 3D Tiles topic needs additional research, but the answer is basically the same as above: either the skeleton of the tree can be quickly traversed to find the desired tiles or an explicit layout scheme will be used for specific subdivisions.

<a name="How-are-cracks-between-tiles-with-vector-data-handled">
#### How are cracks between tiles with vector data handled?

Unlike 2D, in 3D, we expect adjacent to be from different LODs so, for example, in the distance, lower resolution tiles are used.  Adjacent tiles from different LODs can lead to an artifact called _cracking_ where there are gaps.  For terrain, this is generally handled by dropping slightly angled _skirts_ around each tile to fill the gap.  For 3D buildings, this is handled by extended by the tile boundary to fully include buildings on the edge.  For vector data, this is an open research problem that we need to solve.  This could invole boundary-aware simplication or runtime stitching. 

<a name="When-using-replacement-refinement-can-multiple-children-be-combined-into-one-request">
#### When using replacement refinement, can multiple children be combined into one request?

Often when using replacement refinement, a tile's children is not rendered until all children are downloaded (an exception, for example, is unstructured data like point clouds where clipping planes can be used to mask out parts of the parent tile where the children are load; naively using the same approach with terrain or an arbitrary 3D model results in cracking).

We may design 3D Tiles to support downloading all children in a single request by allowing tiles.json to point to a subset of a file for a tile's content similiar to glTF [buffer](https://github.com/KhronosGroup/glTF/blob/master/specification/buffer.schema.json) and [bufferView](https://github.com/KhronosGroup/glTF/blob/master/specification/bufferView.schema.json).  [HTTP/2](http://chimera.labs.oreilly.com/books/1230000000545/ch12.html#_brief_history_of_spdy_and_http_2) will also make the overhead of multiple requests less important.

<a name="What-texture-compression-do-3D-Tiles-use">
#### What texture compression do 3D Tiles use?

3D Tiles will support the same texture compression that glTF [will support](https://github.com/KhronosGroup/glTF/issues/59).  In addition, we need to consider how well GPU formats compress compared to, for example, jpeg.  Some desktop game engines use jpeg, then decompress and recompress to a GPU format in a thread.  The CPU overhead for this approach may be too high for JavaScript and Web Workers.
