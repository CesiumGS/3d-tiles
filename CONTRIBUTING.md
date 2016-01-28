# Tile Format Spec Writing Guide

As we add more tile formats, 3D Tiles needs to stay consistent.

## Terminology

* Tiles are composed of `sections` such as `header` and `body`.  Sections are composed of `fields` such as `magic` and `version`.
* "Feature" - indicates one model in a batch of models (b3dm), one instance in a collection of instances (i3dm), one point in a point cloud (pnts), one polygon in a vector tile (vctr), etc.

## Fields

* Field names are in camelCase.
* `Length` - a `Length` suffix on a field name indicates the number of elements in an array.
* `ByteLength` - a `ByteLength` suffix indicates the number of bytes, not to be confused with just `Length`.

## Header

* Each tile format starts with a header that starts with the following fields:
```
magic            // uchar[4], indicates the tile format
version          // uint32,   1
byteLength       // uint32,   length, in bytes, of the entire tile.
```

## Binary

* All binary data, e.g., tile formats, are in little endian.
