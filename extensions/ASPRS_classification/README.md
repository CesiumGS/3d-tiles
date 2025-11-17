⚠️ This is a proof-of-concept extension. Do not use!

# ASPRS_classification

ASPRS standard class codes are a set of numeric codes to classify lidar points based on the feature they represent, such as ground, vegetation, or buildings, as defined in [LAS Specification 1.4 - R14](https://higherlogicdownload.s3.amazonaws.com/ASPRS/9752340f-f766-5abd-193c-4813ddf7b704_file.pdf?X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEPD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIAnwYtTVFnj4GbvnZnVyeqrQiCQb23UNPwk82j21SgEXAiEAj0KGRKgr7yR00VQio1Q2bP4jldgklGhSgwok8ZNwHQIqugUIuP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgwzODAzMzczNDA3MDYiDJY2oto77Mh%2BLnhoCiqOBWmYo9CR%2FG4gsEnwzkRWt%2BQoAKOYusxMYNXBjc%2Bqpdn8x6rXlOgFzL6ic3%2FPRMMTbpT4z%2FCespYLvZwSb7qK2if40jM3CdlT94xT0%2FNuMkK7E9Xkd%2B1P%2BD6%2B%2BVpfdtGcMRIHGPy71XbSKfzdT7nOqIk38VNldb4JCwHAkD5A48F1D1H8ytf2i3mlv2NCt15ILkb1qny7PLONtU0fLxYkM7bigv%2BTyqBts4vDR1an2Wbju%2FHhDh3kdHlCAQmuDaxwVqjg1WJ1R0RVevm2Nac7VstdrAgkz7w%2BeU3wx2p3xRxSVKZUKJflO1Zx9jNJVa5MIqiUStkT2aYG1BWgUlBx2zTuvMvkXVHfSx%2FArVlbl3JLdGnZHjeg3X6dSG%2Bl3ff5oCYg8x9vPnaV1hv2pS9B%2FYm%2FA1KH486c1LQZk%2B6s2%2FkYpELvYNeSLBaeaVS6tQ6AJF1VWebkvr5Rp36hRV5NZkJEwLOy5TRXtPBAumCX8tYKd6lXH8wpGsIyVpllNlrrBU6yznB%2FSrUWRMUft6XPfNNY5HH3i%2B1UEYEu7ICYPIYSlaktNpYEX1gpaS4%2FdmgeX6DvwC3vR%2B0myjKcioQ9l3hZyc4FLnhLD0UdrQupyAs4pvtGdLSogj5FTOFrdqFb1fCr2vHjwyqZxugmpA0GaSdWekks4zCnXGEnNNTSzbg3qRXPehMNhQeL%2BgcgL4WruQFPjiK6F%2BnDsDi8GKMny17XWJm2speTq6gZWpRK9tEhJWuWyTWxcYD668pXJLpWD%2BTlBtPY%2Fk36J6%2F1oRd7nojeKP1APsDc7QbyY6b8iKGcMpzerqlDRbiceHtgx4Nr%2Fn6T8tsE2f6o7mYeIBCAkhYYBhhNwKknj%2Bdz6IWBVDDn1O7IBjqxAf7vZai4O8X7ktyhP7Yxwqkz1feLoOeCa4%2ButuaSG027mqKxZ6wpgxUz9jRpGz5CYrqPEeQvA1Cm8qrySVl%2FZ6oCBbeqCVp6fB1A0XKwZTszaejwGyZrZzE7QiafBNA0mhA66DQAiWT%2B4R2cLnp%2Fm%2FlnD85pzeZ%2FYLAJ3n9V0VIdo9q4POiKXANQBsB1ybcOcNo%2FVf6uoDLovvhYA5oVzVhSCevuy2%2Fx%2Fo41k8KJcE2hSg%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAVRDO7IERIEQVY3JP%2F20251117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251117T230842Z&X-Amz-SignedHeaders=host&X-Amz-Signature=49973fdf1f32115e45de875e7cc6ef1ae9274e4df9c50c6a31b2a80122c4f470).

This extension defines a [semantic](https://github.com/CesiumGS/3d-tiles/tree/main/specification/Metadata/Semantics) for ASPRS class codes that may be assigned to an [Enum](https://github.com/CesiumGS/3d-tiles/tree/main/specification/Metadata#enum).

![ASPRS Classification](images/classification.jpg)

## Optional vs. Required

This extension is optional, meaning it should be placed in the  `extensionsUsed`  list, but not in the  `extensionsRequired`  list.

## Semantics

* `"ASPRS_classification"` - may be assigned to an [Enum](https://github.com/CesiumGS/3d-tiles/tree/main/specification/Metadata#enum). The enum must define the following `values` and `valueType`.

```json
{
  "semantic": "ASPRS_classification",
  "values": [
    { "value": 0, "name": "Created, Never Classified" },
    { "value": 1, "name": "Unclassified" },
    { "value": 2, "name": "Ground" },
    { "value": 3, "name": "Low Vegetation" },
    { "value": 4, "name": "Medium Vegetation" },
    { "value": 5, "name": "High Vegetation" },
    { "value": 6, "name": "Building" },
    { "value": 7, "name": "Low Point (Noise)" },
    { "value": 8, "name": "Model Key-Point (Mass Point)" },
    { "value": 9, "name": "Water" },
    { "value": 12, "name": "Overlap Points" }
  ],
  "valueType": "UINT8"
}
```

## Example

The example below shows a property table containing per-point classification and intensity.

### Schema
```json
{
  "enums": {
    "classification": {
      "semantic": "ASPRS_classification",
      "values": [
        { "value": 0,  "name": "Created, Never Classified" },
        { "value": 1,  "name": "Unclassified" },
        { "value": 2,  "name": "Ground" },
        { "value": 3,  "name": "Low Vegetation" },
        { "value": 4,  "name": "Medium Vegetation" },
        { "value": 5,  "name": "High Vegetation" },
        { "value": 6,  "name": "Building" },
        { "value": 7,  "name": "Low Point (Noise)" },
        { "value": 8,  "name": "Model Key-Point (Mass Point)" },
        { "value": 9,  "name": "Water" },
        { "value": 12, "name": "Overlap Points" }
      ],
      "valueType": "UINT8"
    }
  },
  "classes": {
    "point": {
      "properties": {
        "classification": {
          "type": "ENUM",
          "enumType": "classification"
        },
        "intensity": {
          "type": "SCALAR",
          "componentType": "UINT16"
        }
      }
    }
  }
}
```

### Property table

```json
{
  "class": "point",
  "count": 100,
  "properties": {
    "classification": {
      "values": 0 // Index of buffer view containing packed UINT8 values
    },
    "intensity": {
      "value": 1 // Index of buffer view containing packed UINT16 values
    }
  }
}
```

