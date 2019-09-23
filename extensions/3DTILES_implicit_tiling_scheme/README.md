# 3DTILES_implicit_tiling_scheme Extension

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

#### TODO: `time`, an array of pairs of key-frame timestamps and their folder prefix (t/d/x/y/z), maybe something like the below. Editing time is just editing a folder name.
```json
{
   "time" : [
     [some-ms-since-1970, t0],
     [some-ms-since-1970, t1],
     [some-ms-since-1970, t2],
     [some-ms-since-1970, t3]
   ]
}
```

#### TODO: `metadata`, an array of pairs of key-frame timestamps and their folder prefix (d/x/y/zMetadataName), maybe something like the below.
```json
{
   "metadata" : [
        "density",
        "temperature",
        "area",
        "volume"
   ]
}
```

## Tileset JSON Format Updates

### Tiling Scheme

The Tileset JSON describing a [3D Tiles](../../specification/README.md) tileset may be extended to include a `3DTILES_implicit_tiling_scheme` object. This object defines
the root level context from which the entire tileset structure (boundingVolumes, geometricError, subdivision) can be implied.

Below is an example of a Tileset JSON with the implicit tiling scheme extension set:

```json
{
    "asset": {
        "extras": {
            "ion": {
                "georeferenced": true,
                "movable": false
            }
        },
        "version": "1.0"
    },
    "geometricError": 563.8721715009725,
    "extensions": {
        "3DTILES_implicit_tiling_scheme": {
            "subdivision": 2,
            "refine": "REPLACE",
            "headCount": [2,1,1],
            "roots": [[0,0,0,0], [0,1,0,0]],
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
        }
    }
}
```

#### properties

`subdivision` defines the subdivision scheme for the tiles described by the tileset.json's corresponding available.json. In the example above, a type of 2 would indicate a quadtree subdivision.
Other possible types are defined in the type enumeration table below. The `subdivision` could be implied from `available`, however, with `headCount` you can layer `subdivision` types in any dimension so proper interpretation requires
explicitly stating the `subdivision` type.

External tilesets do not specify a `subdivision`.

|Type|Description|
|----|-----------|
|`0`|Reserved. Indicates no subdivision? (CDB negative levels, mips) |
|`1`|Reserved. Binary tree? |
|`2`|Quadtree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json.|
|`3`|Octree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json|

#### headCount

The `headCount` property specifies the number of heads in each dimension (x, y, and z, in that order) at level 0 as indicated by a three element array containing integers. A single root would be indicated by "headCount": [1, 1, 1].
A "dual-headed quad tree" or TMS style quadtree, where there are two roots side-by-side along the x dimension, would be indicated by "headCount": [2, 1, 1], "subdivision": 2.

`headCount` enables easy mapping onto other implicit tilings schemes. For example, in a `CDB` tiling scheme, each tileset.json boundingVolume would described the bounds of the latitude strip and the tileset.json headCount
would describe the resolution of cdb tiles in that strip. The available.json would tell you what heads are actually available.

External tilesets do not specify a `headCount`.

#### refine

The `refine` property specifies the refinement style and is either `REPLACE` or `ADD`. The refinement specified applies to all tiles in implied by a  tileset JSON.
This is the same `refine` metadata as described in [3D Tiles](../../specification/README.md).

External tilesets do not specify a `refine`.

#### boundingVolume

The `boundingVolume` property specifies boundingVolume context for the tileset.json and its available.json. The `boundingVolume` types are restricted to `region` and `box`.
The `boundingVolume`'s of descendants of a tileset.json spedified in it's available.json are derived from its `boundingVolume` and `subdivision` types.
This is the same `boundingVolume` metadata as described in [3D Tiles](../../specification/README.md).

External tilesets do not specify a `boundingVolume`.

#### transform

The `transform` property specifies 4x4 affine transformation to apply to the tileset. Per-tile transforms are unsupported.
This is the same `transform` metadata as described in [3D Tiles](../../specification/README.md).

