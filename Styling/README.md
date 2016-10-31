# Styling

![](figures/example.png)


```json
{
    "show" : "${Area} > 0",
    "color" : {
        "conditions" : [
            ["${Height} < 60", "color('#13293D')"],
            ["${Height} < 120", "color('#1B98E0')"],
            ["true", "color('#E8F1F2', 0.5)"]
        ]
    }
}
```

Example: Creating a color ramp based on building height.

## Contributors

* Gabby Getz, [@ggetz](https://github.com/ggetz)
* Matt Amato, [@matt_amato](https://twitter.com/matt_amato)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)


Contents:

* [Overview](#overview)
* [Examples](#examples)
* [Schema Reference](#schema-reference)
* [Expressions](#expressions)
   * [Semantics](#semantics)
   * [Operators](#operators)
   * [Types](#types)
      * [Number](#number)
      * [Color](#color)
      * [RegExp](#regexp)
   * [Conversions](#conversions)
   * [Variables](#variables)
   * [Built-in Functions](#built-in-functions)
   * [Notes](#notes)
* [File Extension](#file-extension)
* [MIME Type](#mime-type)
* [Acknowledgments](#acknowledgments)

## Overview

3D Tiles styles provide concise declarative styling of tileset features.  A style defines expressions to evaluate a feature's `color` (RGB and translucency) and `show` properties, often based on the feature's properties stored in the tile's batch table.

Styles are defined with JSON and expressions written in a small subset of JavaScript augmented for styling. Additionally the styling language provides a set of built-in functions to support common math operations.

## Examples

The following style assigns the default show and color properties to each feature:
```json
{
    "show" : "true",
    "color" : "color('#ffffff')"
}
```

Instead of showing all features, `show` can be an expression dependent on a feature's properties, for example:
```json
{
    "show" : "${ZipCode} === '19341'"
}
```

Here, only features in the 19341 zip code are shown.
```json
{
    "show" : "(regExp('^Chest').test(${County})) && (${YearBuilt} >= 1970)"
}
```

Above, a compound condition and regular expression are used to show only features whose county starts with `'Chest'` and whose year built is greater than or equal to 1970.

Colors can also be defined by expressions dependent on a feature's properties, for example:
```json
{
    "color" : "(${Temperature} > 90) ? color('red') : color('white')"
}
```

This colors features with a temperature above 90 as red and the others as white.

The color's alpha component defines the feature's opacity, for example:
```json
{
   "color" : "rgba(${red}, ${green}, ${blue}, (${volume} > 100 ? 0.5 : 1.0))"
}
```
This sets the feature's RGB color components from the feature's properties and makes features with volume greater than 100 transparent.

In addition to a string containing an expression, `color` and `show` can be an object defining a series of conditions (think of them as `if...else` statements).  Conditions can, for example, be used to make color maps and color ramps with any type of inclusive/exclusive intervals.

For example, here's a color map that maps an ID property to colors:
```json
{
    "color" : {
        "expression" : "regExp('^1(\\d)').exec(${id})",
        "conditions" : [
            ["${expression} === '1'", "color('#FF0000')"],
            ["${expression} === '2'", "color('#00FF00')"],
            ["true", "color('#FFFFFF')"]
        ]
    }
}
```

Conditions are evaluated in order so, above, if `${expression}` is not `'1'` or `'2'`, the `"true"` condition returns white. If no conditions are met, the color of the feature will be `undefined`.

The next example shows how to use conditions to create a color ramp using intervals with an inclusive lower bound and exclusive upper bound.
```json
"color" : {
    "expression" : "${Height}",
    "conditions" : [
        ["(${expression} >= 1.0)  && (${expression} < 10.0)", "color('#FF00FF')"],
        ["(${expression} >= 10.0) && (${expression} < 30.0)", "color('#FF0000')"],
        ["(${expression} >= 30.0) && (${expression} < 50.0)", "color('#FFFF00')"],
        ["(${expression} >= 50.0) && (${expression} < 70.0)", "color('#00FF00')"],
        ["(${expression} >= 70.0) && (${expression} < 100.0)", "color('#00FFFF')"],
        ["(${expression} >= 100.0)", "color('#0000FF')"]
    ]
}
```

Since `expression` is optional and conditions are evaluated in order, the above can more concisely be written as:
```json
"color" : {
    "conditions" : [
        ["(${Height} >= 100.0)", "color('#0000FF')"],
        ["(${Height} >= 70.0)", "color('#00FFFF')"],
        ["(${Height} >= 50.0)", "color('#00FF00')"],
        ["(${Height} >= 30.0)", "color('#FFFF00')"],
        ["(${Height} >= 10.0)", "color('#FF0000')"],
        ["(${Height} >= 1.0)", "color('#FF00FF')"]
    ]
}
```

Non-visual properties of a feature can be defined using the `meta` property. 

For example, to set a `description` meta property to a string containing the feature name:
```json
{
    "meta" : {
        "description" : "'Hello, ${featureName}.'"
    }
}
```

A meta property expression can evaluate to any type. For example:
```json
{
    "meta" : {
        "featureColor" : "rgb(${red}, ${green}, ${blue})",
        "featureVolume" : "${height} * ${width} * ${depth}" 
    }
}
```

## Schema Reference

TODO: generate reference doc from schema

Also, see the [JSON schema](schema).

## Expressions

The language for expressions is a small subset of JavaScript ([EMCAScript 5](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf)), plus native color and regular expression types and access to tileset feature properties in the form of readonly variables.

_Implementation tip: Cesium uses the [jsep](http://jsep.from.so/) JavaScript expression parser library to parse style expressions._

### Semantics

Dot notation is used to access properties by name, e.g., `color.red`.

Bracket notation (`[]`) is also used to access properties, e.g., `color['red']`, or arrays, e.g., `temperatures[1]`.

Functions are called with parenthesis (`()`) and comma-separated arguments, e.g., (`isNaN(0.0)`, `color('cyan', 0.5)`).

### Operators

The following operators are supported with the same semantics and precedence as JavaScript.

* Unary: `+`, `-`, `!`
   * Not supported: `~`
* Binary: `||`, `&&`, `===`, `==`, `!==`, `!=`, `<`, `>`, `<=`, `>=`, `+`, `-`, `*`, `/`, `%`, `=~`, `!~`
   * Not supported: `|`, `^`, `&`, `<<`, `>>`, and `>>>`
* Ternary: `? :`

`(` and `)` are also supported for grouping expressions for clarity and precedence.

Logical `||` and `&&` implement short-circuiting; `true || expression` does not evaluate the right expression, and `false && expression` does not evaluate the right expression.

Similarly, `true ? leftExpression : rightExpression` only executes the left expression, and `false ? leftExpression : rightExpression` only executes the right expression.

### Types

The following types are supported:
* `Boolean`
* `Null`
* `Undefined`
* `Number`
* `String`
* `Color`
* `RegExp`

All of the types except `Color` and `RegExp` have the same syntax and runtime behavior as JavaScript.  `Color` is derived from [CSS3 Colors](https://www.w3.org/TR/css3-color/) and behaves similarly to a JavaScript `Object` (see the [Color section](#color)).  `RegExp` is derived from JavaScript and described in the [RegExp section](#regexp).

Example expressions for different types include the following:
* `true`, `false`
* `null`
* `undefined`
* `1.0`, `NaN`, `Infinity`
* `'Cesium'`, `"Cesium"`
* `color('#00FFFF')`
* `regExp('^Chest'))`

Explicit conversions between primitive types are handled with `Boolean`, `Number`, and `String` functions.
* `Boolean(value : Any) : Boolean`
* `Number(value : Any) : Number`
* `String(value : Any) : String`

For example:

```
Boolean(1) === true
Number('1') === 1
String(1) === '1'
```

These are essentially casts, not constructor functions.

#### Number

As in JavaScript, numbers can be `NaN` or `Infinity`.  The following test functions are supported:
* `isNaN(testValue : Number) : Boolean`
* `isFinite(testValue : Number) : Boolean`

#### Color

Colors are created with one of the following functions:
* `color() : Color`
* `color(keyword : String, [alpha : Number]) : Color`
* `color(6-digit-hex : String, [alpha : Number]) : Color`
* `color(3-digit-hex : String, [alpha : Number]) : Color`
* `rgb(red : Number, green : Number, blue : number) : Color`
* `rgba(red : Number, green : Number, blue : number, alpha : Number) : Color`
* `hsl(hue : Number, saturation : Number, lightness : Number) : Color`
* `hsla(hue : Number, saturation : Number, lightness : Number, alpha : Number) : Color`

Calling `color()` with no arguments is the same as calling `color('#FFFFFF')`.

Colors defined by a case-insensitive keyword (e.g., `'cyan'`) or hex rgb are passed as strings to the `color` function.  For example:
* `color('cyan')`
* `color('#00FFFF')`
* `color('#0FF')`

These `color` functions have an optional second argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `color('cyan', 0.5)`

Colors defined with decimal rgb or hsl are created with `rgb` and `hsl` functions, respectively, just as in CSS (but with percentage ranges from `0.0` to `1.0` for `0%` to `100%`, respectively).  For example:
* `rgb(100, 255, 190)`
* `hsl(1.0, 0.6, 0.7)`

The range for rgb components is `0` to `255`, inclusive.  For `hsl`, the range for hue, saturation, and lightness is `0.0` to `1.0`, inclusive.

Colors defined with `rgba` or `hsla` have a fourth argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `rgba(100, 255, 190, 0.25)`
* `hsla(1.0, 0.6, 0.7, 0.75)`

Colors store rgba components internally, where each component is in the range `0.0` to `1.0`.  They are accessed with readonly properties:
* `red : Number`
* `green : Number`
* `blue : Number`
* `alpha : Number`

For example: `color.red`.

Colors support the following binary operators by performing component-wise operations: `===`, `==`, `!==`, `!=`, `+`, `-`, `*`, `/`, and `%`.  For example `color() === color()` is true since the red, green, blue, and alpha components are equal.  This is not the same behavior as a JavaScript `Object`, where, for example, reference equality would be used.  Operators are essentially overloaded for `Color`.

Colors have a `toString` function for explicit (and implicit) conversion to strings in the format `'(red, green, blue, alpha)'`.
* `toString() : String`

Colors do not expose any other functions or a `prototype` object.

#### RegExp

Regular expressions are created with the following functions, which behave like the JavaScript [`RegExp`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp) constructor:
* `regExp() : RegExp`
* `regExp(pattern : String, [flags : String]) : RegExp`

Calling `regExp()` with no arguments is the same as calling `regExp('(?:)')`.

If specified, `flags` can have any combination of the following values:

* `g` - global match
* `i` - ignore case
* `m` - multiline
* `u` - unicode
* `y`- sticky

Regular expressions support these functions:
* `test(string: String) : Boolean` - Tests the specified string for a match.  
* `exec(string: String) : String` - Executes a search for a match in the specified string. If the search succeeds, it returns the first instance of a captured `String`. If the search fails, it returns `null`

For example:
```json
{
    "Name" : "Building 1"
}
```

```
regExp('a').test('abc') === true
regExp('a(.)', 'i').exec('Abc') === 'b'
regExp('Building\s(\d)').exec(${Name}) === '1'
```

Regular expressions have a `toString` function for explicit (and implicit) conversion to strings in the format `'pattern'`.
* `toString() : String`

Regular expressions do not expose any other functions or a `prototype` object.

The operators `=~` and `!~` are overloaded for regular expressions. The `=~` operator matches the behavior of the `test` function, and tests the specified string for a match. It returns `true` if one is found, and `false` if not found. The `!~` operator is the inverse of the `=~` operator. It returns `true` if no matches are found, and `false` if a match is found. Both operators are communitive.

For example, the following expressions all evaluate to true:
```
regExp('a') =~ 'abc'
'abc' =~ regExp('a')

regExp('a') !~ 'bcd'
'bcd' !~ regExp('a')
```

If no `RegExp` is supplied as and operand, both operators will return `false`.

If both operands are of type `RegExp`, the left operand will be treated as the regular expression which is performing the match, and the right operand will be treated as the object which the test is being performed on. For example, `regExp('a') =~ regExp('abc')` will match the behavior of `regExp('a').test(regExp('abc'))`.

Regular expressions are treated as `NaN` when performing operations with operators other than `=~` and `!~`. 


### Conversions

Style expressions follow JavaScript conversion rules.

For conversions involving `Color` or `RegExp`, they are treated as JavaScript objects.  For example, `Color` implicitly converts to `NaN` with `==`, `!=`, `>`, `>=`, `<`, and `<=` operators.  In Boolean expressions, a `Color` implicitly converts to `true`, e.g., `!!color() === true`.  In string expressions, `Color` implicitly converts to `String` using its `toString` function.

### Variables

Variables are used to retrieve the property values of individual features in a tileset.  Variables are identified using the ES 6 ([ECMAScript 2015](http://www.ecma-international.org/ecma-262/6.0/)) Template Literal syntax, i.e., `${feature.identifier}` or `${feature['identifier']}`, where the identifier is the case-sensitive property name.  `feature` is implicit and can be omitted in most cases.

Variables can be used anywhere a valid expression is accepted, except inside other variable identifiers. For example, the following is not allowed:
```
${foo[${bar}]}
```

If a feature does not have a property with specified name, the variable evaluates to `undefined`.  Note that the property may also be `null` if `null` was explicitly stored for a property.

Variables may be any of the supported native JavaScript types:
* `Boolean`
* `Null`
* `Undefined`
* `Number`
* `String`

For example:
```json
{
    "enabled" : true,
    "description" : null,
    "order" : 1,
    "name" : "Feature name"
}
```

```
${enabled} === true
${description} === null
${order} === 1
${name} === 'Feature name'
```

Variables can be used to construct colors, for example:
```
rgba(${red}, ${green}, ${blue}, ${alpha})
color(${colorKeyword})
```

Dot or bracket notation is used to access feature subproperties.  For example:
```json
{
    "address" : {
        "street" : "Example street",
        "city" : "Example city"
    }
}
```

```
${address.street} === `Example street`
${address['street']} === `Example street`

${address.city} === `Example city`
${address['city']} === `Example city`
```

Bracket notation supports only string literals.

Top-level properties can be accessed with bracket notation by explicitly using the `feature` keyword. For example:

```json
{
    "address.street" : "Maple Street",
    "address" : {
        "street" : "Oak Street"
    }
}
```

```
${address.street} === `Oak Street`
${feature.address.street} === `Oak Street`
${feature['address'].street} === `Oak Street`
${feature['address.street']} === `Maple Street`
```

To access a feature named `feature`, use the variable `${feature}`. This is equivalent to accessing `${feature.feature}`

```json
{
    "feature" : "building"
}
```

```
${feature} === `building`
${feature.feature} === `building`
```

Variables can also be substituted inside strings defined with backticks, for example:
```json
{
    "order" : 1,
    "name" : "Feature name"
}
```
```
`Name is ${name}, order is ${order}`
```

Bracket notation is used to access feature subproperties or arrays.  For example:
```json
{
    "temperatures" : {
        "scale" : "fahrenheit",
        "values" : [70, 80, 90]
    }
}
```

```
${temperatures['scale']} === 'fahrenheit'
${temperatures.values[0]} === 70
${temperatures['values'][0]} === 70 // Same as (temperatures[values])[0] and temperatures.values[0]
```

### Built-in Functions

The following built-in functions are supported by the styling language:

* [`abs`](#abs)

#### abs

`abs(value : Number) : Number`

Returns the absolute value of the number.

```json
{
    "show" : "abs(${temperature}) > 20.0"
}
```

### Notes

Comments are not supported.

## File Extension

TBA

## MIME Type

_TBA, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/json`

## Acknowledgments

* Piero Toffanin, [@pierotofy](https://github.com/pierotofy)
