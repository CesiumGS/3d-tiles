# 3D Tiles

Specification for streaming massive heterogeneous 3D geospatial datasets.

Contents:

* [Status](#status)
* [Content Types](#contentTypes)
* [Q&A](#qa)

Created by the [Cesium team](http://cesiumjs.org/) and built on [glTF](https://www.khronos.org/gltf).

<a href="http://cesiumjs.org/"><img src="figures/cesium.jpg" height="40" /></a> <a href="https://www.khronos.org/gltf"><img src="figures/gltf.png" height="40" /></a>

Discuss 3D Tiles on the [Cesium forum](http://cesiumjs.org/forum.html).

---

<a name="status">
## Status

Topic  | Status
---|---
tiles.json  | :white_check_mark: **Pretty solid**, but will expand as we add new content types
Batched 3D Model ([b3dm](b3dm/README.md))  | :white_check_mark: **Pretty solid**, only minor changes expected
Points ([pnts](pnts/README.md))  | :rocket: **Prototype**, needs compression and additional attributes
Composite Tile  | :white_circle: **Not started**
Instanced 3D Model  | :white_circle: **Not started**
Vector Data  | :white_circle: **Not started**
Massive Model  | :white_circle: **Not started**
Terrain  | :white_circle: **Not started**

<a name="contentTypes">
## Content Types
* [Batched 3D Model](b3dm/README.md) - 3D cities
* [Points](pnts/README.md) - point clouds

<a name="qa">
## Q&A

**TODO: TOC**

### General Q&A

#### Can I use 3D Tiles today?

We expect the 3D Tiles specification to evolve until spring 2015.  If you are OK with things changing, then, yes, jump in.  The Cesium implementation is in the [3d-tiles branch](https://github.com/AnalyticalGraphicsInc/cesium/tree/3d-tiles).

#### Are 3D Tiles specific to Cesium?

No, 3D Tiles are a general specification for streaming massive heterogeneous 3D geospatial datasets.  The Cesium team started this initiative because we need an open format optimized for streaming 3D content to Cesium.  [AGI](http://www.agi.com/), the founders of Cesium, is also developing tools for creating 3D Tiles.  We expect to see other visualization engines and conversion tools use 3D Tiles.

#### What is the relationship between 3D Tiles and glTF

[glTF](https://www.khronos.org/gltf), the runtime asset format for WebGL, is an emerging open-standard for 3D models from Khronos (the same group who does WebGL and COLLADA).  Cesium uses glTF as its 3D model format, and the Cesium team contributes heavily to the glTF spec and open-source COLLADA2GLTF converter.  We recommend using glTF in Cesium for individual assets, e.g., an aircraft, a character, or a 3D building.

We created 3D Tiles for streaming massive geospatial datasets where a single glTF model would be prohibitively big.  Given that glTF is optimized for rendering, Cesium has a well-tested glTF loader, and there are existing conversion tools for glTF, 3D Tiles use glTF for some tile types like [b3dm](b3dm/README.md) (used for 3D buildings).  In particular, we introduced a binary extension ([CESIUM_binary_glTF](https://github.com/KhronosGroup/glTF/blob/new-extensions/extensions/CESIUM_binary_glTF/README.md)) in order to embed glTF into binary tiles and avoid base64-encoding or multiple file overhead.

Taking this approach allows us to improve Cesium, glTF, and 3D Tiles at the same time, e.g., when we add mesh compression to glTF, it benefits 3D models in Cesium, the glTF ecosystem, and 3D Tiles.

_TODO: glTF supports general models and has a material system - as opposed to building something custom for 3D buildings_

#### Will 3D Tiles include terrain?

Yes, a [quantized-mesh](https://cesiumjs.org/data-and-assets/terrain/formats/quantized-mesh-1.0.html)-like tile would fit well with 3D Tiles and allow Cesium to use the same streaming code (we say _quantized-mesh-like_ because some of the metadata, e.g., for bounding volumes and horizon culling, may be organized differently or moved to tiles.json).

However, since Cesium already streams terrain well, we are not focused on this in the short-term.

#### Will 3D Tiles include imagery?

Yes, there is an opportunity to provide an optimized base layer of terrain and imagery (similar to how a 3D model contains both geometry and textures).  There is also the open research problem of how to tile imagery for 3D?  In 2D, only one LOD (`z` layer) is used for a given view.  In 3D, especially when looking towards the horizon, tiles from multiple LODs are adjacent to each other.  How do we make the seams look good?  This will likely require tool and runtime support.

Similar to terrain, since Cesium already streams imagery, we are not focused on this in the short-term.

#### Will 3D Tiles replace KML?

Conservatively, by the end of 2016, we believe 3D Tiles can replace KML.  KML regions and network links are a clunky approach to streaming massive 3D geospatial datasets on the web.  3D Tiles are built for the web and optimized for streaming; true hierarchical LOD is used, polygons do not need to be triangulated, and so on.

### Technical Q&A

#### How do 3D Tiles support heterogeneous datasets?

Geospatial datasets are heterogeneous; 3D buildings are different from terrain, which is different from point clouds, which are different from vector data, and so on.

3D Tiles support heterogeneous data by allowing a different content type for each tile in a tileset, e.g., a tileset may contain tiles for 3D buildings, tiles for instanced 3D trees, and tiles for point clouds, all using different tile types.

We expect 3D Tiles will also support heterogeneous datasets by concatenating different tile types into one tile; in the example above, a tile may have a short header followed by the contents for the 3D buildings, instanced 3D trees, and point clouds.

Supporting heterogeneous datasets with both inter-tile (different tile types in the same tileset) and intra-tile (different tile types in the same tile) options will allow conversion tools to make trade-offs between number of requests, optimal type-specific subdivision, and how visible/hidden layers are streamed.

#### Will tiles.json be part of the final 3D Tiles spec?

Yes, in one form or another.  There will always be a need to know metadata about the tileset and about tiles that are not yet loaded, e.g., so only visible tiles are request.  However, when scaling to millions of tiles, a single tiles.json with metadata for the entire tree will be prohibitively big.

There's a few ways we may solve this:
* Trees of trees.  A content type of `"3dtile"` is already planned and will allow conversion tools to chunk up a tileset into any number of tiles.json files that reference each other.
* Moving subtree metadata to the tile payload instead of tiles.json.  Each tile would have a header with, for example, the bounding volumes of each child, and perhaps grandchildren and so on.
* Explicit tile layout like traditional tiling schemes (e.g., TMS's `z/y/x`).  The challenge is that this implicitly assumes a spatial subdivision, where as 3D Tiles strive to be general enough to support quadtrees, octrees, k-d trees, and so on.

#### How do I request the tiles for Level `n`?

More generally, how do we support the use case for when the viewer is zoom in very close to terrain, for example, and we do not want to load all the parent tiles toward the root of the tree; instead, we want to skip right to the high-resolution tiles needed for the current 3D view?

This 3D Tiles topic needs additional research, but the answer is basically the same as above: either the skeleton of the tree can be quickly traversed to find the desired tiles or an explicit layout scheme will be used for specific subdivisions.

#### How are cracks between tiles with vector data handled?

Unlike 2D, in 3D, we expect adjacent to be from different LODs so, for example, in the distance, lower resolution tiles are used.  Adjacent tiles from different LODs can lead to an artifact called _cracking_ where there are gaps.  For terrain, this is generally handled by dropping slightly angled _skirts_ around each tile to fill the gap.  For 3D buildings, this is handled by extended by the tile boundary to fully include buildings on the edge.  For vector data, this is an open research problem that we need to solve.  This could invole boundary-aware simplication or runtime stitching. 
