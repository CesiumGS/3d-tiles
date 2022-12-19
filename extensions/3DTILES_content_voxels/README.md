# 3DTILES_content_voxels

## Contributors

* Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.1 specification.

## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

## Overview

```json
{
 "asset": {
   "version": "1.1"
 },
 "schema": {
   "classes": {
     "voxel": {
       "properties": {
         "temperature": {
           "type": "SCALAR",
           "componentType": "FLOAT32",
           "noData": 999.9
         },
         "salinity": {
           "type": "SCALAR",
           "componentType": "UINT8",
           "normalized": true,
           "noData": 255
         }
       }
     }
   }
 },
 "geometricError": 200.0,
 "root": {
   "geometricError": 100.0,
   "refine": "REPLACE",
   "boundingVolume": {
     "box": [...]
   },
   "content": {
     "uri": "{level}/{x}/{y}/{z}.voxel",
     "extensions": {
       "3DTILES_content_voxels": {
         "dimensions": [8, 8, 8],
         "padding": {
           "before": [1, 1, 1],
           "after": [1, 1, 1]
         },
         "class": "voxel"
       }
     }
   },
   "implicitTiling": {
     "subdivisionScheme": "OCTREE",
     "subtreeLevels": 6,
     "availableLevels": 14,
     "subtrees": {
       "uri": "{level}/{x}/{y}/{z}.subtree"
     }
   },
   "transform": [...]
 }
}
```

```json
{
 "buffers": [{
     "byteLength": 3649
   }],
 "bufferViews": [{
     "buffer": 0,
     "byteOffset": 0,
     "byteLength": 2916
   }, {
     "buffer": 0,
     "byteOffset": 2920,
     "byteLength": 729
   }],
 "propertyTables": [{
   "class": "voxel",
   "count": 729,
   "properties": {
     "temperature": {
       "values": 0
     },
     "salinity": {
       "values": 1
     }
   }
 }],
 "voxels": 0
}
```