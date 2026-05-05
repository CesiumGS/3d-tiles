# 3DTILES_content_conditional

## Contributors

* Marco Hutter, [javagl](https://github.com/javagl)
* Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.1 specification.

## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

## Overview

This extension adds support for conditional content in 3D Tiles, by defining the following elements:

- A new content _type_ that can be referred to via the content URI in a 3D Tiles data set.
- An _extension object_ in the top-level tileset JSON that describes the structure of the conditional content

In the context of this extension, 'conditional content' is tile content where the actual content data that is loaded and rendered depends on user-selectable criteria. In the context of this specification, the content data item that should be loaded and rendered is referred to as the _'active'_ content data. 


> **Implementation Note**
>
> This extension specification itself does not define the behavior of clients regarding this 'active' content data. Clients could choose to pre-load all content data items, to allow them to quickly switch between them when a certain item becomes active. Alternatively, they can choose to download a content item lazily when it becomes active. When they download the content lazily, they can choose to display the previously active content until the newly active content is available and ready to be rendered, or they can choose to display a placeholder or loading indicator instead.

### Conditional Content Type

The new content type for the conditional content is represented as a JSON file. Such a file can be referred to via a content URI in a 3D Tiles data set. The file contains an array `conditionalContents`, where each item is a [3D Tiles 1.1 `content`](https://github.com/CesiumGS/3d-tiles/blob/1.1/specification/schema/content.schema.json) with additional properties.

The additional properties that are defined for each item are the `keys`. These keys serve as the basis for deciding whether the respective content item should be active. The keys are objects with arbitrary properties that have the type `string`, `number`, or `boolean`. The set of properties is defined by the top-level extension object (as described below).

An example conditional content data is shown here: It defines two different content items. These contents contain different keys. The keys allow the application to select the contents to be 'active', depending on a time stamp and a revision indicator.

```jsonc
{
  "conditionalContents" : [ {
    "uri" : "content-0-0-2025-09-25-revision0.glb",
    "keys" : {
      "exampleTimeStamp" : "2025-09-25",
      "exampleRevision" : "revision0"
    }
  }, {
    "uri" : "content-0-0-2025-09-26-revision1.glb",
    "keys" : {
      "exampleTimeStamp" : "2025-09-26",
      "exampleRevision" : "revision1"
    }
  } ]
}
```
The `uri` of an item in the `conditionalContents` array is resolved relative to the conditional content JSON file.


### Top-level Extension Object

The structure of the conditional contents is defined with a top-level extension object in the tileset JSON. This object is stored as the `3DTILES_content_conditional` object in the `extensions` dictionary of the tileset JSON. An example of such an object - corresponding to the example content from the previous section - is shown here:

```jsonc
{
  "dimensions" : [ {
    "name" : "exampleTimeStamp",
    "keySet" : [ "2025-09-25", "2025-09-26" ]
  }, {
    "name" : "exampleRevision",
    "keySet" : [ "revision0", "revision1" ]
  } ]
}
```

It defines the `dimensions` that are available for selecting the content that should be active. Each dimension has a `name` that corresponds to the property name in the `keys` of the content object. And it defines a `keySet`, which defines the domain of the respective property, as an array of all values that appear as the values for the respective key in any content.

### Content Structure Constraints

- The items that are contained in the `conditionalContents` may refer to different content types. This includes the common content types that are supported as the [3D Tiles 1.1 tile formats](https://github.com/CesiumGS/3d-tiles/tree/1.1/specification/TileFormats). But the items may _not_ refer to _external tilesets_. And they may _not_ refer to other conditional contents.


## Schema

- [`3DTILES_content_conditional` extension object schema](./schema/tileset.3DTILES_content_conditional.schema.json)
- [Conditional content JSON schema](./schema/conditionalContent.schema.json)
  - [Conditional content item JSON schema](./schema/conditionalContentItem.schema.json)


