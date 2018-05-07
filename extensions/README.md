# 3D Tiles Extensions

## Extensions

* [3DTILES_batch_table_hierarchy](./3DTILES_batch_table_hierarchy/)

## About

Extensions allow the base 3D Tiles specification to be extended with new features. They may add new properties to a 3D Tiles JSON object, and may add functionality a tile format or the 3D Tiles Styling expression language.

Extensions may not remove existing properties or features, nor redefine existing properties or features to mean something else. 

The optional `extensions` dictionary property may be added to a 3D Tiles JSON object, which contains the name of the extensions and the extension specific objects.

The following example shows a tile object with a hypothetical vendor extension which specifies a separate collision volume.
```JSON
{
  "transform": [
     4.843178171884396,   1.2424271388626869, 0,                  0,
    -0.7993325488216595,  3.1159251367235608, 3.8278032889280675, 0,
     0.9511533376784163, -3.7077466670407433, 3.2168186118075526, 0,
     1215001.7612985559, -4736269.697480114,  4081650.708604793,  1
  ],
  "boundingVolume": {
    "box": [
      0,     0,    6.701,
      3.738, 0,    0,
      0,     3.72, 0,
      0,     0,    13.402
    ]
  },
  "geometricError": 32,
  "content": {
    "url": "building.b3dm"
  },
  "extensions": {
    "VENDOR_collision_volume": {
      "box": [
        0,     0,    6.8,
        3.8,   0,    0,
        0,     3.8,  0,
        0,     0,    13.5
      ]
    }
  }
}
```

All extensions used in a tileset or any descendent external tilesets must be listed in the tileset JSON file in the top-level `extensionsUsed` array property, e.g.,

```JSON
{
    "extensionsUsed": [
        "VENDOR_collision_volume"
    ]
}
```

All extensions required to load and render a tileset or any descendent external tilesets must also be listed in the tileset JSON file in the top-level `extensionsRequired` array property, such that `extensionsRequired` is a subset of `extensionsUsed`. All values in `extensionsRequired` must also exist in `extensionsUsed`.