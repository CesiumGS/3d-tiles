# 3D Tiles Extensions

## Extensions

### Extensions for 3D Tiles 1.1

Extension|Notes
--|--
[3DTILES_bounding_volume_S2](./3DTILES_bounding_volume_S2)|_Written against 3D Tiles 1.1 and 1.0_

### Extensions for 3D Tiles 1.0

Extension|Notes
--|--
[3DTILES_content_gltf](./3DTILES_content_gltf)|_Promoted to core in 3D Tiles 1.1_
[3DTILES_multiple_contents](./3DTILES_multiple_contents)|_Promoted to core in 3D Tiles 1.1_
[3DTILES_metadata](./3DTILES_metadata)|_Promoted to core in 3D Tiles 1.1_
[3DTILES_implicit_tiling](./3DTILES_implicit_tiling)|_Promoted to core in 3D Tiles 1.1_
[3DTILES_bounding_volume_S2](./3DTILES_bounding_volume_S2)|_Written against 3D Tiles 1.1 and 1.0_
[3DTILES_batch_table_hierarchy](./3DTILES_batch_table_hierarchy/)|_Deprecated in 3D Tiles 1.1_
[3DTILES_draco_point_compression](./3DTILES_draco_point_compression/)|_Deprecated in 3D Tiles 1.1_

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
    "uri": "building.b3dm"
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

All extensions used in a tileset or any descendant external tilesets must be listed in the tileset JSON in the top-level `extensionsUsed` array property, e.g.,

```JSON
{
    "extensionsUsed": [
        "VENDOR_collision_volume"
    ]
}
```

All extensions required to load and render a tileset or any descendant external tilesets must be listed in the tileset JSON in the top-level `extensionsRequired` array. Extensions in `extensionsRequired` must also be listed in `extensionsUsed`.
