# 3DTILES_binary_buffers

## Overview

This extension to 3D Tiles enables storage of binary data in external buffers.

## Concepts

### Element Types

| Element Type | No. of components |
|:------------:|:-----------------:|
| SCALAR | 1 |
| STRING | 1 |
| VEC2 | 2 |
| VEC3 | 3 | 
| VEC4 | 4 |
| MAT2 | 4 |
| MAT3 | 9 |
| MAT4 | 16 |

### Component Types

| Component | Size (bits) |
|:---------:|:------------:|
| BIT | 1 |
| BYTE | 8 |
| UNSIGNED_BYTE | 8 |
| SHORT | 16 |
| UNSIGNED_SHORT | 16 |
| HALF_FLOAT | 16 |
| INT | 32 |
| UNSIGNED_INT | 32 |
| FLOAT | 32 |
| DOUBLE | 64 |

### Buffers

Buffers are binary blobs of data.

### Buffer Views

Buffer views offer typed views into buffers. They specify a subset of the data stored in a buffer through a `byteOffset` and a `byteLength`. The type of data inside the buffers can be derived from the `elementType` and the `componentType` properties.
