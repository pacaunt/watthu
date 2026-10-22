# watthu

Watthu is a small Typst utility for building and modifying objects created by
functions. It is useful when you want to keep a reusable set of constructor
arguments, derive variants from it, and apply the result later.

## Import

When using this checkout as a local Typst package:

```typ
#import "@local/watthu:0.0.1": arg, new, put, update
```

Use the package namespace where you installed watthu if it differs from
`@local`.

## Example

Watthu works with ordinary constructor functions. This example uses Cetz to
draw a circle, then creates a second version by changing its positional
arguments and named options:

```typ
#import "@local/watthu:0.0.1": arg, new, put
#import "@preview/cetz:0.5.3": canvas, draw

#canvas({
  import draw: *

  let first = new(circle, (0, 0), radius: 2, name: "first")
  let second = first
  second.push((
    arg(0): "first.east",
    anchor: "west",
    name: "second",
  ))

  put(first)
  put(second)
})
```

`new` captures the constructor and its initial arguments. The returned value
can be copied and extended with `.push(...)`; `put` applies the accumulated
changes and calls the constructor.

## API

### `new(func, ..props)`

Creates a deferred object from a constructor function. Positional arguments
are retained as constructor arguments, and named arguments are retained as
constructor options.

```typ
#let base = new(circle, (0, 0), radius: 2, name: "base")
```

### `arg(id)`

Creates a key for modifying a constructor argument:

- `arg(0)`, `arg(1)`, etc. select positional arguments by zero-based index.
- `arg("name")` selects a named argument.
- `arg(<all>)` selects the full array of positional arguments.
- `arg(<each>)` applies a change to each positional argument individually.

For example, a direct value replaces the selected argument:

```typ
let moved = base
moved.push((arg(0): (1, 0), name: "moved"))
```

With `arg(<each>)`, the value replaces every positional argument; an
`update(...)` function instead receives each argument individually:

```typ
let items = new(table, columns: 3)
items.push((arg(<each>): [Cell]))
```

### `update(value-or-function)`

Marks a change as an update. If given a function, the function receives the
current value and returns its replacement. If given any other value, that
value replaces the current value. Use it when a modification should be
computed from the existing argument rather than simply replacing it.

```typ
let centered = new(content, (0, 0), [Label])
centered.push((
  arg(1): update(align.with(center)),
))
```

### `put(object)`

Applies the object's modifications, calls its constructor with the resulting
arguments, and returns the constructed value.

## Modifications

Values passed to `.push(...)` are interpreted as follows:

- A dictionary specifies argument changes. Ordinary keys select named
  arguments; keys created with `arg(...)` select positional or grouped
  arguments.
- A function is applied as a wrapper to the constructed value.
- An array is treated as all positional arguments.
- A non-function, non-dictionary value is also treated as a wrapper, replacing
  the value with that constant.

Wrappers are applied in the order they were added. Direct argument
replacements are processed before `update(...)` changes, so updates can build
on the value established by earlier replacements.
