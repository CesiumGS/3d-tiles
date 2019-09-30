# 3DTILES_implicit_tiling Extension

## Contributors

* Josh Lawrence, [@loshjawrence](https://github.com/loshjawrence)
* Shehzan Mohammed, [@shehzan10](https://github.com/shehzan10)
* Patrick Cozzi, [@pjcozzi](https://github.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Tileset JSON Format Updates](#tileset-json-format-updates)
   * [Tiling Scheme](#tiling-scheme)
   * [Available](#available)
   * [Notes](#notes)
* [Resources](#resources)
* [Property Reference](#property-reference)

## Overview

This extension enables the [3D Tiles JSON](../../specification/schema/tileset.schema.json) to support streaming tilesets with implied subdivision schemes.

## Tileset JSON Format Updates

### Tiling Scheme

The Tileset JSON describing a [3D Tiles](../../specification/README.md) tileset may be extended to include a `3DTILES_implicit_tiling` object. This object defines
the root level context from which the entire tileset structure (`boundingVolumes`, `geometricError`, `subdivision`, `refine`) can be implied.

Below is an example of a Tileset JSON with the implicit tiling scheme extension set:

```json
{
    "asset": {
        "version": "1.0"
    },
    "geometricError": 563.8721715009725,
    "extensions": {
        "3DTILES_implicit_tiling": {
            "subdivision": 2,
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
            "transform": {
                TODO: add transform (region tilesets would should bake its rotataion and get its rtc from the gltf CESIUM_RTC extension)
            }
        }
    }
}
```

### TODO:
* Context/Examples "give more context about the intent here first. Otherwise, non-expert readers will not be able to follow and may write 3D Tiles and implicit tiling off as "too complex" even though they are not."
* Readability: copy paste examples of the json into each section to prevent the need to scroll around.
* Figures subdirectory
* Precise language. Get rid of soft language like would/could.
* Consistent terms: level vs depth,
* Spell check.

#### properties
TODO: better name(subdivisions? partions? splits? numberOf*? *Count?)
TODO: Maybe a 3 element array of 0/1 saying which axes are split? ex: [1, 1, 0], [1, 1, 1], etc? name in this case would be something like splitAxes?
        * This is easily the most flexible but does it complicate impl (uri, data structures, algo)? or is it more like rootTilesPerAxis where it just plugs into an equation and it ends being even simpler than an enum?
`subdivision` defines the subdivision scheme for the entire tileset. In the example above, a type of 2 would indicate a quadtree subdivision, or the number of axes being split.
Other possible types are defined in the table below.

|Type|Description|
|----|-----------|
|`0`|TODO: Indicates no subdivision? (CDB negative levels, i.e. the mipped imagery) |
|`2`|Quadtree subdivision scheme.|
|`3`|Octree subdivision scheme.|

TODO: Add figure of what quad and oct examples.

#### refine

The `refine` property specifies the refinement style and is either `REPLACE` or `ADD`. The refinement specified applies to all tiles in the tileset.
This is the same `refine` property which is defined per-tile in the core 3D Tiles specification [3D Tiles](../../specification/README.md). TODO: deep link to the part of the 3D Tiles spec that explains it.

#### rootTilesPerAxis

The `rootTilesPerAxis` property specifies the number of roots in each dimension (x, y, and z, in that order) at tree level 0 as indicated by a three element array containing integers. A single root is indicated by "rootTilesPerAxis": [1, 1, 1].
A quadtree with two roots side-by-side along the x dimension, is indicated by "rootTilesPerAxis": [2, 1, 1]. The space is uniformly divided so all of the root tiles will have exactly the same geometric size, like a fixed grid.

TODO: Add figure. How does indexing correlate: 0 to n-1 for each dimension. left-right, top-bottom, back-front?

#### firstSubtreesWithContent

The `firstSubtreesWithContent` property describes the first set of subtrees that are available in the tree.
TODO: redo wording.
It is an array where each element holds a [d,x,y,z] key of the subtree that can be requested.
The this is needed to know where the tree starts for cases where the content starts somewhere down the tree (not at level 0, as can be the case with some tilesets defined in a globe context with a region bounding box) or if some roots are missing.

In the example above, the first subtrees that are available on level 0 at each of the available root locations. A subtree uri is this d,x,y,z key prepended with the subtree default folder location or `availability/d/x/y/z`.

#### subtreeLevels

TODO: Introduce core concepts in the preliminary paragraphs so that things like subtree and availability have some context when describing them in detail.

The `subtreeLevels` property is a number that specifies the fixed amount of levels in of all subtree availabilities for the tileset. In the example above this number is `10` meaning that any subtree that is requested out of the `availability` folder
(followed by the `d/x/y/z` index of the subtrees root within the tree) will specify availability for all tiles from the subtree root and down 10 levels. Available tiles on the last level of the subtree will have another subtree available for requesting.

#### lastLevel

The `lastLevel` property is a number that specifies the last tree level in the tileset. In the example above this number is `19` meaning that last level in the tree is level 19.
This number is indexed from 0 so if the number was 0 it would mean the tileset only has 1 level, the root at level 0.

#### boundingVolume

The `boundingVolume` property specifies bounding volume for the entire tileset.  The `boundingVolume` types are restricted to `region` and `box`.
This is the same `boundingVolume` property which is defined per-tile in the core 3D Tiles specification [3D Tiles](../../specification/README.md). TODO: deep link.
Every tile in the tileset can derive its bounding volume from the tileset bounding volume.

TODO: figure for how the tileset bounding volume is subdivided.
TODO: bounding region is technically implied for region, the only info we need is height min/max.

#### transform

The `transform` property specifies 4x4 affine transformation that transforms any tile in the tileset from the tileset's local coordinate system to a global coordinate system.
This is the same `transform` property which is defined per-tile in the core 3D Tiles specification [3D Tiles](../../specification/README.md). TODO: deep link.


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
These would have tiles available for requesting (like all the other 1's) but they would also have subtree binaries available for requesting as well, at uri "baseUri/availability/d/x" (d/x in this case since its binary. quad is d/x/y, oct is d/x/y/z)

![](subtreeBits.jpg)

Clearly, duds can exist (a subtree with 1 in the root (coinciding with the tile in the parent subtree's leaf level), and the rest 0's). Tiling can easily enough adjust its `subtreeLevel` to limit these.
Another approach could be to have the last level of the subtree have 2 bits to indicate no-tile/tile/tile+subtree. I don't think this is a common enough issue to introduce extra complexity that would be felt in subtree size and implementation. As mentioned already,
If it is an issue it can be easily remedied through other means that the spec provides.

We could use the 7 bits in the subtree root to store the subtrees level count (and remove the need for it in the tileset.json). During tiling, this could allow adding an extra level to a subtree, if there are many duds without the extra level.

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
|**boundingVolume**|`object`|The `boundingVolumes` around level 0, not just the roots that are available.| :white_check_mark: Yes|
|**rootTilesPerAxis**|`array`|Defines the number of roots at level 0 in the tree.| :white_check_mark: Yes|
|**lastLevel**|`number`|Defines the last level in the tileset. 0 indexed.| :white_check_mark: Yes|
|**refine**|`string`|Defines the refinement scheme for all tiles described by the `available` array in available.json.| :white_check_mark: Yes|
|**firstSubtreesWithContent**|`array`|Defines the first set of subtree keys that are available in the tileset.| :white_check_mark: Yes|
|**subdivision**|`number`|Defines the implied subdivision for all tiles described by the `available` array in available.json.| :white_check_mark: Yes|
|**subtreeLevels**|`number`|Defines how many levels each availability subtree contains.| :white_check_mark: Yes|

Additional properties are not allowed.

### boundingVolume :white_check_mark:

TODO: copy from 3dtiles spec

A bounding volume that encloses the tileset. Exactly one box or region  property is required.

* **Type**: `object`
* **Required**: Yes
* **Type of each property**: `array`

### rootTilesPerAxis :white_check_mark:

Defines the number of roots at level 0 in the tree.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `number`
* **Minimum**: 1

### lastLevel :white_check_mark:

Defines the last level in the tileset. 0 indexed.

* **Type**: `number`
* **Required**: Yes

### refine :white_check_mark:

TODO: copy from 3dtiles spec

Defines the refinement scheme for all tiles in the tileset.

* **Type**: `string`
* **Required**: Yes

### firstSubtreesWithContent :white_check_mark:

TODO: define the size of the sub arrays, i.e d/x/y vs d/x/y/z
Defines the first set of subtree keys that are available in the tileset.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `array`

### subdivision :white_check_mark:

Defines the implied subdivision for all tiles in the tileset.

* **Type**: `number`
* **Required**: Yes
* **Allowed Values**:
  * `2` Quadtree
  * `3` Octree

### subtreeLevels :white_check_mark:

Defines how many levels each availability subtree contains.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: 1
