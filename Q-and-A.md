<!-- omit in toc -->
# 3D Tiles Q&A

<!-- omit in toc -->
## Contents

- [General Q&A](#general-qa)
  - [Is 3D Tiles specific to Cesium?](#is-3d-tiles-specific-to-cesium)
  - [What is the relationship between 3D Tiles and glTF?](#what-is-the-relationship-between-3d-tiles-and-gltf)
  - [Does 3D Tiles support runtime editing?](#does-3d-tiles-support-runtime-editing)
  - [Will 3D Tiles replace KML?](#will-3d-tiles-replace-kml)
- [Technical Q&A](#technical-qa)
  - [How does 3D Tiles support heterogeneous datasets?](#how-does-3d-tiles-support-heterogeneous-datasets)
  - [How do I request the tiles for Level `n`?](#how-do-i-request-the-tiles-for-level-n)
  - [Is screen space error the only metric used to drive refinement?](#is-screen-space-error-the-only-metric-used-to-drive-refinement)
  - [How are cracks between tiles with vector data handled?](#how-are-cracks-between-tiles-with-vector-data-handled)
  - [What compressed texture formats does 3D Tiles use?](#what-compressed-texture-formats-does-3d-tiles-use)

### General Q&A

#### Is 3D Tiles specific to Cesium?

No, 3D Tiles is an open standard for streaming massive heterogeneous 3D geospatial dataset. The Cesium team started this initiative because we need an open format optimized for streaming 3D content to CesiumJS. Today, 3D Tiles is an [open standard recognized by the Open Geospatial Consortium](https://www.ogc.org/standards/3DTiles), and an increasing number of visualization engines and geospatial applications use 3D Tiles as their delivery format. 

#### What is the relationship between 3D Tiles and glTF?

[glTF](https://www.khronos.org/gltf) is an open standard for 3D models from Khronos (the same group that does WebGL and COLLADA). CesiumJS uses glTF as its 3D model format, and the Cesium team contributes heavily to the glTF specification and open-source COLLADA2GLTF converter. We recommend using glTF in CesiumJS for individual assets, e.g., an aircraft, a character, or a 3D building.

We created 3D Tiles for streaming massive geospatial datasets where a single glTF model would be prohibitive. Given that glTF is optimized for rendering, that CesiumJS has a well-tested glTF loader, and that there are existing conversion tools for glTF, 3D Tiles often use glTF for tile content. Tiles may reference glTF models directly, using the [glTF Tile Format](./specification/TileFormats/glTF/README.md).

Taking this approach allows us to improve CesiumJS, glTF, and 3D Tiles at the same time. As new features and compression methods arrive in glTF, they benefit 3D models in CesiumJS, the glTF ecosystem, and 3D Tiles.

#### Does 3D Tiles support runtime editing?

A common use case for 3D buildings is to stream a city dataset, color each building based on one or more properties (e.g., the building's height), and then hide a few buildings and replace them with high-resolution 3D buildings. With 3D Tiles, this type of editing can be done at runtime.

The general case runtime editing of geometry on a building, vector data, etc., and then efficiently saving those changes in a 3D Tile will be possible, but is not the initial focus. However, styling is much easier since it can be applied at runtime without modification to the 3D Tiles tree and is part of the initial work.

#### Will 3D Tiles replace KML?

In many cases, yes. KML regions and network links are a clunky approach to streaming massive 3D geospatial datasets on the web. 3D Tiles is built for the web and optimized for streaming. It uses true HLOD and does not need to triangulate polygons on the client side. The [Cesium ion](https://cesium.com/ion/) platform allows uploading many different file formats, including KML, and convert them into 3D Tiles for efficient streaming. 

### Technical Q&A

#### How does 3D Tiles support heterogeneous datasets?

Geospatial datasets are heterogeneous: 3D buildings are different from terrain, which is different from point clouds, which are different from vector data, and so on.

3D Tiles supports heterogeneous data by allowing different formst of 3D data in a tileset. A tileset may contain tiles for 3D buildings, tiles for instanced 3D trees, and tiles for point clouds. The [glTF Tile Format](./specification/TileFormats/glTF/README.md) serves as a basis for representing these different forms of data: [glTF](https://www.khronos.org/gltf) is an open standard for 3D models and supports a large variety of 3D data, in a form that is optimized for efficient transmission.

#### How do I request the tiles for Level `n`?

More generally, how does 3D Tiles support the use case for when the viewer is zoomed in very close to terrain, for example, and we do not want to load all the parent tiles toward the root of the tree; instead, we want to skip right to the high-resolution tiles needed for the current 3D view?

For a tileset with irregular structure, the tile hierarchy can be quickly traversed to find the desired tiles (see [Skipping Levels of Detail](https://cesium.com/blog/2017/05/05/skipping-levels-of-detail/)). For tilesets with common, regular subdivision patterns like quadtrees or octrees, [Implicit Tiling](./specification/ImplicitTiling) may be used, and allow near-constant time random access to arbitrary tiles in the hierarchy. 

#### Is screen space error the only metric used to drive refinement?

At runtime, a tile's `geometricError` is used to compute the screen space error (SSE) to drive refinement. Additionally, it is possible to drive the refinement using [metadata ](specification/README.md#metadata) that is associated withe the tile or tile content. For example, points of interest may be better served with on/off distances and a label collision factor computed at runtime. Note that the viewer's height above the ground is rarely a good metric for 3D since 3D supports arbitrary views.

#### How are cracks between tiles with vector data handled?

Unlike 2D, in 3D, we expect adjacent tiles to be from different LODs so, for example, in the distance, lower resolution tiles are used. Adjacent tiles from different LODs can lead to an artifact called _cracking_ where there are gaps between tiles. For terrain, this is generally handled by dropping _skirts_ slightly angled outward around each tile to fill the gap. For 3D buildings, this is handled by extending the tile boundary to fully include buildings on the edge; [see Quadtrees](./specification/README.md#quadtrees). For vector data, this is an open research problem that we need to solve. This could involve boundary-aware simplification or runtime stitching.

#### What compressed texture formats does 3D Tiles use?

3D Tiles reference glTF content via the [glTF Tile Format](./specification/TileFormats/glTF/README.md), and the glTF format officially supports PNG, JPEG, and KTX2 / Basis Universal compressed textures ([`KHR_texture_basisu`](https://github.com/KhronosGroup/glTF/blob/main/extensions/2.0/Khronos/KHR_texture_basisu)). Additional texture compression methods may be added to glTF in the future, as [glTF extensions](https://github.com/KhronosGroup/glTF/tree/main/extensions). Texture compression is generally applied offline, as it is often prohibitively expensive to do in JavaScript and Web Workers.
