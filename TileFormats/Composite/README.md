# Composite

## Contributors

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Layout](#layout)
* [Header](#header)
* [Inner tiles](#inner-tiles)
* [File extension and MIME type](#file-extension-and-mime-type)
* [Acknowledgments](#acknowledgments)
* [Resources](#resources)

## Overview

The _Composite_ tile format enables concatenating tiles of different formats into one tile.

3D Tiles and the Composite tile allow flexibility for streaming heterogeneous datasets.  For example, buildings and trees could be stored either in two separate _Batched 3D Model_ and _Instanced 3D Model_ tiles or, using a Composite tile, the tiles can be combined.

Supporting heterogeneous datasets with both inter-tile (separate tiles of different formats that are in the same tileset) and intra-tile (different tile formats that are in the same Composite tile) options allows conversion tools to make trade-offs between number of requests, optimal type-specific subdivision, and how visible/hidden layers are streamed.

A Composite is a binary blob in little endian accessed in JavaScript as an `ArrayBuffer`.

## Layout

Composite layout (dashes indicate optional fields):

![](figures/layout.png)

## Header

The 16-byte header section contains the following fields:

|Field name|Data type|Description|
|----------|---------|-----------|
| `magic` | 4-byte ANSI string | `"cmpt"`.  This can be used to identify the arraybuffer as a Composite tile. |
| `version` | `uint32` | The version of the Composite format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire Composite tile, including this header and each inner tile, in bytes. |
| `tilesLength` | `uint32` | The number of tiles in the Composite. |

_TODO: code example reading header_

## Inner tiles

Inner tile fields are stored tightly packed immediately following the header section. No additional header is added on top of the tiles' preexisting headers, e.g., b3dm or i3dm headers. However, the following information describes general characteristics of the existing contents of relevant files' headers to explain common information that a Composite tile reader might exploit to find the boundaries of the inner tiles:

* Each tile starts with a 4-byte ANSI string, `magic`, that can be used to determine the tile format for further parsing.  See the [main 3D Tiles spec](../../README.md) for a list of tile formats.  Composite tiles can contain Composite tiles.
* Each tile's header contains a `uint32` `byteLength`, which defines the length of the inner tile, including its header, in bytes.  This can be used to traverse the inner tiles.
* For any tile format's version 1, the first 12 bytes of all tiles is the following fields:

|Field name|Data type|Description|
|----------|---------|-----------|
| `magic` | `uchar[4]` | Indicates the tile format |
| `version` | `uint32` | `1` |
| `byteLength` | `uint32` | Length, in bytes, of the entire tile. |

Refer to the spec for each tile format for more details.

## File extension and MIME type

Composite tiles use the `.cmpt` extension and `application/octet-stream` MIME type.

The file extension is optional. Valid implementations ignore it and identify a content's format by the `magic` field in its header.

## Acknowledgments

* [Christopher Mitchell, Ph.D.](https://github.com/KermMartian)

## Resources

1. [Python `packcmpt` tool in gltf2glb toolset](https://github.com/Geopipe/gltf2glb)
