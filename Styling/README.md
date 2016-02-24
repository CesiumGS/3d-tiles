# Styling

## Contributors

* Gabby Getz, [@ggetz](https://github.com/ggetz)
* Matt Amato, [@matt_amato](https://twitter.com/matt_amato)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

TBA: TOC

## Overview

3D Tiles styles provide concise declarative styling of tileset features.  A style defines expressions to evaluate a feature's `color` (RGB and translucency) and `show` properties, often based on the feature's properties stored in the tile's batch table.

Styles are a JSON format with expressions written in a small subset of JavaScript augmented for styling.

## Examples

TODO: test these examples
TODO: would be cool to include some screenshots here
TODO: introduce translucency property to assign without having to set RGB

The following style assigns the default show and color properties to each feature:
```json
{
    "show" : "true",
    "color" : "Color('#FFF')"
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
    "show" : "(${County} === regExp('/^Chest/')) && (${YearBuilt} >= 1970)"
}
```

Above, a compound conditional and regular expression are used to show only features whose county starts with `'Chest'` and whose year built is greater than or equal to 1970.

Colors can also be defined by expressions dependent on a feature's properties, for example:
```json
{
    "color" : "(${Temperature} > 90) ? Color('red') : Color('white')"
}
```

This colors features with a temperature above 90 red, and the others white.

The color's alpha component defines the feature's opacity, for example:
```json
{
   "color" : "Color(${red}, ${green}, ${blue}, (${volume} > 100 ? 0.5 : 1.0))"
}
```
This sets the feature's RGB color components from the feature's properties, and makes features with volume greater than 100 transparent.

In addition to a string containing an expression, `color` can be an object defining a map or color ramp.  For example:
```json
"color" : {
    "key" : "RegEx('^1(\\d)$').exec(${id})",
    "map" : {
        "1" : "Color('#FF0000')",
        "2" : "Color('#00FF00')"
    },
    "defaultValue" : "Color('#FFFFFF')"
}
```

TODO: what exactly should exec return? See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/exec
TODO: require new for constructor functions, e.g., `new Color('red')` and `new RegEx('^1(\\d)$')`.  Or rename these to lowercase.

`color` can also be a color ramp by using a conditional:
```json
"color" : {
    "key" : "${Height} / ${Area}",
    "conditional" : {
        "(${KEY} >= 1.0)  && (${KEY} < 10.0)"  : "Color('#FF00FF')",
        "(${KEY} >= 10.0) && (${KEY} < 30.0)"  : "Color('#FF0000')",
        "(${KEY} >= 30.0) && (${KEY} < 50.0)"  : "Color('#FFFF00')",
        "(${KEY} >= 50.0) && (${KEY} < 70.0)"  : "Color('#00FF00')",
        "(${KEY} >= 70.0) && (${KEY} < 100.0)" : "Color('#00FFFF')",
        "(${KEY} >= 100.0)"                    : "Color('#0000FF')"
    }
}
```

TODO: schema for conditional

## Schema Reference

TBA (and full JSON schema)

## Expressions

The language for expressions is a small subset of JavaScript ([EMCAScript 5](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf)) plus a native color type and access to tileset feature properties in the form of readonly variables.

_Implementation tip: Cesium uses the [jsep](http://jsep.from.so/) JavaScript expression parser library to parse style expressions._

### Semantics

Dot notation is used to access properties by name, e.g., `color.red`.

Bracket notation (`[]`) is also used to access properties, e.g., `color['red']`, or arrays, e.g., `temperatures[1]`.

Functions are called with parenthesis (`()`) and comma-separated arguments, e.g., (`isNaN(0.0)`, `Color('cyan', 0.5)`).

### Operators

The following operators are supported with the same semantics and precedence as JavaScript.

* Unary: `+`, `-`, `!`
   * Not supported: `~`
* Binary: `||`, `&&`, `===`, `!==`, `<`, `>`, `<=`, `>=`, `+`, `-`, `*`, `/`, `%`
   * Not supported: `|`, `^`, `&`, `==`, `!=`, `<<`, `>>`, and `>>>`
* Ternary: `? :`

`(` and `)` are also supported for grouping expressions for clarity and precedence.

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

All of the types except `Color` are from JavaScript and have the same syntax and runtime behavior as JavaScript.  `Color` is derived from [CSS3 Colors](https://www.w3.org/TR/css3-color/) and behaves similar to a JavaScript `Object` (see the [Color section](#color)).

Example expressions for different types include:
* `true`, `false`
* `null`
* `undefined`
* `1.0`, `NaN`, `Infinity`
* `'Cesium'`, `"Cesium"`
* `Color('#00FFFF')`

Explicit conversions between primitive types are handled with `Boolean`, `Number`, and `String` functions. For example:

```
Boolean(1) === true
Number('1') === 1
String(1) === '1'
```

#### Number

Like JavaScript, numbers can be `NaN` or `Infinity`.  The following test functions are supported:
* `isNaN(testValue : Number)`
* `isFinite(testValue : Number)`

#### Color

Color objects are created with the following constructor functions:
* `Color()` `// default constructs #FFFFFF`
* `Color(keyword : String, [alpha : Number])`
* `Color(6-digit-hex : String, [alpha : Number])`
* `Color(3-digit-hex : String, [alpha : Number])`

And the following creation functions:
* `rgb(red : Number, green : Number, blue : number)`
* `rgba(red : Number, green : Number, blue : number, alpha : Number)`
* `hsl(hue : Number, saturation : Number, lightness : Number)`
* `hsla(hue : Number, saturation : Number, lightness : Number, alpha : Number)`

The functions `rgb`, `hsl`, `rgba`, and `hsla` require all their arguments.

Colors defined by a case-insensitive keyword (e.g. `cyan`) or hex rgb are passed as strings to the `Color` constructor.  For example:
* `Color('cyan')`
* `Color('#00FFFF')`
* `Color('#0FF')`

These constructor functions have an optional second argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `Color('cyan', 0.5)`

Colors defined with decimal rgb or hsl are defined with `rgb` and `hsl` functions, respectively, just like in CSS (but with perctange ranges from `0.0` to `1.0` for `0%` to `100%`, respectively).  For example:
* `rgb(100, 255, 190)`
* `hsl(1.0, 0.6, 0.7)`

The range for rgb components is `0` to `255`, inclusive.  For `hsl`, the range for hue, saturation, and lightness is `0.0` to `1.0`, inclusive.

Colors defined with `rgba` or `hsla` have a fourth argument that is an alpha component to define opacity, where `0.0` is fully transparent and `1.0` is fully opaque.  For example:
* `rgba(100, 255, 190, 0.25)`
* `hsla(1.0, 0.6, 0.7, 0.75)`

Colors store rgba components internally where each component is in the range `0.0` to `1.0`.  They are accessed with readonly properties:
* `red : Number`
* `green : Number`
* `blue : Number`
* `alpha : Number`

For example: `color.red`.

Color objects support the following binary operators by performing component-wise operations: `===`, `!==`, `+`, `-`, `*`, `/`, and `%`.  For example `Color() === Color()` is true since the red, green, blue, and alpha components are equal.

Color objects have a `toString` function for explicit (and implicit) conversion to strings in the format `'(red, green, blue, alpha)'`.

Color objects do not expose any other functions or a `prototype` object.

#### Conversions

Style expressions follow JavaScript conversion rules.  To minimize unexpected type coercion, `==` and `!=` operators are not supported.

For conversions involving `Color`, color objects are treated as JavaScript objects.  For example, `Color` implicitly converts to `NaN` with `>`, `>=`, `<`, and `<=` operators.  In boolean expressions, `Color` implicit converts to `true`, e.g., `!!Color() === true`.  In string expressions, `Color` implicitly converts to `String` using its `toString` function.

#### Regular Expressions

Regular expressions can be created with the following constructor functions:
* `RegExp()` - default constructor returns an empty regex, equivilent to `/(?:)/`
* `RegExp(pattern : String, [flags : String])`

The `RegExp` function behaves like the JavaScript [`RegExp`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp) constructor and takes the same arguments. All arguments must be literals, not expressions. 

Regular expressions support the functions:
* `test(string: String) : Boolean` - Tests the specified string for a match.  
* `exec(string: String) : String` - Executes a search for a match in the specified string. If the search succeeds, it returns the first instance of a captured `String`. If the search fails, it returns `null`

For example:
```json
{
    "name" : "Building 1"
}
```

```
RegExp("a").test("abc") === true
RegExp("a(.)").exec("abc") === 'b'
RegExp("Building\s(\d)").exec(${name}) === '1'
```

#### Variables

Variables are used to retrieve the property values of individual features in a tileset.  Variables are identified using the ES 6 ([ECMAScript 2015](http://www.ecma-international.org/ecma-262/6.0/)) Template Literal syntax, i.e., `${feature.identifier}` or `${feature['identifier']}`, where the identifier is the case-sensitive property name.  `feature` is implicit and can be ommited in most cases.

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
${color} === Color('#FFFFFF')
```

Variables can be used to constructor colors, for example:
```
Color(${red}, ${green}, ${blue}, ${alpha})
Color(${colorKeyword})
```

Dot or bracket notation is used to access feature sub-properties.  For example:
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

To access a feature named `feature`, use the variable `${feature}`. This is equivelent to accessing `${feature.feature}`

```json
{
    "feature" : "building"
}
```

```
${feature} === `building`
${feature.feature} === `building`
```

Variables can also be substituted inside strings defined with back-ticks, for example:
```json
{
    "order" : 1,
    "name" : "Feature name"
}
```
```
`Name is ${name}, order is ${order}`
```

Bracket notation is used to access feature sub-properties or arrays.  For example:
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

### Notes

Comments are not supported.

## File Extension

TBA

## MIME Type

_TBA, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/json`

## Acknowledgements

* Piero Toffanin, [@pierotofy](https://github.com/pierotofy)
