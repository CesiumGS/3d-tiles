# Declarative Styling

## Contributors

* Gabby Getz, [@ggetz](https://github.com/ggetz)
* Matt Amato, [@matt_amato](https://twitter.com/matt_amato)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Overview

TBA

## Examples

TBA

## Schema Reference

TBA (and full JSON schema)

## Expressions

TODO: intro

The syntax for expressions is derived from JavaScript, but provides stronger typing, variables to access feature properties, and a native color type.

_Implementation note: Cesium used the [jsep](http://jsep.from.so/) JavaScript expression parser library to parse style expressions._

### Types

The following types are supported:
* `Boolean`
* `Null`
* `Undefined` **TODO: is this right?**
* `Number`
* `String`
* `Color`

All of the types except `Color` are derived from JavaScript.  `Color` is derived from [CSS3 Colors](https://www.w3.org/TR/css3-color/).  Example expressions include:
* `true`
* `null`
* `undefined`
* `1.0`
* `'Cesium'`
* `Color('#00FFFF')`

### Color

Colors are created with the following constructor functions:
* `Color(keyword : String)`
* `Color(6-digit-hex : String)`
* `Color(3-digit-hex : String)`
* `rgb(red : Number, green : Number, blue : number)`
* `rgba(red : Number, green : Number, blue : number, alpha : Number)`
* `hsl(hue : Number, saturation : Number, lightness : Number)`
* `hsla(hue : Number, saturation : Number, lightness : Number, alpha : Number)`

Colors defined by a case-insensitive keyword (e.g. `cyan`) or hex rgb (e.g., `#00FFFF`) are passed as strings to the `Color` constructor (so that they can be differentiated from string types).  For example:
* `Color('cyan')`
* `Color('#00FFFF')`
* `Color('#0FF')`

The `Color` constructor has an optional second argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `Color('cyan', 0.5)`

An empty `Color` constructor `Color()` produces white.

Colors defined with decimal rgb or hsl are defined with `rgb` and `hsl` functions, respectively, just like in CSS.  For example:
* `rgb(100, 255, 190)`
* `hsl(1.0, 0.6, 0.7)`

The range for rgb components is `0` to `255`, inclusive.  For `hsl`, the range for hue, saturation, and lightness is `0.0` to `1.0`, inclusive.

Colors defined with `rgba` or `hsla` have a fourth argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `rgba(100, 255, 190, 0.25)`
* `hsla(1.0, 0.6, 0.7, 0.75)`

The functions `rgb`, `hsl`, `rgba`, and `hsla` require all their arguments.

## File Extension

TBA

## MIME Type

_TBA, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/json`
