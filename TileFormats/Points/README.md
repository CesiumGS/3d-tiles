# Points

## Contributors

* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)
* Dan Bagnell, [@bagnell](https://github.com/bagnell)
* Sean Lilley, [@lilleyse](https://github.com/lilleyse)

## Overview

_TODO, [#22](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/22)_

## Layout

**Figure 1**: Points layout

![](figures/layout.png)

Positions are defined for high-precision rendering with [RTC](http://blogs.agi.com/insight3d/index.php/2008/09/03/precisions-precisions/). [#10](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/10)

## Batch Table Semantics

* `TILES3D_RGBA` - per-point colors, tightly packed interleaved RGBA `uint8` (32-bits per point).  Byte length: `header.pointsLength * 4`
* `TILES3D_RGB` - per-point colors, tightly packed interleaved RGB `uint8` (24-bits per point).  Byte length: `header.pointsLength * 3`
* `TILES3D_COLOR` - constant color for all points.  RGBA `uint8`.  Byte length: `4`

If more than one color semantic is defined, the precedence order is `TILES3D_RGBA`, `TILES3D_RGB`, then `TILES3D_COLOR`.  For example, if a tile's batch table contains both `TILES3D_RGBA` and `TILES3D_COLOR` properties, the runtime would render with per-point colors using `TILES3D_RGBA`.

If no color semantics are defined, the runtime is free to color points using an application-specific default color.

In any case, [3D Tiles Styling](../../Styling/README.md) may be used to change the final rendered color and other visual properties at runtime.

## File Extension

`.pnts`

## MIME Type

_TODO, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/octet-stream`