# 3DTILES_implicit_tiling

**Version 0.0.0**, December 1, 2020

## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Erixen Cruz, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 specification.

## Contents

- [3DTILES_implicit_tiling](#3dtiles_implicit_tiling)
  - [Contributors](#contributors)
  - [Status](#status)
  - [Dependencies](#dependencies)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Use Cases](#use-cases)
  - [Configuration](#configuration)
  - [Tiling Schemes](#tiling-schemes)
  - [Template URIs](#template-uris)
  - [Availability](#availability)
    - [Tile Availability](#tile-availability)
    - [Content Availability](#content-availability)
    - [Subtree Availability](#subtree-availability)
    - [Morton Order](#morton-order)
  - [Subtrees](#subtrees)
  - [Content](#content)
  - [Buffers and BufferViews](#buffers-and-bufferviews)
  - [Examples](#examples)

## Overview

This extension to 3D Tiles enables implicit tiling. 

OUTLINE:
- What is implicit tiling? - Simpler way of describing a tileset with a predictable structure without naming every tile.
- Why would you use this? - Instead of explicitly listing a large number of tiles, use a pattern to keep the tileset.json small.

## Use Cases

Implicit tiling allows Cesium 3D Tiles to support a variety of new use cases.

A key use for implicit tiling is enabling and/or accelerating tree traversal algorithms. For example, Cesium uses a [skip-LOD](https://cesium.com/blog/2017/05/05/skipping-levels-of-detail/) algorithm for faster loading times. This can be accelerated further by implicit tiling, as tiles can be directly fetched given the `level`, `x`, `y`, and sometimes `z` of a tile. This means no traversal of the `tileset.json` is needed. Raycasting algorithms and GIS algorithms can also benefit from directly addressing tiles rather than using a tree traversal.

Implicit tiling also allows for better interoperability with existing GIS data formats with implicitly defined tiling schemes. Some examples are:

* [CDB](https://docs.opengeospatial.org/is/15-113r5/15-113r5.html)
* [S2](http://s2geometry.io/)
* [WMTS](https://www.ogc.org/standards/wmts)
* [TMS](https://wiki.osgeo.org/wiki/Tile_Map_Service_Specification)

One new feature implicit tiling enables is procedurally-generated tilesets. Since implicit tiling encodes tile coordinates in URLs (such as `{level}/{x}/{y}/model.gltf`), consider the server that serves these files. Instead of serving static files, a server could extract the tile coordinates from the URL and generate tiles at runtime. This could be useful for making a large procedural terrain dataset without requiring much disk space.

## Configuration

The `tileset.json` of an implicit tileset is much more compact than in the core 3D Tiles specification. Instead of specifying a tree of tiles, only information about the root tile and URL patterns to locate the other files in tileset are used.

Information about the root tile includes the following:

| Option | Description |
| ------ | ----------- |
| `tilingScheme` | Either `QUADTREE` or `OCTREE`, this determines the branching factor at every level of the tree|
| `boundingVolume` | a bounding volume (either a `box` or `region`) describing the root. This will be subdivided depending on the `tilingScheme`. See [Tiling Schemes](#tiling-schemes) for more information |
| `refine` | Either `ADD` or `REPLACE` as in the core Cesium 3D Tiles Specification. This will be used throughout the tree |
| `geometricError` | Geometric error of the root tile as described in the Cesium 3D Tiles Specification. This will be halved at each successive level of the tree |
| `maximumLevel` | Maxium level of the entire tree |
| `subtreeLevels` | How many distince levels in each subtree. See the [Subtrees](#subtrees) section for more details |

An implicit tileset also includes many other tiles to store 3D models, subtree files, and binary buffers for availability information. These are configured [template URIs](#template-uris) that use the tile coordinates, i.e. `level`, `x`, `y`, and sometimes `z`. 

On disk, one possible organization of files in an implicit tileset looks like this:

```
/
|-- tileset.json
|-- availability/
|   |-- {level}/{x}/{y}/buffer.bin
|-- content/
|   |-- {level}/{x}/{y}/model.gltf
|-- subtrees/
|   |-- {level}/{x}/{y}/subtree.json
```

The options for configuring these other files are as follows:

| Option | Description |
| ------ | ----------- |
| `subtrees.uri` | template URI for a subtree JSON file. see [Subtrees](#subtrees) for more info |
| `content.uri` | template URI for the content 3D Models |

## Tiling Schemes

OUTLINE:
- Quadtree vs octree
- bounding volumes are quartered/eighthed automatically
- cartesian cube or cartographic cube covering root tileset
- geometric error is halved
- refine (ADD/REPLACE) applies to every tile
- subtree branching factor
- diagram: subdivision of tile (maybe reuse some from the [old draft?](https://github.com/CesiumGS/3d-tiles/tree/3DTILES_implicit_tiling/extensions/3DTILES_implicit_tiling))

## Template URIs

OUTLINE:
- level, x, y, z are templated in
- relative to tileset
- availability buffers used to determine when a tile exists
- used to describe tile availability files, content availability files, and subtree jsons
- diagram: how a pattern corresponds to tiles

## Availability

While tiling schemes and template URIs describe the structural patterns the tileset must follow, **availability** describes what data actually exists in the tree. Availability serves two main purposes:

1. It provides an efficient method for checking for the presence of data.
2. Including this information prevents extraneous HTTP requests that would result in 404 errors.

This extension provides three types of availability data for different purposes:

* [Tile availability](#tile-availability) - information about whether a given tile exists in the tileset tree.
* [Content availability](#content-availability) - information about whether a given tile has content (since tiles can be empty)
* [Subtree availability](#subtree-availability) - for memory considerations, tilesets are split into [subtrees](#subtrees). 

All three use the same form of data storage. Avaiablity takes the form of a bit vector with one bit per entity in consideration. a 1 indicates an entity exists, while a 0 indicates that the entity does not exist. These bit vectors are packed in binary using a format described in the [Boolean Data section](https://github.com/CesiumGS/3d-tiles/blob/3d-tiles-next/specification/Metadata/0.0.0/README.md#boolean-data) of the Cesium 3D Metadata Specification. This bit vector is stored in a [buffer](#buffers-and-bufferviews) and referenced using a `bufferView` JSON property.

However, storing a bit for every node in a tree can add up. This is especially true when every entity exists (a bit vector with all 1s) or no entity exists (all 0s). To help reduce the cost in these two cases, specifying `constant: 1` or `constant: 0` can be used in place of the bit vector to save memory.

OUTLINE:
- bit vector (describe this like in Cesium 3D Metadata spec?)
- `constant` can be used to save memory
- 1 indicates something is available, 0 indicates unavailable
- meaning depends on type of availability buffers
  - tile availability: does the tile exist?
  - content availability: does the tile have content
  - subtree availability: preview of immediate children availability so traversals can short-circuit
- diagram: tile and content availability
- diagram: subtree availability

### Tile Availability

Tile availability describes what tiles exist at a specific position in space. Though template URIs can represent any possible `(level, x, y)` or `(level, x, y, z)` tile (depending on the tiling scheme), a tileset will typically need only a small subset of the possible tiles. Tile availability explicitly list which tiles are present. This allows querying for tiles while keeping network requests to a minimum.

Tile availability is a bit vector with one bit per node in the [subtree](#subtrees).

Useful formulas for the tile availability buffer:

| Quantity | Formula | Description |
| -------- | ------- | ----------- |
| `lengthBits` | `N^subtreeLevels - 1` | Length of buffer is determined by subtree levels 
| `lengthBytes` | `ceil(lengthBits / 8)` | Bytes needed to store the buffer | 
| `parent.index` | `floor((child.index - 1) / N)` | Index of the parent in the bit vector | 
| `parent.indexOf(child)` | `(child.index - 1) % N` | Index of the child within the parent's `N` children |
| `parent.children[k].index` | `N * index + k + 1` | Find the bit of the `k-th` child of a node |
| `index` | `N^level - 1 + mortonIndex` | Find the index of a node from `(level, mortonIndex)`
| `level` | `floor(log2(index + 1))` | Find the level of a node relative to the subtree |
| `globalLevel` | `level + subtreeRoot.globalLevel` | Find the level of a node relative to the entire tileset | 
| `startOfLevel` | `N^level - 1` | first index at a particular level (relative to the subtree root) |
| `mortonIndex` | `index - startOfLevel` | Convert from bit index to Morton index, relative to the root of the subtree |
| `globalMortonIndex` | `concat(subtreeRoot.globalMortonIndex, mortonIndex)` | Get the Morton index relative to the root of the tileset |

### Content Availability

### Subtree Availability

| Quantity | Formula | Description |
| -------- | ------- | ----------- |
| `lengthBits` | `N^subtreeLevels` | Length of the buffer by subtree levels |
| `lengthBytes` | `ceil(lengthBits / 8)` | Bytes needed to store the buffer |
| `subtree.globalLevel` | `subtreeRoot.globalLevel + subtreeLevels` | Level of the subtrees relative to the tileset root |
| `leaf.children[k].index` | `N * leaf.mortonIndex + k` | index of the `k-th` subtree |
| `leaf.indexOf(subtree)` | `subtreeRoot.mortonIndex % N` | Index of the subtree within the parent leaf's `N` children |
| `leaf.mortonIndex` | `floor(subtreeRoot.mortonIndex / N)` | Morton index of the parent leaf |

TODO: be clearer about conventions. which subtree am I referring to? it's a little unclear if I'm referring to the current subtree or one of the child subtrees.

### Morton Order

| Quantity | Formula | Description |
| -------- | ------- | ----------- |
| `N` | 4 or 8 | N is 4 for quadtrees, 8 for octrees |
| `bits` | `log2(N)` | Quadtree address are a multiple of 2 bits, Octrees use a multiple of 3 bits | 
| `mortonIndex` | `interleave(z, y, x)` or `interleave(y, x)` | The morton index is computed by interleaving bits. see below. |
| `length(mortonIndex)` | `level * bits` | length of morton index in bits
| `parent.mortonIndex` | `child.mortonIndex >> bits` | The parent morton index is a prefix of the child |
| `child[k].mortonIndex` | `(parent.mortonIndex << bits) + k` | Morton index of a node's `k-th` child in Morton order |
| `parent.indexOf(child)` | `child.mortonIndex % N` or `child.mortonIndex & (N - 1)` | Index of the child within the parent's `N` children |

```
N = 4 for quadtrees, 8 for octrees
lgN = log2(N) = 2 for quadtrees, 3 for octrees

level = level of tile in quadtree or octree
x, y, z = coordinates of tile at the deepest level. z is only used for octrees.

mortonIndex = interleave(z, y, x) or interleave(y, x) for quadtrees
length(mortonIndex) = level * lgN // measured in bits

parent.mortonIndex = child.mortonIndex >> lgN
child[k].mortonIndex = parent.mortonIndex << lgN + k
parent.indexOf(child) = child.mortonIndex % N = child.mortonIndex & (N - 1)
```

OUTLINE:
- better locality of reference
- takes into account hierarchy (simple to find parent index)
- see what can be reused from old draft

## Subtrees

Since tilesets grow exponentially, storing all tile info in a single file is not always feasible. To account for this, `3DTILES_implicit_tiling` provides a standard method for dividing a tileset into manageable chunks called **subtrees**. This extension defines a subtree as a fixed-size section of the overall tileset tree. A subtree has a fixed number of levels, controlled by `subtreeLevels`. The branching factor is also fixed by the `tilingScheme` to either 4 or 8.

TODO: diagram: anatomy of a subtree

It is helpful to think of a subtree as a fixed-size container for part of the tileset. The container takes the form of a complete tree

TODO: diagram: smaller tree within subtree

The set of subtrees must exactly cover the valid tiles of the tileset. That is, every tile must appear in exactly one subtree.

TODO: diagram: subtrees exactly covering the tileset. 


OUTLINE:
- fixed depth subtree chunk of root tree
- json file points to buffers (or constants) with tile, child subtree, content availabilities
- children availability used for traversal for retrieval of tile
- subtrees contain mutually exclusive tiles, and completely cover the entire tree
- include formulas from `example/subtree.json`
- diagram: how subtrees fit together to make a tree

## Content

Each tile can optionally contain **content** which represents a single 3D model. This is nearly identical to the [definition](https://github.com/CesiumGS/3d-tiles/tree/master/specification#reference-tile-content) from the Cesium 3D Tiles 1.0 specifiction, with one main difference. This extension adds a `mimeType` property to identify the type of the content. This is useful information when parsing tilesets, as it is more reliable than guessing the type of file by file extension.

To use glTF models (`.gltf` or `.glb` files) as content, the `3DTILES_content_gltf` extension must be listed as a required extension in the tileset.

## Buffers and BufferViews

OUTLINE:
- describe
- refer to Cesium Metadata spec
- describe these again so they're standalone?
- Any chance we can reuse material?

## Examples

OUTLINE:
- make example more concrete
- link to it here