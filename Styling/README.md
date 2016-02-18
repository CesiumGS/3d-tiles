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

The syntax for expressions is derived from JavaScript.  

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
* `Color(keyword : String)`, `Color(6-digit-hex : String)`, `Color(3-digit-hex : String)`
* `rgb(red : Number, green : Number, blue : number)`, `rgba(red : Number, green : Number, blue : number, alpha : Number)`
* `hsl(hue : Number, saturation : Number/Percentage, lightness : Number/Percentage)`, `hsla(hue : Number, saturation : Number/Percentage, lightness : Number/Percentage, alpha : Number)`

Colors defined by keyword (e.g. `cyan`) or hex rgb (e.g., `#00FFFF`) should be passed as strings to the `Color` constructor (so that they can be differentiated from string types).  For example:
* `Color('cyan')`
* `Color('#00FFFF')`
* `Color('#0FF')`

**TODO: What does `Color()` produce?  What should it?  WHITE or DeveloperError?**

Colors defined with decimal rgb or hsl are defined with `rgb` and `hsl` functions, respectively, just like in CSS.  For example:
* `rgb(100, 255, 190)`
* `hsl(250, 60%, 70%)`

The range for rgb components are numbers in the range `0` to `255`, inclusive.  For `hsl`, the range for hue is `0` to `255`, and the range for saturation and lightness is `0%` to `100%`, inclusive.

Colors defined with `rgba` or `hsla` have a fourth argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `rgba(100, 255, 190, 0.25)`
* `hsla(250, 60%, 70%, 0.75)`

**TODO: should `Color` have an optional second argument for alpha, e.g., `Color('red', 0.5)`?  I think so.**

**TODO: `rgb`, `hsl`, `rgba`, and `hsla` should require all their arguments (assuming that is true in CSS).**

## File Extension

TBA

## MIME Type

_TBA, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/json`