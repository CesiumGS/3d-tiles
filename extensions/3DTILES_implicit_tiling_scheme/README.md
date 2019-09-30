# 3DTILES_implicit_tiling Extension

## Contributors

* Josh Lawrence, [@loshjawrence](https://github.com/loshjawrence)
* Shehzan Mohammed, [@shehzan10](https://github.com/shehzan10)
* Patrick Cozzi, [@pjcozzi](https://github.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Concepts](#concepts)
* [Tileset JSON Format Updates](#tileset-json-format-updates)
   * [Tiling Scheme](#tiling-scheme)
   * [Notes](#notes)
* [Resources](#resources)
* [Property Reference](#property-reference)

### TODO:
* Context/Examples "give more context about the intent here first. Otherwise, non-expert readers will not be able to follow and may write 3D Tiles and implicit tiling off as "too complex" even though they are not."
   * Introduce core concepts in the preliminary paragraphs so that things like subtree and availability have some context when describing them in detail.
   * Describe what octrees and quadtrees are
* Figures subdirectory
* Spell check.

## Overview

This extension enables the [3D Tiles JSON](../../specification/schema/tileset.schema.json) to support streaming tilesets with implied subdivision schemes.

## Concepts

subdivision, how `boundingVolume`s are split, subtrees, subtree of availability as packed bit mipmap, how is indexing done.

## Tileset JSON Format Updates

### Tiling Scheme

The Tileset JSON describing a [3D Tiles](../../specification/README.md) tileset may be extended to include a `3DTILES_implicit_tiling` object. This object defines
the root level context from which the entire tileset structure (`boundingVolume`, `geometricError`, `refine`) can be implied.

Below is an example of a Tileset JSON with the implicit tiling scheme extension set:

```json
{
    "asset": {
        "version": "1.0"
    },
    "geometricError": 563.8721715009725,
    "extensions": {
        "3DTILES_implicit_tiling": {
            "splitAxes": 2,
            "refine": "REPLACE",
            "rootTilesPerAxis": [2,1,1],
            "firstSubtreesWithContent": [[0,0,0,0], [0,1,0,0]],
            "subtreeLevels": 10,
            "lastLevel": 19,
            "boundingVolume": {
                "region": [
                     -1.5707963267948966,
                     -3.1415926535897932,
                      1.5707963267948966,
                      3.1415926535897932,
                    -11.89207010413975,
                    547.7591827297583
                ]
            },
            "transform": [
                0.964993398200894,
                -0.2622741722486046,
                0,
                0,
                0.1674100354510973,
                0.6159568729846445,
                0.7697863409110614,
                0,
                -0.2018950753707308,
                -0.7428387370043971,
                0.6383016444806947,
                0,
                -1289474.3598308756,
                -4744402.522436097,
                4049448.137488265,
                1
            ],
        }
    }
}
```

#### properties

#### splitAxes

|Type|Description|
|----|-----------|
|`0`|TODO: Indicates no `splitAxes`? (CDB negative levels, i.e. the mipped imagery) |
|`2`|Quadtree scheme.|
|`3`|Octree scheme.|

The `splitAxes` property specifies the subdivision scheme for the entire tileset. A value of 2 means the subdivision scheme is a quadtree while a value of 3 means the subdivision scheme is an octree.
In a quadtree, a tile is split evenly along the x and y axes, forming four equally sized children. In an octree, a tile is split evenly along the x, y, and z axes, forming eight equally sized children.

TODO: Add figure of what quad and oct examples, check 3dtiles spec.

#### refine

The `refine` property specifies the refinement style and is either `REPLACE` or `ADD`. The refinement specified applies to all tiles in the tileset.
This is the same `refine` property which is defined per-tile in the core 3D Tiles specification [3D Tiles `refine` Property](https://github.com/AnalyticalGraphicsInc/3d-tiles/tree/master/specification#refinement).

#### rootTilesPerAxis
TODO: rename? fixedGridDimensions? rootGridDimensions? rootFixedGridDimensions?

The `rootTilesPerAxis` property is a three element array of numbers specifying the x, y, and z dimensions of a fixed grid at tree level 0. At each location of the fixed grid, there may reside a tileset root.
The space is uniformly divided so all of the root tiles will have exactly the same geometric size.  For quadtrees, the third element of this array is ignored. A single root is indicated by "`rootTilesPerAxis`": [1, 1, 1].
Two roots side-by-side along the x dimension is indicated by "`rootTilesPerAxis`": [2, 1, 1].

TODO: Add figure. How does indexing correlate: 0 to n-1 for each dimension. left-right, top-bottom, back-front?

#### firstSubtreesWithContent

The `firstSubtreesWithContent` property describes the first set of subtrees that are available in the tree.
It is an array where each element holds a four element array specifying the subtrees d,x,y,z index in the tileset. The last element is ignored if the tileset is a quadtree.

```json
    "firstSubtreesWithContent": [[0,0,0,0], [0,1,0,0]],
```
In this example, the first subtrees that are available have d,x,y,z indexes of 0,0,0,0 and 0,1,0,0. A subtree uri is this d,x,y,z key appended to the subtree default folder location or `availability/d/x/y/z`.
These two subtree relative uri's would be `availability/0/0/0/0` and `availability/0/1/0/0`, respectively.

#### subtreeLevels

The `subtreeLevels` property is a number that specifies the fixed amount of levels in of all subtrees for the tileset.

```json
    "subtreeLevels": 10,
```
In this example, `subtreeLevels` is 10 meaning that all subtrees will supply availability for 10 levels starting from their root. If a subtree starts at level 0 it would cover levels 0 through 9 for its portion of the tree.
If a subtree starts at level 9 it would cover levels 9 through 18 for its portion of the tree.

#### lastLevel

The `lastLevel` property is a number that specifies the last tree level in the tileset.

```json
    "lastLevel": 19,
```
In the example above this number is `19` meaning that last level in the tree is level 19. This number is indexed from 0 so if the number was 0 it would mean the tileset only has 1 level, the root at level 0.

#### boundingVolume

The `boundingVolume` property specifies bounding volume for the entire tileset.  The `boundingVolume` types are restricted to `region` and `box`.
This is the same `boundingVolume` property which is defined per-tile in the core 3D Tiles specification [3D Tiles `boundingVolume` Property](https://github.com/AnalyticalGraphicsInc/3d-tiles/tree/master/specification#bounding-volumes)
Every tile in the tileset can derive its bounding volume from the tileset bounding volume.

TODO: figure for how the tileset bounding volume is subdivided.

#### transform

The `transform` property specifies 4x4 affine transformation that transforms any tile in the tileset from the tileset's local coordinate system to a global coordinate system.
This is the same `transform` property which is defined per-tile in the core 3D Tiles specification [3D Tiles `transform` Property](https://github.com/AnalyticalGraphicsInc/3d-tiles/tree/implicit-tiling/specification#transforms)

### Subtree availability

Availability of tiles are broken up into subtree chunks. A subtree of availability is binary file where each tiles gets a bit: 1 if it exists, 0 if it does not. Every tile in the subtree must have a 0 or 1.
Tiles on the last level that have a 1 will have an additional subtree for requesting (unless that tile is also on the last level of the tree). Each level of the subtree has a minimimum size of 1 byte.
For example, a quadtrees root and first levels have some bit padding. An example quadtree subtree that is fully packed:
quad subtree: [0b00000001, 0b00001111, 0b11111111, 0b11111111, ...]

An example oct tree subtree that is fully packed:
oct subtree: [0b00000001, 0b11111111, 0b11111111, ...]

Bits are left to right, top to bottom raster order. LSB bits are earlier in the raster order.

Note: Padding bits in the root of the subtree can allow the subtree itself communicate how deep it goes. Will let implementation dictate that this is more desirable than fix sizes (don't think it will, hasn't yet).

Below is a binary subtree of 4 levels. There are two leaf tiles at level 3 (root is level 0) that are available.
These would have tiles available for requesting (like all the other 1's) but they would also have subtree binaries available for requesting as well, at uri "baseUri/availability/d/x" (d/x in this case since its binary(only for illustrative purposes). quad is d/x/y, oct is d/x/y/z)

![](subtreeBits.jpg)

Clearly, duds can exist (a subtree with 1 in the root (coinciding with the tile in the parent subtree's leaf level), and the rest 0's). Tiling can easily enough adjust its `subtreeLevel` to limit these.
Another approach could be to have the last level of the subtree have 2 bits to indicate no-tile/tile/tile+subtree. I don't think this is a common enough issue to introduce extra complexity that would be felt in subtree size and implementation. As mentioned already,
If it is an issue it can be easily remedied through other means that the spec provides.

We could use the 7 bits in the subtree root to store the subtree's level count (and remove the need for it in the `tileset.json`). During tiling, this could allow adding an extra level to a subtree, if there would be many duds without the extra level.

### Schema updates

See [Property reference](#reference-3DTILES_implicit_tiling-tileset-extension) for the `3DTILES_implicit_tiling.tileset` schema reference. The full JSON schema can be found in [3DTILES_implicit_tiling.tileset.schema.json](schema/3DTILES_implicit_tiling.tileset.schema.json).

## Notes
_This section is non-normative._

## Resources
_This section is non-normative._

## Property reference

* [`3DTILES_implicit_tiling Tileset JSON extension`](#reference-3DTILES_implicit_tiling-tileset-extension)

---------------------------------------
<a name="reference-3DTILES_implicit_tiling-tileset-extension"></a>
## 3DTILES_implicit_tiling Tileset JSON extension

Specifies the Tileset JSON properties for the 3DTILES_implicit_tiling.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**boundingVolume**|`object`|A bounding volume that encloses the tileset.  Exactly one `box` or `region` property is required.|:white_check_mark: Yes|
|**rootTilesPerAxis**|`number` `[3]`|Defines the number of roots at level 0 in the tree.| :white_check_mark: Yes|
|**lastLevel**|`number`|Defines the last level in the tileset. 0 indexed.| :white_check_mark: Yes|
|**refine**|`string`|Specifies if additive or replacement refinement is used when traversing the tileset for rendering. This refinement applies to the entire tileset.|:white_check_mark: Yes|
|**firstSubtreesWithContent**|`array`|Defines the first set of subtree keys that are available in the tileset.| :white_check_mark: Yes|
|**splitAxes**|`number`|Defines the implied subdivision scheme for all tiles in the tileset.| :white_check_mark: Yes|
|**subtreeLevels**|`number`|Defines how many levels each availability subtree contains.| :white_check_mark: Yes|

Additional properties are not allowed.

### boundingVolume :white_check_mark:

A bounding volume that encloses the tileset.  Exactly one `box` or `region` property is required.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**box**|`number` `[12]`|An array of 12 numbers that define an oriented bounding box.  The first three elements define the x, y, and z values for the center of the box.  The next three elements (with indices 3, 4, and 5) define the x axis direction and half-length.  The next three elements (indices 6, 7, and 8) define the y axis direction and half-length.  The last three elements (indices 9, 10, and 11) define the z axis direction and half-length.|No|
|**region**|`number` `[6]`|An array of six numbers that define a bounding geographic region in EPSG:4979 coordinates with the order [west, south, east, north, minimum height, maximum height]. Longitudes and latitudes are in radians, and heights are in meters above (or below) the WGS84 ellipsoid.|No|

Additional properties are not allowed.

#### BoundingVolume.box

An array of 12 numbers that define an oriented bounding box. The first three elements define the x, y, and z values for the center of the box.  The next three elements (with indices 3, 4, and 5) define the x axis direction and half-length.  The next three elements (indices 6, 7, and 8) define the y axis direction and half-length.  The last three elements (indices 9, 10, and 11) define the z axis direction and half-length.

* **Type**: `number` `[12]`
* **Required**: No

#### BoundingVolume.region

An array of six numbers that define a bounding geographic region in EPSG:4979 coordinates with the order [west, south, east, north, minimum height, maximum height]. Longitudes and latitudes are in radians, and heights are in meters above (or below) the WGS84 ellipsoid.

* **Type**: `number` `[6]`
* **Required**: No

### rootTilesPerAxis :white_check_mark:

Defines the number of roots at level 0 in the tree. This three element array contains the x, y, and z dimensions for a fixed grid at level 0 that holds the roots of the tileset. The last element is ignored for quadtrees.

* **Type**: `number` `[3]`
* **Required**: Yes
* **Minimum**: [1,1,1]

### lastLevel :white_check_mark:

Defines the last level in the tileset. 0 indexed.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: 0

### refine :white_check_mark:

Specifies if additive or replacement refinement is used when traversing the tileset for rendering. This refinement applies to the entire tileset.

* **Type**: `string`
* **Required**: No
* **Allowed values**:
   * `"ADD"`
   * `"REPLACE"`

### firstSubtreesWithContent :white_check_mark:

Defines the first set of subtree keys that are first available in the tileset.
Each element of the array is a four element array holding the d,x,y,z index in the tileset for the root of the subtree. The last element of this four element array is ignored for quadtrees.
The corresponding uri for this subtree of availability is `availability/d/x/y/z` for octrees and `availability/d/x/y` for quadtrees.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `number` `[4]`

### subdivision :white_check_mark:

Defines the implied subdivision for all tiles in the tileset.

* **Type**: `number`
* **Required**: Yes
* **Allowed Values**:
  * `2` Quadtree
  * `3` Octree

### subtreeLevels :white_check_mark:

Defines how many levels each subtree of availability contains.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: 1
