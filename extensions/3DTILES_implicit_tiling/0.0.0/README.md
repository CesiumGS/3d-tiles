<!-- omit in toc -->
# 3DTILES_implicit_tiling

**Version 0.0.0**, December 1, 2020

<!-- omit in toc -->
## Contributors

* Peter Gagliardi, Cesium
* Erixen Cruz, Cesium
* Sam Suhag, Cesium
* Sean Lilley, Cesium
* Josh Lawrence, Cesium
* Patrick Cozzi, Cesium
* Shehzan Mohammed, Cesium

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
- [Tileset JSON](#tileset-json)
- [Subdivision scheme](#subdivision-scheme)
  - [Implicit Subdivision](#implicit-subdivision)
- [Tile Coordinates](#tile-coordinates)
- [Template URIs](#template-uris)
- [Content](#content)
- [Subtrees](#subtrees)
- [Availability](#availability)
  - [Tile Availability](#tile-availability)
  - [Content Availability](#content-availability)
  - [Child Subtree Availability](#child-subtree-availability)
- [Subtree Files](#subtree-files)
  - [Buffers and Buffer Views](#buffers-and-buffer-views)
  - [Morton Order](#morton-order)
  - [Morton Order Example](#morton-order-example)
  - [Availability Encoding](#availability-encoding)
  - [Subtree Files](#subtree-files-1)
  - [External Buffers](#external-buffers)
- [Tileset JSON](#tileset-json-1)
- [Glossary](#glossary)
- [Examples](#examples)
  - [Quadtree with four levels](#quadtree-with-four-levels)
- [Octree Example](#octree-example)
- [JSON Schema Reference](#json-schema-reference)
- [Appendix A: Tree Indexing Formulas](#appendix-a-tree-indexing-formulas)
  - [Morton Indexing Formulas](#morton-indexing-formulas)
  - [Availability Formulas](#availability-formulas)
    - [Tile and Content Availability Formulas](#tile-and-content-availability-formulas)
    - [Child Subtree Availability Formulas](#child-subtree-availability-formulas)

## Overview

**Implicit tiling** describes a Cesium 3D Tileset while enabling new data structures and algorithms for near constant time random access and dynamic tileset generation. It makes fast, efficient high resolution (meter or centimeter scale) global dataset streaming possible. The tileset is uniformly subdivided and organized for ease of read and write without the need to read the entire tileset at once. The subdivision, using full and sparse quad and octrees, enables random access, smaller tileset JSON files, and faster loading.

Implicit tiling provides a method for accessing tiles by tile coordinates. This allows for abbreviated tree traversal algorithms.

![Explicit vs Implicit Tiling](figures/implicit-vs-explicit.jpg)

For a complete list of terminology used, see the [Glossary](#glossary).

## Use Cases

_This section is non-normative_

Implicit tiling allows Cesium 3D Tiles to support a variety of new use cases.

A key use for implicit tiling is enabling and/or accelerating tree traversal algorithms. Accessing a tile by coordinates is faster than traversing the entire tree. Likewise, raycasting algorithms and GIS algorithms can benefit from the abbreviated tree traversals. Tiles can be loaded immediately instead of going from top to bottom of a tree.

Implicit tiling also allows for better interoperability with existing GIS data formats with implicitly defined tiling schemes. Some examples are:

* [CDB](https://docs.opengeospatial.org/is/15-113r5/15-113r5.html)
* [S2](http://s2geometry.io/)
* [WMTS](https://www.ogc.org/standards/wmts)
* [TMS](https://wiki.osgeo.org/wiki/Tile_Map_Service_Specification)

Implicit tiling enables procedurally-generated tilesets. Instead of serving static files, a server could extract the tile coordinates from [Template URIs](#template-uris) and generate tiles at runtime while using little disk space.

## Tileset JSON

As in [3D Tiles 1.0](https://github.com/CesiumGS/3d-tiles/tree/master/specification#tileset-json), one tileset JSON file is the entry point for defining an implicit tileset. To use implicit tiling, the `3DTILES_implicit_tiling` extension must be defined in one of the tiles of the tileset JSON file. This tile is treated as the root of an implicit tileset, even if it is not the root of the tileset JSON. The implicit root tile must not define any explicit `children`.

```json
{
  "asset": {
    "version": "1.0"
  },
  "geometricError": 10000,
  "extensionsUsed": [
    "3DTILES_implicit_tiling",
  ],
  "extensionsRequired": [
    "3DTILES_implicit_tiling",
  ],
  "root": {
    "boundingVolume": {
      "region": [-1.318, 0.697, -1.319, 0.698, 0, 20]
    },
    "refine": "REPLACE",
    "geometricError": 5000,
    "extensions": {
      "3DTILES_implicit_tiling": {
        ...
      }
    }
  }
}
```
The `boundingVolume` must be either a `box`, an array of 12 numbers that define an oriented bounding box in a right-handed 3-axis (x, y, z) Cartesian coordinate system where the z-axis is up, or a `region`, an array of six numbers that define the bounding geographic region with latitude, longitude, and height coordinates with the order [west, south, east, north, minimum height, maximum height], as defined in the [bounding volume section of the 3D Tiles 1.0 specification](https://github.com/CesiumGS/3d-tiles/tree/master/specification#bounding-volumes).

**Geometric error** is the error, in meters, of the tile's simplified representation of its source geometry, as defined in the [3D Tiles 1.0 Specification](https://github.com/CesiumGS/3d-tiles/tree/master/specification#geometric-error). An implementation uses it to determine the level of detail to render.

**Refinement** determines the process by which a lower resolution parent tile renders when its higher resolution children are selected to be rendered, [as defined in 1.0](https://github.com/CesiumGS/3d-tiles/tree/master/specification#refinement).

<img src="figures/simple-tileset-json.jpg" width="300px" />

## Subdivision scheme

A **subdivision scheme** is a recursive pattern for dividing a bounding volume of a tile into smaller children tiles that take up the same space.

A subdivision scheme recursively subdivides a volume by splitting it at the midpoint of some or all of the dimensions. If the `x` and `y` dimensions are split, a quadtree is produced. If all three dimensions are split, an octree is produced. The subdivision scheme remains constant throughout the entire tileset. They may not be intermixed within a single implicit tileset.

For a `region` bounding volume, `x`, `y`, and `z` refer to `longitude`, `latitude`, and `height` respectively.

A **quadtree** divides space only on the `x` and `y` dimensions. It divides each tile into 4 smaller tiles where the `x` and `y` dimensions are halved. The quadtree `z` minimum and maximum remain unchanged. The resulting tree has 4 children per tile.

![Quadtree](figures/quadtree.png)

An **octree** divides space along all 3 dimensions. It divides each tile into 8 smaller tiles where each dimension is halved. The resulting tree has 8 children per tile.

![Octree](figures/octree.png)

The following diagrams illustrate the subdivision in the bounding volume types supported by 3D Tiles:

| Root Box | Quadtree | Octree |
|:---:|:--:|:--:|
| ![Root box](figures/box.png) | ![Box Quadtree](figures/box-quadtree.png) | ![Box octree](figures/box-octree.png)  |

| Root Region | Quadtree | Octree |
|:---:|:--:|:--:|
| ![Root region](figures/region.png) | ![Region Quadtree](figures/region-quadtree.png) | ![Region octree](figures/region-octree.png)  |
The `region` boxes above are curved to follow the globe's surface.

### Implicit Subdivision

Implicit tiling only requires defining the subdivision scheme, bounding volume, geometric error, and refine strategy at the root tile. These properties can be computed for any other tile based on the following rules:

| Property | Subdivision Rule | 
| --- | --- |
| `subdivisionScheme` | Constant for all tiles in tileset |
| `refine` | Constant for all tiles in tileset |
| `boundingVolume` | If `subdivisionScheme` is `QUADTREE`, the parent tile is divided into 4 child tiles. If `subdivisionScheme` is `OCTREE`, the parent tile is divided into 8 child tiles. |
| `geometricError` | Each child's `geometricError` is half of the parent's `geometricError` |
```json
{
  "asset": {
    "version": "1.0"
  },
  "geometricError": 10000,
  "extensionsUsed": [
    "3DTILES_implicit_tiling",
  ],
  "extensionsRequired": [
    "3DTILES_implicit_tiling",
  ],
  "root": {
    "boundingVolume": {
      "region": [-1.318, 0.697, -1.319, 0.698, 0, 20]
    },
    "refine": "REPLACE",
    "geometricError": 5000,
    "extensions": {
      "3DTILES_implicit_tiling": {
        "subdivisionScheme": "QUADTREE"
        ...
      }
    }
  }
}
```
<img src="figures/simple-tileset-subdivision.jpg" width="300px" />

## Tile Coordinates

**Tile coordinates** are a tuple of integers that uniquely identify a tile. Tile coordinates are either `(level, x, y)` for quadtrees or `(level, x, y, z)` for octrees. All tile coordinates are 0-indexed.

`level` is 0 for the root of the implicit tileset, i.e. the tile with the `3DTILES_implicit_tiling` extension. This tile's children are at level 1, and so on.

`x`, `y`, and `z` coordinates are measured in tiles from a side of the root bounding volume at the current level along one of the coordinate axes. The type of bounding volume (`box` or `region`) determines the direction of increasing tile coordinates.

For `box`, the tile coordinates are listed along the same direction as the Cartesian coordinate system of the tileset. That is:

| Coordinate | Positive Direction |
| --- | --- |
| `x` | Along the `+x` axis of the bounding box |
| `y` | Along the `+y` axis of the bounding box |
| `z` | Along the `+z` axis of the bounding box |

![Box coordinates](figures/box-coordinates.jpg)

For `region` bounding volumes, the coordinates are interpreted in geographic coordinates as described in [the 1.0 specification](https://github.com/CesiumGS/3d-tiles/tree/master/specification#region). That is:

| Coordinate | Positive Direction |
|---|---|
| `x` | From west to east (increasing longitude) |
| `y` | From south to north (increasing latitude) |
| `z` | From bottom to top (increasing height) |

![Region Coordinates](figures/region-coordinates.jpg)

## Template URIs

A **Template URI** is a URI pattern used to refer to tiles by their tile coordinates.

Template URIs are configured in the tileset JSON file. They may be any URI pattern, but must include the variables `{level}`, `{x}`, `{y}`. Template URIs for octrees must also include `{z}`. When referring to a specific tile, the tile's coordinates are substituted in for these variables.

Here are some examples of template URIs and files that they match:

```
== Quadtree Example ==
Pattern: "content/{level}/{x}/{y}/tile.b3dm"
Valid filenames: 
- content/0/0/0/tile.b3dm
- content/1/1/0/tile.b3dm
- content/3/2/2/tile.b3dm

== Octree Example ==
Pattern: "content/{level}/{z}/{y}/{x}.pnts"
Valid filenames:
- content/0/0/0/0.pnts
- content/1/1/1/1.pnts
- content/3/2/1/0.pnts
```

Unless otherwise specified, template URIs are resolved relative to the tileset JSON file.

![Template URI](figures/template-uri.jpg)

## Content

**Content** is an optional 3D model associated with a single tile, as described in the [Introduction section](https://github.com/CesiumGS/3d-tiles/tree/master/specification#introduction) of the Cesium 3D Tiles 1.0 specification.

```json
{
  "asset": {
    "version": "1.0"
  },
  "geometricError": 10000,
  "extensionsUsed": [
    "3DTILES_implicit_tiling",
  ],
  "extensionsRequired": [
    "3DTILES_implicit_tiling",
  ],
  "root": {
    "boundingVolume": {
      "region": [-1.318, 0.697, -1.319, 0.698, 0, 20]
    },
    "refine": "REPLACE",
    "geometricError": 5000,
    "extensions": {
      "3DTILES_implicit_tiling": {
        "subdivisionScheme": "QUADTREE",
        "content": {
          "uri": "terrain/{level}/{x}/{y}.b3dm"
        }
      }
    }
  }
}
```
## Subtrees

**Subtrees** are fixed-sized sections of the tileset tree used for breaking tilesets into manageable pieces.

Since tilesets grow exponentially with depth, storing information about every tile in a single file is not always feasible or desirable. Even if RAM is not a direct limitation, streaming large files over the network can make loading times slower. To account for this, subtrees partition the tileset structure into pieces of bounded size.

![exact cover](figures/union-of-subtrees.jpg)

A subtree has a fixed number of levels defined by the `subtreeLevels` property. This describes the number of distinct levels in the subtree. The number of children per tile is also fixed due to the subdivision scheme. For quadtrees, there are `4` children per tile, while octrees have `8` children per tile. Taken together, a subtree has exactly enough tiles to store a full quadtree or full octree with a limited number of levels. However, each tile may or may not exist or contain content, as a tileset only stores the tiles that are necessary.

![subtree anatomy](figures/subtree-anatomy.jpg)

## Availability

**Availability** is a boolean that defines whether a tile, content, or subtree exist in a tileset. Availability provides an efficient method for checking which resources (tile, content, subtrees) are present. Including this information prevents extraneous HTTP requests that would result in 404 errors.

Availability takes the form of a bitstream with one bit per node in consideration. A 1 indicates that a tile/content/subtree is available at this node. Meanwhile, a 0 indicates that no tile/content/subtree is available at this node.

For cases where all nodes are available or all nodes are unavailable, the `constant` property should be used instead of storing a full bitstream. For example, `constant: 0` indicates that all bits are 0 and no bitstream must be stored.

Availability data is scoped to a subtree. This ensures that the size of each bitstream is bounded to a reasonable size.

### Tile Availability

**Tile availability** is a bitstream that determines which tiles exist within a subtree. There is one bit for each subtree node. A 1 indicates that a tile is available, while a 0 indicates that a tile is unavailable. The bits follow [Morton Order](#morton-order).

![Tile Availability](figures/tile-availability.jpg)

In the diagram above, colored nodes indicate available tiles, while nodes with dashed outlines are unavailable tiles Note that this is for illustration purposes only. Binary trees are not supported.

If a tile is marked as available, it may have extensions attached to it as defined by the tileset author, and it may have content or children.

`tileAvailability.constant: 0` is disallowed, as subtrees must have at least one available tile.

### Content Availability

**Content availability** is a bitstream, separate from tile availability, that determines which tiles have an associated content 3D model. Like tile availability, there is one bit for each tile. A 1 indicates a content file exists for this tile, while a 0 indicates that no content file exists. An available tile does not need to have content if, for example, the tileset author defines extensions that store extra information in tiles outside of content.

![Content Availability](figures/content-availability.jpg)

The purpose of content availability is to check if a content 3D model exists before making a network request. If content is marked as unavailable, the network request for that file must be skipped.

A content availability bit can only be set if the corresponding tile availability bit is set. Otherwise, it would be possible to specify content files that are not reachable by the tiles of the tileset.

When a subtree has at least one tile with content, content availability is required. If no tile in the subtree has content, then content availability is disallowed.

### Child Subtree Availability

**Child subtree availability** is a bitstream that determines which subtrees can be reached from the deepest level of this subtree.

The child subtree availability bitstream has slightly different structure than tile or content availability. There is one bit for each node in the level of the tree immediately below the subtree. That is, if the deepest subtree is level `L`, then there is one bit for every node at level `L + 1`. Since each node at level `L` has `N` children (4 for `QUADTREE` or 8 for `OCTREE`), there are `N * (L + 1)` bits in the child subtree availability bitstream. A 1 bit means there is a child subtree available at that position in the tree. A 0 bit means there is no subtree available at that position.

![Child Subtree Availability](figures/subtree-availability.jpg)

Child subtree availability is used to determine whether files for child subtrees exist before making network requests. If a child subtree availability bit is 0, any network request for that subtree must be skipped.

## Subtree Files

A **subtree file** is a binary file that contains availability information for a single subtree. It includes two main portions:

* The **subtree JSON** which describes how the availability data is stored.
* A binary array for storing availability bitstreams as needed.

The subtree JSON describes where the availability information for a single subtree is stored. It includes:

* a bitstream for tile availability
* a bitstream for content availability (if at least one tile has content)
* A bitstream for child subtree availability

### Buffers and Buffer Views

A **buffer** is an array of binary data used for storing data. For subtree binary files, one buffer can be stored within the binary file. In all other cases, the binary file is assumed to be an external resource specified by the `uri` property. Each buffer has a `byteLength` describing the size of the data, including any padding (for subtree binary files)

A **buffer view** is a contiguous subarray of a buffer. A buffer view's `buffer` property is an integer index to identify the buffer. A buffer must have a `byteOffset` to describe the position within the buffer. A buffer also must have a `byteLength` length of the subarray, not including padding. There may be multiple buffer views within a single buffer.

For efficient memory access, the `byteOffset` of a buffer view must be aligned to a multiple of 8 bytes.

```jsonc
{
  "buffers": [
    {
      "name": "Internal Buffer",
      "byteLength": 80
    },
    {
      "name": "External Buffer",
      "uri": "external.bin",
      "byteLength": 64
    }
  ],
  "bufferViews" [
    {
      "name": "Tile Availability",
      "buffer": 0,
      "byteOffset": 0,
      "byteLength": 3
    },
    {
      "name": "Content Availability",
      "buffer": 0,
      "byteOffset": 8,
      "byteLength": 3
    },
    {
      "name": "Subtree Availability",
      "buffer": 1,
      "byteOffset": 0,
      "byteLength": 64
    }
  ]
}
```

### Morton Order

**[Morton order](https://en.wikipedia.org/wiki/Z-order_curve)** assigns indices to nodes in the same level. The indices are used for lookup in availability buffers.

Using the Morton order serves these purposes:

- Efficient tile location decomposition: The Morton order allows efficient encoding and decoding of locations of a tile in the level to its location in the availability buffers.
- Efficient traversal: The binary representation of tile locations in the tree level allow for easy traversal of the tileset (finding parent and child nodes).
- Locality of reference: Adjacent indices are stored close to each other in memory and are close to each other spatially.

Given tile coordinates `(level, x, y)`, the Morton index is found by interleaving the bits of `x` and `y` in binary, each represented by `level` bits.


### Morton Order Example

_This section is non-normative_

The figure below shows the tile coordinate decomposition of the tile `(level, x, y) = (3, 5, 1)`. We first convert the tile coordinate to its Morton index. `5` represented as 3 bits is `101`. `1` represented as 3 bits is `001`. Interleaving the two, we get `010011`, which is `19`. 

At Level 3 of a Quadtree, we'll use 6 bits to represent the binary value of the Morton index: `010011`.

![Morton Order](figures/morton-indexing.png)

### Availability Encoding

Availability bitstreams are packed in binary using the format described in the [Boolean Data section](https://github.com/CesiumGS/3d-tiles/blob/3d-tiles-next/specification/Metadata/0.0.0/README.md#boolean-data) of the Cesium 3D Metadata Specification. These bitstreams are subject to alignment requirements described in the [Binary Alignment Rules section](https://github.com/CesiumGS/3d-tiles/tree/3DTILES_binary_buffers/extensions/3DTILES_binary_buffers) of the same specification.

Each availability bitstream must be stored as a separate `bufferView`, but multiple `bufferViews` may refer to a single `buffer`.

### Subtree Files

Subtrees are stored in little-endian binary files. A subtree file consists of a 24-byte header and a variable length payload: 

![Subtree Binary Format](figures/binary-subtree.jpg)

Header fields:

| Bytes | Field | Type     | Description |
|-------|-------|----------|-------------|
| 0-3   | Magic | `uint32_t` | A magic number identifying this as a subtree file. This is always `0x74627573` which when stored in little-endian is the ASCII string `subt` |
| 4-7   | Version | `uint32_t` | The version number. Always `1` for this version of the specification. |
| 8-15  | JSON byte length | `uint64_t` | The length of the subtree JSON, including any padding. |
| 16-23 | Binary byte length | `uint64_t` | The length of the buffer (or 0 if the buffer does not exist) including any padding. |

The variable length payload consists of two chunks:

1. A required JSON chunk containing the contents of the subtree JSON.
2. An optional binary chunk containing a single buffer.

Each chunk must be padded so it ends on an 8-byte boundary:

* The JSON chunk must be padded at the end with spaces (`' '` = 0x20 in ASCII)
* If it exists, the binary chunk must be padded at the end with NUL bytes (`\x00` = 0x00 in ASCII)

### External Buffers

To support more than one buffer, the subtree files support external buffers. In the subtree JSON, each buffer object has a `uri` field to indicate where the external buffer can be found.

```json
{
  "buffers": [
    {
      "name": "External Buffer Example",
      "uri": "external.bin",
      "byteLength": 1000
    }
  ]
}
```

## Tileset JSON

Using implicit tiling, the tileset JSON file describes the root tile, tiling scheme, and template URIs for locating files.

In the extension object of the tileset JSON, the following properties about the root tile are included:

| Property | Description |
| ------ | ----------- |
| `subdivisionScheme` | Either `QUADTREE` or `OCTREE`|
| `boundingVolume` | A bounding volume (either a `box` or `region`) describing the root tile |
| `refine` | Either `ADD` or `REPLACE` as in the [Cesium 3D Tiles 1.0 Specification](https://github.com/CesiumGS/3d-tiles/tree/master/specification#refinement). |
| `geometricError` | Geometric error of the root tile as described in the [Cesium 3D Tiles 1.0 Specification.](https://github.com/CesiumGS/3d-tiles/tree/master/specification#geometric-error) |
| `maximumLevel` | Level of the deepest available tile in the tree. |
| `subtreeLevels` | How many levels there are in each subtree |

Furthermore, template URIs are used for resolving subtree files as well as tile contents. The key properties are as follows:

| Property | Description |
| ------ | ----------- |
| `subtrees` | Template URI for a subtree file. See [Subtrees](#subtrees) |
| `content` | Template URI for the content 3D Models |

Below is a full example of how the tileset JSON file looks in practice:

```json
{
  "asset": {
    "version": "1.0"
  },
  "geometricError": 10000,
  "extensionsUsed": [
    "3DTILES_implicit_tiling",
  ],
  "extensionsRequired": [
    "3DTILES_implicit_tiling",
  ],
  "root": {
    "boundingVolume": {
      "region": [-1.318, 0.697, -1.319, 0.698, 0, 20]
    },
    "geometricError": 5000,
    "refine": "REPLACE",
    "extensions": {
      "3DTILES_implicit_tiling": {
        "subdivisionScheme": "QUADTREE",
        "subtreeLevels": 7,
        "maximumLevel": 20,
        "subtrees": "subtrees/{level}/{x}/{y}.subtree.json",
        "content": {
          "uri": "terrain/{level}/{x}/{y}.b3dm"
        }
    }
  }
}
```
## Glossary

* **availability** - Data specifying which tiles/subtrees/contents exist within a single subtree.
* **bounding volume** - The spatial extent enclosing a tile or a tile's content, as defined in the [3D Tiles specification](https://github.com/CesiumGS/3d-tiles/tree/master/specification#bounding-volumes).
* **boolean bitstream** - A boolean array stored as a sequence of bits rather than bytes.
* **child subtree** - A subtree reachable from an available tile in the bottommost row of a subtree.
* **implicit tiling** - Describing a tileset using recursive subdivision.
* **octree** - A 3D subdivision scheme that divides each bounding volume into 8 smaller bounding volumes along the midpoint of the `x`, `y`, and `z` axes.
* **quadtree** - A 2D subdivision scheme that divides each bounding volume into 4 smaller bounding volume along the midpoint of the `x` and `y` axes.
* **subtree** - A fixed-size section of the tileset tree used to break large tilesets into manageable pieces.
* **subtree file** - A binary file storing information about a specific subtree.
* **template URI** - A URI pattern containing tile coordinates for directly addressing tiles.
* **tile** - A division of space that may contain content.
* **tileset** - A hierarchical collection of tiles.
* **tileset JSON** - A JSON file describing a tileset, as described in the [Cesium 3D Tiles 1.0 specification](https://github.com/CesiumGS/3d-tiles/tree/master/specification#tileset-json).
* **subdivision scheme** - A recursive pattern of dividing a parent tile into smaller children tiles occupying the same area. This is done by uniformly dividing the bounding volume of the parent tile.

## Examples
Here are some complete examples for how to create commonly used data structures with implicit tiling.

### Quadtree with four levels

Consider a tileset with a quadtree tiling scheme and four levels of detail. Suppose that we want to use implicit tiling with subtrees with 2 levels.

![Quadtree example](figures/quadtree-example.jpg)

The root tileset JSON might look something this:

```json
{
  "asset": {
    "version": "1.0"
  },
  "geometricError": 10000,
  "extensionsUsed": [
    "3DTILES_implicit_tiling",
  ],
  "extensionsRequired": [
    "3DTILES_implicit_tiling",
  ],
  "root": {
    "boundingVolume": {
      "region": [-1.318, 0.697, -1.319, 0.698, 0, 20]
    },
    "refine": "ADD",
    "geometricError": 5000,
    "extensions": {
      "3DTILES_implicit_tiling": {
        "subdivisionScheme": "QUADTREE",
        "subtreeLevels": 2,
        "maximumLevel": 3,
        "subtrees": "subtrees/{level}/{x}/{y}/subtree.json",
        "content": {
          "uri": "models/{level}/{x}/{y}.b3dm"
        }
      }
    }
  }
}
```

The directory structure for subtrees is:

```
|__ tileset.json
|__ subtrees/
  |__ 0/
    |__ subtree.json
    |__ availability.bin
  |__ 2/
    |__ 0/
      |__ 1/
        |__ subtree.json
        |__ availability.bin
      |__ 2/
        |__ subtree.json
        |__ availability.bin
      |__ 3/
        |__ subtree.json
    |__ 1/
      |__ 0/
        |__ subtree.json
      |__ 1/
        |__ subtree.json
      |__ 2/
        |__ subtree.json
      |__ 3/
        |__ subtree.json
    |__ 2/
      |__ 1/
        |__ subtree.json
        |__ availability.bin
      |__ 2/
        |__ subtree.json
        |__ availability.bin
```

Notice that subtrees that do not exist do not have subtree files or binary buffers. Also, subtrees that are completely full do not get availability buffers since they can specify availability with a constant.

`subtrees/0/0/0/subtree.json`:

```json
{
  "buffers": [
    {
      "uri": "availability.bin",
      "byteLength": 4
    }
  ],
  "bufferViews": [
    {
      "buffer": 0,
      "byteOffset": 0,
      "byteLength": 1
    },
    {
      "buffer": 0,
      "byteOffset": 1,
      "byteLength": 1
    },
    {
      "buffer": 0,
      "byteOffset": 2,
      "byteLength": 2
    }
  ],
  "tileAvailability": {
    "bufferView": 0
  },
  "contentAvailability": {
    "bufferView": 1
  },
  "childSubtreeAvailability": {
    "bufferView": 2
  },
}
```
In this example, tile, content, and child subtree availability are in one availability buffer. Buffer views split the buffer into the three parts. Since there are five nodes in the subtree, tile and content availability only need five bits each, so they each get one byte. There are 16 children, however, so two bytes are needed for child subtree availability.

`subtrees/2/1/0/subtree.json`:

```json
{
  "tileAvailability": {
    "constant": 1
  },
  "contentAvailability": {
    "constant": 1
  },
  "childSubtreeAvailability": {
    "constant": 0
  },
}
```

This subtree at the bottom of the tree is completely full. It uses constants for its availabilities instead of buffers. Because it is at the bottom of the tree, there are no child subtrees, so child subtree availability is a constant zero.

## Octree Example

`tileset.json`:

```json
{
  "asset": {
    "version": "1.0"
  },
  "geometricError": 10000,
  "extensionsUsed": [
    "3DTILES_implicit_tiling",
  ],
  "extensionsRequired": [
    "3DTILES_implicit_tiling",
  ],
  "root": {
    "boundingVolume": {
      "box": [
        0, 0, 0,
        100, 0, 0,
        0, 100, 0
        0, 0, 100
      ]
    },
    "refine": "ADD",
    "geometricError": 5000,
    "extensions": {
      "3DTILES_implicit_tiling": {
        "subdivisionScheme": "OCTREE",
        "subtreeLevels": 3,
        "maximumLevel": 8,
        "subtrees": {
          "uri": "subtrees/{level}/{z}/{y}/{x}/subtree.json"
        },
        "content": {
          "uri": "models/{level}/{z}/{y}/{x}.pnts"
        }
      }
    }
  }
  }
}
```

`subtrees/0/0/0/0/subtree.json`

```json
{
  "buffers": [
    {
      "uri": "availability.bin",
      "byteLength": 74
    }
  ],
  "bufferViews": [
    {
      "buffer": 0,
      "byteOffset": 0,
      "byteLength": 10
    },
    {
      "buffer": 0,
      "byteOffset": 10,
      "byteLength": 64
    }
  ],
  "tileAvailability": {
    "bufferView": 0
  },
  "contentAvailability": {
    "constant": 0
  },
  "childSubtreeAvailability": {
    "bufferView": 1
  }
}
```

`subtrees/6/0/0/0/subtree.json`

```json
{
  "buffers": [
    {
      "uri": "availability.bin",
      "byteLength": 84
    }
  ],
  "bufferViews": [
    {
      "buffer": 0,
      "byteOffset": 0,
      "byteLength": 10
    },
    {
      "buffer": 0,
      "byteOffset": 10,
      "byteLength": 10
    },
    {
      "buffer": 0,
      "byteOffset": 10,
      "byteLength": 64
    }
  ],
  "tileAvailability": {
    "bufferView": 0
  },
  "contentAvailability": {
    "bufferView": 1
  },
  "childSubtreeAvailability": {
    "bufferView": 2
  }
}
```

File structure:

```
|__ tileset.json
|__ subtrees/
  |__ 0/
    |__ 0/
      |__ 0/
        |__ 0/
            |__ subtree.json
            |__ availability.bin
  |__ 3/
    |__ 0/
      |__ 0/
        |__ 0/
          |__ subtree.json
          |__ availability.bin
  |__ 6/
    |__ 0/
      |__ 0/
        |__ 0/
        |__ subtree.json
        |__ availability.bin
|__ models/
  |__ 8/
    |__ 0/
      |__ 0/
        |__ 0.pnts
        |__ 1.pnts
      |__ 1/
        |__ 0.pnts
        |__ 1.pnts
    |__ 1/
      |__ 0/
        |__ 0.pnts
        |__ 1.pnts
      |__ 1/
        |__ 0.pnts
        |__ 1.pnts
```

## JSON Schema Reference

OUTLINE:
- Generate via Wetzel
  
## Appendix A: Tree Indexing Formulas

### Morton Indexing Formulas

| Quantity | Formula | Description |
| -------- | ------- | ----------- |
| `N` | 4 or 8 | N is 4 for quadtrees, 8 for octrees |
| `bits` | `log2(N)` | Quadtree address are a multiple of 2 bits, Octrees use a multiple of 3 bits | 
| `mortonIndex` | `interleave(z, y, x)` or `interleave(y, x)` | The morton index is computed by interleaving bits. See below. |
| `length(mortonIndex)` | `level * bits` | Length of morton index in bits
| `parent.mortonIndex` | `child.mortonIndex >> bits` | The parent morton index is a prefix of the child |
| `child[k].mortonIndex` | `(parent.mortonIndex << bits) + k` | Morton index of a node's `k-th` child in Morton order |
| `parent.indexOf(child)` | `child.mortonIndex % N` or `child.mortonIndex & (N - 1)` | Index of the child within the parent's `N` children |

The `interleave(a, b, c, ...)` function mentioned above interleaves the bits of the input streams into a single bit stream. It does this by taking a bit from each bit stream from left to light and concatenating them into a single bitstream. This is repeated until all bits have been used.

Below are some examples:

```
interleave(0b11, 0b00) = 0b1010
interleave(0b1010, 0b0011) = 0b10001101
interleave(0b0110, 0b0101) = 0b00111001

interleave(0b001, 0b010, 0b100) = 0b001010100
interleave(0b111, 0b000, 0b111) = 0b101101101
```

### Availability Formulas

#### Tile and Content Availability Formulas

Both tile and content availability are stored in a bitstream with the same structure, so these formulas apply equally well to both

| Quantity | Formula | Description |
| -------- | ------- | ----------- |
| `lengthBits` | `(N^subtreeLevels - 1)/(N - 1)` | Length of buffer is determined by subtree levels |
| `lengthBytes` | `ceil(lengthBits / 8)` | Bytes needed to store the buffer | 
| `parent.index` | `floor((child.index - 1) / N)` | Index of the parent in the bitstream | 
| `parent.indexOf(child)` | `(child.index - 1) % N` | Index of the child within the parent's `N` children |
| `parent.children[k].index` | `N * index + k + 1` | Find the bit of the `k-th` child of a node |
| `index` | `(N^level - 1)/(N - 1) + mortonIndex` | Find the index of a node from `(level, mortonIndex)`
| `level` | `ceil(log(index + 1)/log(N))` | Find the level of a node relative to the subtree |
| `globalLevel` | `level + subtreeRoot.globalLevel` | Find the level of a node relative to the entire tileset | 
| `startOfLevel` | `(N^level - 1)/(N - 1)` | First index at a particular level (relative to the subtree root) |
| `mortonIndex` | `index - startOfLevel` | Convert from bit index to Morton index, relative to the root of the subtree |
| `globalMortonIndex` | `concat(subtreeRoot.globalMortonIndex, mortonIndex)` | Get the Morton index relative to the root of the tileset |

#### Child Subtree Availability Formulas

| Quantity | Formula | Description |
| -------- | ------- | ----------- |
| `lengthBits` | `N^subtreeLevels` | Length of the buffer by subtree levels |
| `lengthBytes` | `ceil(lengthBits / 8)` | Bytes needed to store the buffer |
| `childSubtree.globalLevel` | `subtreeRoot.globalLevel + subtreeLevels` | Level of the child subtrees relative to the tileset root |
| `leaf.children[k].index` | `N * leaf.mortonIndex + k` | Index of the `k-th` child subtree |
| `leaf.indexOf(childSubtree)` | `subtreeRoot.mortonIndex % N` | Index of the child subtree within the parent leaf's `N` children |
| `leaf.mortonIndex` | `floor(subtreeRoot.mortonIndex / N)` | Morton index of the parent leaf |