External tilesets do not specify a `transform`.

#### roots

The `roots` property describes the first set of subtrees in the tree. It contains a single json object that is an array. Each element of the array holds an index containing the [d,x,y,z] key of the subtree that can be requested.

In the example above, the first subtrees that are available on level 0 at each head location. A subtree uri is this d,x,y,z key prepended with the subtree default folder location or `availability/D/X/Y/Z`.

The reason for this is for tilesets that are in a global context (region bounding volume) that start somewhere down the tree, say at level 10.

#### subtreeLevels

The `subtreeLevels` property is a number that specifies the fixed depth of all subtree availabilities for the tileset. In the example above this number is `10` meaning that any subtree that is requested out of the `availabililty` folder
(followed by the `d/x/y/z` index of the subtrees root within the tree) will specify availability for all nodes from the subtree root and down 10 levels.

#### lastLevel

The `lastLevel` property is a number that specifies the last tree level in the tileset. In the example above this number is `19` meaning that last level in the tree is level 19.
This number is indexed from 0 so if the number was 0 it would mean the tileset only has 1 level, the root level 0.


#### Schema updates

See [Property reference](#reference-3DTILES_implicit_tiling_scheme-tileset-extension) for the `3DTILES_implicit_tiling_scheme.tileset` schema reference. The full JSON schema can be found in [3DTILES_implicit_tiling_scheme.tileset.schema.json](schema/3DTILES_implicit_tiling_scheme.tileset.schema.json).


## Notes
_This section is non-normative._

## Resources
_This section is non-normative._

## Property reference

* [`3DTILES_implicit_tiling_scheme Tileset JSON extension`](#reference-3DTILES_implicit_tiling_scheme-tileset-extension)

---------------------------------------
<a name="reference-3DTILES_implicit_tiling_scheme-tileset-extension"></a>
## 3DTILES_implicit_tiling_scheme Tileset JSON extension

Specifies the Tileset JSON properties for the 3DTILES_implicit_tiling_scheme.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**subdivision**|`number`|Defines the implied subdivision for all tiles described by the `available` array in available.json.| :white_check_mark: Yes|
|**refine**|`string`|Defines the refinement scheme for all tiles described by the `available` array in available.json.| :white_check_mark: Yes|
|**headCount**|`array`|Defines the number of heads at level 0 in the tree.| :white_check_mark: Yes|
|**roots**|`array`|Defines the first set of subtree keys that are available in the tileset.| :white_check_mark: Yes|
|**subtreeLevels**|`number`|Defines how many levels each availability subtree contains.| :white_check_mark: Yes|
|**lastLevel**|`number`|Defines the last level in the tileset. 0 indexed.| :white_check_mark: Yes|
|**boundingVolume**|`object`|The `boundingVolumes` around level 0, not just the heads that are available.| :white_check_mark: Yes|

Additional properties are not allowed.

### subdivision :white_check_mark:

Defines the implied subdivision for all tiles described by the `available` array in available.json.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`

### refine :white_check_mark:

Defines the refinement scheme for all tiles described by the `available` array in available.json.

* **Type**: `string`
* **Required**: Yes

### headCount :white_check_mark:

Defines the number of heads at level 0 in the tree.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `number`

### roots :white_check_mark:

Defines the first set of subtree keys that are available in the tileset.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `array`

### subtreeLevels :white_check_mark:

Defines how many levels each availability subtree contains.

* **Type**: `number`
* **Required**: Yes

### lastLevel :white_check_mark:

Defines the last level in the tileset. 0 indexed.

* **Type**: `number`
* **Required**: Yes

### boundingVolume :white_check_mark:

Defines the bounds around all the heads (both available and unavailable) at level 0 in the tree.

* **Type**: `object`
* **Required**: Yes
* **Type of each property**: `array`
