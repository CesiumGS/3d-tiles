# Declarative Styling

## Contributors

* Gabby Getz, [@ggetz](https://github.com/ggetz)
* Matt Amato, [@matt_amato](https://twitter.com/matt_amato)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

TBA: TOC

## Overview

TBA

## Examples

TBA

## Schema Reference

TBA (and full JSON schema)

## Expressions

TODO: intro

The syntax for expressions is derived from JavaScript [EMCAScript 5](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf), and includes a native color type.

_Implementation note: Cesium uses the [jsep](http://jsep.from.so/) JavaScript expression parser library to parse style expressions._

### Operators

The following operators are supported with the same semantics and precedence as JavaScript.

* Unary: `+`, `-`, `!`
   * Not supported: `~`
* Binary: `||`, `&&`, `===`, `!==`, `<`, `>`, `<=`, `>=`, `+`, `-`, `*`, `/`, `%`
   * Not supported: `|`, `^`, `&`, `==`, `!=`, `<<`, `>>`, and `>>>`
* Ternary: `? :`

`(` and `)` are supported for grouping expressions.

Logical `||` and `&&` implement short-circuiting; `true || expression` does not evaluate the right expression; and `false && expression` does not evaluate the right expression.

Similarly, `true ? left-expression : rightExpression` only executes the left expression, and `false ? leftExpression : right-expression` only executes the right expression.

### Types

The following types are supported:
* `Boolean`
* `Null`
* `Undefined`
* `Number`
* `String`
* `Color`

All of the types except `Color` are derived from JavaScript.  `Color` is derived from [CSS3 Colors](https://www.w3.org/TR/css3-color/).  Example expressions for different types include:
* `true`, `false`
* `null`
* `undefined`
* `1.0`, `NaN`, `Infinity`
* `'Cesium'`, `"Cesium"`
* `Color('#00FFFF')`

Array expressions are not supported.

#### Number

Like JavaScript, numbers include `NaN` and `Infinity`, and the functions:
* `isNaN(testValue : Number)`
* `isFinite(testValue : Number)`

#### Color

Colors are created with the following constructor functions:
* `Color()` `// default constructs #FFFFFF`
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

Colors defined with decimal rgb or hsl are defined with `rgb` and `hsl` functions, respectively, just like in CSS (but with perctange ranges from `0.0` to `1.0` for `0%` to `100%`, respectively).  For example:
* `rgb(100, 255, 190)`
* `hsl(1.0, 0.6, 0.7)`

The range for rgb components is `0` to `255`, inclusive.  For `hsl`, the range for hue, saturation, and lightness is `0.0` to `1.0`, inclusive.

Colors defined with `rgba` or `hsla` have a fourth argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `rgba(100, 255, 190, 0.25)`
* `hsla(1.0, 0.6, 0.7, 0.75)`

The functions `rgb`, `hsl`, `rgba`, and `hsla` require all their arguments.

Color supports the following binary operators by performing component-wise operations: `===`, `!==`, `+`, `-`, `*`, `/`, and `%`.  For example `Color() === Color()` is true since the red, green, blue, and alpha components are equal.

Color instances do not expose a `prototype` object.

Color instances have a `toString` for explicit (and implicit) conversion to strings of the form `'(red, green, blue, alpha)'`, which each component is in its internal range of `0.0` to `1.0`.

#### Conversions

JavaScript conversion rules are followed.  To minimize unexpected type coercion, `==` and `!=` operators are not supported.

For conversions involving `Color`, colors are treated as a JavaScript object.  For example, `Color` implicitly converts to `NaN` (`Number({})` is `NaN`) with `>`, `>=`, `<`, and `<=` operators.  In boolean expressions, `Color` implicit converts to `true`, e.g., `!!Color() === true`.  In string expressions, `Color` implicitly converts to `String` using its `toString` function.

### TODO

TODO: RegEx

#### Variables

Variables are used to retrieve the properties of individual features in a tileset.  Variables are identified using the ES 6 Template String syntax, i.e., `${identifier}`, where the identifier is the case-sensitive property name.

If a feature does not have a property with specified name, the variable evaluates to `undefined`.  Note that the property may also be `null` if `null` was explicitly stored for that property.

Variables may be any of the supported types:
* `Boolean`
* `Null`
* `Undefined`
* `Number`
* `String`
* `Color`

For example:
```
feature : {
    enabled : true,
    description : null
    details : undefined,
    order : 1
    name : 'Feature name',
    color : TODO
}
```
**TODO: need to think about how color is store in the batch table**
```
${enabled} === true
${description} === null
${details} === undefined
${order} === 1
${name} === 'Feature name'
${color} === Color('#FFFFFF')
```

Variables can also be substituted inside strings, for example:
```
feature : {
    order : 1,
    name : 'Feature name'
}
```
```
'Name is ${name}, order is ${order}'
```

### Notes

Comments are not supported.

## File Extension

TBA

## MIME Type

_TBA, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/json`
