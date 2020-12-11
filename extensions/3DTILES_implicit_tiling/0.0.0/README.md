<!-- omit in toc -->
# 3DTILES_implicit_tiling

**Version 0.0.0**, December 1, 2020

<!-- omit in toc -->
## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Erixen Cruz, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Dependencies

Written against the 3D Tiles 1.0 specification.

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Tiling Schemes](#tiling-schemes)
- [Tile Coordinates](#tile-coordinates)
- [Template URIs](#template-uris)
- [Content](#content)
- [Subtrees](#subtrees)
- [Availability](#availability)
  - [Tile Availability](#tile-availability)
  - [Content Availability](#content-availability)
  - [Child Subtree Availability](#child-subtree-availability)
- [Subtree JSON Files](#subtree-json-files)
  - [Buffers and Buffer Views](#buffers-and-buffer-views)
  - [Morton Order](#morton-order)
  - [Availability Encoding](#availability-encoding)
- [Tileset JSON](#tileset-json)
- [Glossary](#glossary)
- [Examples](#examples)
- [JSON Schema Reference](#json-schema-reference)
- [Appendix A: Tree Indexing Formulae](#appendix-a-tree-indexing-formulae)
  - [Morton Indexing](#morton-indexing)
  - [Availability Buffers](#availability-buffers)
- [----------- OLD DRAFT FOLLOWS ---------------](#------------old-draft-follows----------------)
- [Overview](#overview-1)
- [Use Cases](#use-cases-1)
- [Configuration](#configuration)
- [Tiling Schemes](#tiling-schemes-1)
- [Template URIs](#template-uris-1)
- [Availability](#availability-1)
  - [Tile Availability](#tile-availability-1)
  - [Content Availability](#content-availability-1)
  - [Subtree Availability](#subtree-availability)
  - [Morton Order](#morton-order-1)
- [Content](#content-1)
- [Buffers and BufferViews](#buffers-and-bufferviews)
- [Examples](#examples-1)

## Overview

>**Implicit tiling** is a alternative method for describing a Cesium 3D Tileset that provides a more succinct representation of large tilesets. It uses a pattern of tile subdivision to describe a tileset. This contrasts **explicit tiling**, where every tile is listed. The Cesium 3D Tiles 1.0 specification only supports explicit tiling, as every tile is listed in the tileset JSON file.

Implicit tiling keeps the tileset JSON file small, which makes loading large tilesets faster. While explicit tiling can represent large datasets, the tileset JSON file grows linearly with the number of tiles. Implicit tiling keeps the tileset JSON file bounded in size.

Implicit tiling also provides a method for accessing tiles by tile coordinates. This allows for abbreviated tree traversal algorithms.

OUTLINE:
- What diagram would be good here?
- Define explicit tiling
- diagram: tile coordinates vs traversal

For a complete list of terminology used, see the [Glossary](#glossary).

## Use Cases

_This section is non-normative_

OLD -----

Implicit tiling allows Cesium 3D Tiles to support a variety of new use cases.

A key use for implicit tiling is enabling and/or accelerating tree traversal algorithms. For example, Cesium uses a [skip-LOD](https://cesium.com/blog/2017/05/05/skipping-levels-of-detail/) algorithm for faster loading times. This can be accelerated further by implicit tiling, as tiles can be directly fetched given the `level`, `x`, `y`, and sometimes `z` of a tile. This means no traversal of the `tileset.json` is needed. Raycasting algorithms and GIS algorithms can also benefit from directly addressing tiles rather than using a tree traversal.

Implicit tiling also allows for better interoperability with existing GIS data formats with implicitly defined tiling schemes. Some examples are:

* [CDB](https://docs.opengeospatial.org/is/15-113r5/15-113r5.html)
* [S2](http://s2geometry.io/)
* [WMTS](https://www.ogc.org/standards/wmts)
* [TMS](https://wiki.osgeo.org/wiki/Tile_Map_Service_Specification)

One new feature implicit tiling enables is procedurally-generated tilesets. Since implicit tiling encodes tile coordinates in URLs (such as `{level}/{x}/{y}/model.gltf`), consider the server that serves these files. Instead of serving static files, a server could extract the tile coordinates from the URL and generate tiles at runtime. This could be useful for making a large procedural terrain dataset without requiring much disk space.

----

## Tiling Schemes

>**Tiling schemes** are well-defined patterns for subdividing a bounding volume into a hierarchy of tiles.

Implicit tiling supports two types of bounding volumes, `box` and `region`. Both are defined in the [Bounding Volumes section](https://github.com/CesiumGS/3d-tiles/tree/master/specification#bounding-volumes) of the Cesium 3D Tiles 1.0 Specification. `sphere` is not supported.

TODO: Diagram of bounding volume.

A bounding volume is recursively subdivided by splitting it at the midpoint of some or all of the dimensions. If the two horizontal dimensions are split, a quadtree is produced. If all three dimensions are split, an octree is produced.

OUTLINE:
- Define quadtree in more depth
- Quadtree diagram
- Define octree in more depth
- Octree diagram
- Define what changes as we go down the tree.

## Tile Coordinates

>**Tile coordinates** are a tuple of integers that uniquely identify a tile. Tile coordinates are either `(level, x, y)` for quadtrees, and `(level, x, y, z)` for octrees.

For quadtrees, the coordinates are interpreted as follows:

| Coordinate | Description |
|---|---|
| `level` | The 0-indexed level number. Level 0 is the root of the tree, Level 1 is one level deep |
| `x` | The 0-indexed column number within the level. Columns are numbered from west to east, with the west edge of tile 0 at -180° W longitude |
| `y` | The 0-indexed row number within the level. Rows are numbered from north to south, with the north edge of tile 0 at 90° N latitude |

## Template URIs

## Content

## Subtrees

**Subtrees** are fixed-depth and fixed-branching factor sections of the tileset tree used for breaking tilesets into manageable pieces.

Since tilesets grow exponentially with depth, storing information about every tile in a single file is not always feasible or desirable. Even if RAM is not a direct limitation, streaming large files over the network can make loading times slower. To account for this, subtrees partition the tileset structure into pieces of bounded size.

![exact cover](figures/union-of-subtrees.jpg)

Each subtree is a tree-shaped container for tiles. A subtree has a fixed number of levels defined by the `subtreeLevels` property. This describes the number of distinct levels in the tree. The branching factor is also fixed due to the tiling scheme. For quadtrees, the branching factor is `4`, while octrees have a branching factor of `8`. Taken together, a subtree has exactly enough slots to store a full quadtree or full octree with a limited depth. In practice, only a subset of slots will contain a tile, as a tileset only stores the tiles that are necessary.

![subtree anatomy](figures/subtree-anatomy.jpg)

OUTLINE:
- refering to nodes is confusing. review this!

## Availability

**Availability** is boolean data about which tiles, contents, or subtrees exist in a tileset. Availability serves two purposes:

1. It provides an efficient method for checking what files are present
2. Including ths information prevents extraneous HTTP requests that would result in 404 errors.

Availablity takes the form of a bitstream with one bit per node in consideration. A 1 indicates that a tile/content/subtree is available at this node. Meanwhile, a 0 indicates that no data is available.

When every node is available or every node is unavailable, all the bits of the bitstream will be identical. That is, either all 1s or all 0s. Instead of storing a full bit stream, the `constant` property can be used instead. For example, `constant: 0` indicates that all bits are 0 and no bitstream must be stored.

Availability data is scoped to a subtree. This ensures that the size of each bitstream is bounded to a reasonable size.

### Tile Availability

**Tile availability** is a bitstream that determines which tiles exist within a subtree. There is one bit for each subtree node. A 1 indicates that a tile is available, while a 0 indicates that a tile is unavailable.

![Tile Availability](figures/tile-availability.jpg)

In the diagram above, colored nodes indicated available tile, while nodes with dashed outlines are unavailable tiles.

If a tile is marked as available, more information about the tile, such as its content or children can be queried. If a tile is marked as unavailable, the tile must be skipped.

### Content Availability

**Content availability** is a bitstream that determines which tiles have an associated content file. Like tile availability, there is one bit for each subtree node. A 1 indicates a content file exists for this tile, while a 0 indicates that no content file exists.

![Content Availability](figures/content-availability.jpg)

The purpose of content availability is to check if a file exists before making a network request. If content is marked as unavailable, the network request for that file must be skipped.

A content availablity bit must only be set if the corresponding tile availability bit is set. Otherwise, it would be possible to specify content files that are not reachable by the tiles of the tileset. The content availability bitstream can be validiated by checking that the following equation holds true:

```
contentAvailability & ~tileAvailability === 0
```

where `&` is the bitwise AND operation and `~` is the bitwise NOT operation.

### Child Subtree Availability

**Child subtree availability** is a bitstream that determines what subtrees can be reached from this subtree. There are `N` bits for every node in the bottom-most level of the subtree, where `N` is the branching factor of the tree. A 1 means there is a child subtree available at that position in the tree. Meanwhile, a 0 means there is no subtree available.

![Child Subtree Availability](figures/subtree-availability.jpg)

Child subtree availability is used to determine whether further subtree files exist before making network requests. If a child subtree availability bit is 0, any network request for that subtree must be skipped.

## Subtree JSON Files

A **subtree JSON file** describes where the availability information for a single subtree is stored.

Each subtree JSON file contains the following information:

* The location of a bitstream for tile availability (if not `constant`)
* The location of a bitstream for content availability (if not `constant`)
* The location of a bitstream for child subtree availability (if not `constant`)

### Buffers and Buffer Views

OUTLINE:
- Which spec to reference? 3DTILES_binary_buffers or core metadata?

### Morton Order

### Availability Encoding

Availability bitstreams are packed in binary using the format described in the [Boolean Data section](https://github.com/CesiumGS/3d-tiles/blob/3d-tiles-next/specification/Metadata/0.0.0/README.md#boolean-data) of the Cesium 3D Metadata Specification.

Each availability bitstream must be stored as a separate `bufferView`, but multiple `bufferViews` may be stored in a single `buffer`.

## Tileset JSON

## Glossary

TODO: Need to rethink the node naming conventions to make it simpler.

* **tileset** - A tileset as described in the Cesium 3D Tiles 1.0 specification
* **tile** - A tile as described in the Cesium 3D Tiles 1.0 specification
* **tileset JSON** - A JSON file describing a tileset, as described in the Cesium 3D Tiles 1.0 specification
* **explicit tiling** - Describing a tileset by providing information about every tile
* **implicit tiling** - Describing a tileset by providing information about the root tile and a pattern for subdividing the tile.
* **Tiling scheme** - A well-defined method for subdividing a bounding volume into a hierarchy of tiles
* **Quadtree** - A 2D tiling scheme that divides each rectangle into 4 smaller rectangles
* **Octree** - A 3D tiling scheme that divides each cuboid into 8 smaller cuboids
* **leaf tile** - A tile with no children.
* **root tile** - The topmost tile in a tileset tree.
* **available tile** - A tile that exists in the dataset.
* **unavailable tile** - A region of space that does not contain a tile
* **empty tile** - A tile that exists but does not have content
* **subtree** - a fixed-depth section of the tileset tree used to break large tilesets into managable pieces.
* **slot** - One of the nodes of a subtree, whether or not a tile exists within.
* **leaf slot** - A slot in the bottommost level of a subtree.
* **child subtree** - A subtree reachable from an available tile in a leaf slot.
* **availability** - Data specifying which tiles are available within a single subtree. This helps prevent unnecessary network requests.
* **tile availability** - Information about which tiles exist within a single subtree.
* **content availability** - Information about which tiles have an associated content file within a single subtree.
* **child subtree availability** - information about what child subtrees are available 
* **subtree file** - A JSON file storing information about a specific subtree.


## Examples

OUTLINE:
- double-headed quadtree as explicit root tileset + external implicit tilesets
- sparse, shallow octree
- deep, sparse quadtree
- Full quadtree (medium depth)

## JSON Schema Reference

OUTLINE:
- Generate via Wetzel
  
## Appendix A: Tree Indexing Formulae

### Morton Indexing

### Availability Buffers

## ----------- OLD DRAFT FOLLOWS ---------------

## Overview

This extension to 3D Tiles enables implicit tiling. 

OUTLINE:
- What is implicit tiling? - Simpler way of describing a tileset with a predictable structure without naming every tile.
- Why would you use this? - Instead of explicitly listing a large number of tiles, use a pattern to keep the tileset.json small.

## Use Cases



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

Implicit tiling supports two types of tiling schemes with predictable patterns: quadtrees and octrees. Quadtrees take each rectangular region or box and divide it into two rows and two columns. Octrees are similar, but also split the height in half to create 8 cells

TODO: Diagram of quadtree. can this be borrowed from another spec?
TODO: Diagram of octree

What changes

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

- children availability used for traversal for retrieval of tile

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