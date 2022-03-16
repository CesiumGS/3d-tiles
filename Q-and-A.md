# 3D Tiles Q&A

## Contents

* [General Q&A](#general-qa)
   * [Is 3D Tiles specific to Cesium?](#is-3d-tiles-specific-to-cesium)
   * [What is the relationship between 3D Tiles and glTF?](#what-is-the-relationship-between-3d-tiles-and-gltf)
   * [Do 3D Tiles support runtime editing?](#does-3d-tiles-support-runtime-editing)
   * [Will 3D Tiles include terrain?](#will-3d-tiles-include-terrain)
   * [Will 3D Tiles include imagery?](#will-3d-tiles-include-imagery)
   * [Will 3D Tiles replace KML?](#will-3d-tiles-replace-kml)
* [Technical Q&A](#technical-qa)
   * [How does 3D Tiles support heterogeneous datasets?](#how-does-3d-tiles-support-heterogeneous-datasets)
   * [Will a tileset file be part of the final 3D Tiles spec?](#will-a-tileset-file-be-part-of-the-final-3d-tiles-spec)
   * [How do I request the tiles for Level `n`?](#how-do-i-request-the-tiles-for-level-n)
   * [Is screen-space error the only metric used to drive refinement?](#is-screen-space-error-the-only-metric-used-to-drive-refinement)
   * [How are cracks between tiles with vector data handled?](#how-are-cracks-between-tiles-with-vector-data-handled)
   * [When using replacement refinement, can multiple children be combined into one request?](#when-using-replacement-refinement-can-multiple-children-be-combined-into-one-request)
   * [How can additive refinement be optimized?](#how-can-additive-refinement-be-optimized)
   * [What compressed texture formats does 3D Tiles use?](#what-compressed-texture-formats-does-3d-tiles-use)

### General Q&A

#### Is 3D Tiles specific to Cesium?

No, 3D Tiles is a general spec for streaming massive heterogeneous 3D geospatial datasets.  The Cesium team started this initiative because we need an open format optimized for streaming 3D content to CesiumJS.  We expect to see other visualization engines and conversion tools use 3D Tiles.

#### What is the relationship between 3D Tiles and glTF?

[glTF](https://www.khronos.org/gltf) is an open standard for 3D models from Khronos (the same group that does WebGL and COLLADA).  CesiumJS uses glTF as its 3D model format, and the Cesium team contributes heavily to the glTF spec and open-source COLLADA2GLTF converter.  We recommend using glTF in CesiumJS for individual assets, e.g., an aircraft, a character, or a 3D building.

We created 3D Tiles for streaming massive geospatial datasets where a single glTF model would be prohibitive. Given that glTF is optimized for rendering, that CesiumJS has a well-tested glTF loader, and that there are existing conversion tools for glTF, 3D Tiles often use glTF for tile content. Tiles may reference glTF models directly, using the [glTF Tile Format](./specification/TileFormats/glTF/README.md).

Taking this approach allows us to improve CesiumJS, glTF, and 3D Tiles at the same time. As new features and compression methods arrive in glTF, they benefit 3D models in CesiumJS, the glTF ecosystem, and 3D Tiles.

#### Does 3D Tiles support runtime editing?

A common use case for 3D buildings is to stream a city dataset, color each building based on one or more properties (e.g., the building's height), and then hide a few buildings and replace them with high-resolution 3D buildings.  With 3D Tiles, this type of editing can be done at runtime.

The general case runtime editing of geometry on a building, vector data, etc., and then efficiently saving those changes in a 3D Tile will be possible, but is not the initial focus.  However, styling is much easier since it can be applied at runtime without modification to the 3D Tiles tree and is part of the initial work.

#### Will 3D Tiles include terrain?

Yes, a [quantized-mesh](https://github.com/CesiumGS/quantized-mesh/blob/main/README.md)-like tile would fit well with 3D Tiles and allow engines to use the same streaming code (we say _quantized-mesh-like_ because some of the metadata, e.g., for bounding volumes and horizon culling, may be organized differently or moved to the tileset JSON).

However, since quantized-mesh already streams terrain well, we are not focused on this in the short-term.

#### Will 3D Tiles include imagery?

Yes, there is an opportunity to provide an optimized base layer of terrain and imagery (similar to how a 3D model contains both geometry and textures).  There is also the open research problem of how to tile imagery for 3D.  In 2D, only one LOD (`z` layer) is used for a given view.  In 3D, especially when looking towards the horizon, tiles from multiple LODs are adjacent to each other.  How do we make the seams look good?  This will likely require tool and runtime support.

As with terrain, there are existing solutions to streaming imagery, so we are not focused on this in the short-term.

#### Will 3D Tiles replace KML?

In many cases, yes.  KML regions and network links are a clunky approach to streaming massive 3D geospatial datasets on the web.  3D Tiles is built for the web and optimized for streaming; uses true HLOD; does not need to triangulate polygons; and so on.

### Technical Q&A

#### How does 3D Tiles support heterogeneous datasets?

Geospatial datasets are heterogeneous: 3D buildings are different from terrain, which is different from point clouds, which are different from vector data, and so on.

3D Tiles supports heterogeneous data by allowing different tile formats in a tileset, e.g., a tileset may contain tiles for 3D buildings, tiles for instanced 3D trees, and tiles for point clouds, all using different tile formats.

3D Tiles also supports heterogeneous datasets by concatenating different tile formats into one tile using the [Composite](./specification/TileFormats/Composite/README.md) tile format.  In the example above, a tile may have a short header followed by the content for the 3D buildings, instanced 3D trees, and point clouds.

Supporting heterogeneous datasets with both inter-tile (different tile formats in the same tileset) and intra-tile (different tile formats in the same Composite tile) options allows conversion tools to make trade-offs between number of requests, optimal type-specific subdivision, and how visible/hidden layers are streamed.

#### Will a tileset file be part of the final 3D Tiles spec?

Yes.  There will always be a need to know metadata about the tileset and about tiles that are not yet loaded, e.g., so only visible tiles can be requested.  However, when scaling to millions of tiles, a single tileset file with metadata for the entire tree would be prohibitively large.

3D Tiles already supports trees of trees. `content.uri` can point to another tileset JSON file, which enables conversion tools to chunk up a tileset into any number of JSON files that reference each other.

[Implicit Tiling](./specification/ImplicitTiling) layouts allow common subdivision schemes and spatial index patterns to be declared without listing bounding volumes exhaustively. This representation reduces tileset size, and enables new optimizations including faster traversal, raycasting, random access, and spatial queries.

#### How do I request the tiles for Level `n`?

More generally, how does 3D Tiles support the use case for when the viewer is zoomed in very close to terrain, for example, and we do not want to load all the parent tiles toward the root of the tree; instead, we want to skip right to the high-resolution tiles needed for the current 3D view?

The answer is basically the same as above: either the skeleton of the tree can be quickly traversed to find the desired tiles (see [Skipping Levels of Detail](https://cesium.com/blog/2017/05/05/skipping-levels-of-detail/)) or an implicit layout scheme ([Implicit Tiling](./specification/ImplicitTiling)) may be used for common subdivision patterns.

#### Is screen space error the only metric used to drive refinement?

At runtime, a tile's `geometricError` is used to compute the screen space error (SSE) to drive refinement.  We expect to expand this, for example, by using the [_virtual multiresolution screen space error_](http://www.dis.unal.edu.co/profesores/pierre/MyHome/publications/papers/vmsse.pdf) (VMSSE), which takes occlusion into account.  This can be done at runtime without streaming additional tile metadata.  Similarly, fog can also be used to tolerate increases to the SSE in the distance.

However, we do anticipate other metadata for driving refinement.  SSE may not be appropriate for all datasets; for example, points of interest may be better served with on/off distances and a label collision factor computed at runtime.  Note that the viewer's height above the ground is rarely a good metric for 3D since 3D supports arbitrary views.

See [#15](https://github.com/CesiumGS/3d-tiles/issues/15).

#### How are cracks between tiles with vector data handled?

Unlike 2D, in 3D, we expect adjacent tiles to be from different LODs so, for example, in the distance, lower resolution tiles are used.  Adjacent tiles from different LODs can lead to an artifact called _cracking_ where there are gaps between tiles.  For terrain, this is generally handled by dropping _skirts_ slightly angled outward around each tile to fill the gap.  For 3D buildings, this is handled by extending the tile boundary to fully include buildings on the edge; [see Quadtrees](./specification/README.md#quadtrees).  For vector data, this is an open research problem that we need to solve.  This could involve boundary-aware simplification or runtime stitching.

#### When using replacement refinement, can multiple children be combined into one request?

Often when using replacement refinement, a tile's children are not rendered until all children are downloaded (an exception, for example, is unstructured data such as point clouds, where clipping planes can be used to mask out parts of the parent tile where the children are loaded; naively using the same approach for terrain or an arbitrary 3D model results in cracking or other artifacts between the parent and child).

We may design 3D Tiles to support downloading all children in a single request by allowing the tileset to point to a subset of a payload for a tile's content similiar to glTF [buffers and buffer views](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#buffers-and-buffer-views).  [HTTP/2](http://chimera.labs.oreilly.com/books/1230000000545/ch12.html#_brief_history_of_spdy_and_http_2) will also make the overhead of multiple requests less important.

See [#9](https://github.com/CesiumGS/3d-tiles/issues/9).

#### How can additive refinement be optimized?

Compared to replacement refinement, additive refinement has a size advantage because it doesn't duplicate data in the original dataset.  However, it has a disadvantage when there are expensive tiles to render near the root and the view is zoomed in close.  In this case, for example, the entire root tile may be rendered, but perhaps only one feature or even no features are visible.

3D Tiles can optimize this by storing an optional spatial data structure in each tile.  For example, a tile could contain a simple 2x2 grid, and if the tile's bounding volume is not completely inside the view frustum, each box in the grid is checked against the frustum, and only those inside or intersecting are rendered.

See [#11](https://github.com/CesiumGS/3d-tiles/issues/11).

#### What compressed texture formats does 3D Tiles use?

3D Tiles reference glTF content via the [glTF Tile Format](./specification/TileFormats/glTF/README.md), and the glTF format officially supports PNG, JPEG, and KTX2 / Basis Universal compressed textures ([`KHR_texture_basisu`](https://github.com/KhronosGroup/glTF/blob/main/extensions/2.0/Khronos/KHR_texture_basisu)). Additional texture compression methods may be added to glTF in the future, as [glTF extensions](https://github.com/KhronosGroup/glTF/tree/main/extensions). Texture compression is generally applied offline, as it is often prohibitively expensive to do in JavaScript and Web Workers.
