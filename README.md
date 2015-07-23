# 3D Tiles

Specification for streaming massive heterogeneous 3D geospatial datasets

**Content Types**
* [Batched 3D Model](b3dm/README.md) - 3D cities
* [Points](pnts/README.md) - point clouds

![](figures/gltf.png)

![](figures/cesium.jpg)

**TODO: discussion on the forum**

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

3D Tiles support heterogeneous data by allowing a different content type for each tile in a tileset, e.g., a tileset may contain tiles for 3D buildings, instanced 3D trees, and point clouds, all using different tile formats.

We expect 3D Tiles will also support heterogeneous tiles by concatenating different tile formats into one tile; in the example above, a tile may have a short header followed by the contents for the 3D buildings, instanced 3D trees, and point clouds.

Support heterogeneous datasets both inter-tile (different tile types in the same tileset) and intra-tile (different tile types in the same tile) will allow conversion tools to make trade-offs between number of requests (heterogeneous tiles === few requests), optimal subdivision (separate tiles allows each type to be subdivided separately), and how on/off layers are handled (separate tiles allow, for example, 3D trees to only be streamed if the layer is enabled).

#### Will tiles.json be part of the final 3D Tiles spec?

Yes, in one form or another.  There will always be a need to know metadata about the tileset and about tiles that are not yet loaded, e.g., so only visible tiles are request.  However, when scaling to millions of tiles, a single tiles.json with metadata for the entire tree will be prohibitively big.

There's a few ways we may solve this:
* Trees of trees.  A content type of `"3dtile"` is already planned and will allow conversion tools to chunk up a tileset into any number of tiles.json.
* Moving subtree metadata to the tile payload instead of tiles.json.  Each tile would have a header with, for example, the bounding volumes of each child, and perhaps grandchildren and so on.
* Explicit tile layout like traditional tiling schemes (e.g., TMS's `z/y/x`).  The challenge is that this implicitly assumes a spatial subdivision, where as 3D Tiles strive to be general enough to support quadtrees, octrees, k-d trees, and son.
