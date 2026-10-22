#import "utils.typ"
#let _key-name = "__watthu_object_name__"

#let class(name, ..props) = ((_key-name): name, ..props.named())

#let is-class(obj) = type(obj) == dictionary and _key-name in obj.keys()

#let class-of(obj) = if is-class(obj) { obj.at(_key-name) } else { type(obj) }

#let Argument(index, value, base: true) = class("argument", index: index, value: value, base: base)

#let Updater(func) = class("updater", func: func)

#let Object(constructor, ..props) = class(
  "object",
  constructor: constructor,
  args: props.pos(),
  kwargs: props.named(),
)

/// Create a new object from a function with default properties.
/// -> array
#let new(
  /// Constructor function
  /// -> func
  func,
  /// default arguments
  /// -> arguments
  ..props,
) = (Object(func, ..props),)

#let _arg-prefix = "__watthu_arg_id:"
#let _kwarg-prefix = "__watthu_kwarg_id:"

/// Editing property of an object based on its arguments.
/// -> str
#let arg(
  /// Identifier. If this is an integer, it will target the positional argument at that index,
  /// if this is `<all>`, it will target all positional arguments as an array,
  /// if this is `<each>` it will target all positional arguments individually,
  /// if this is a string, it will target the named argument.
  /// -> int | label | str
  id,
) = {
  if type(id) == int or id in (<all>, <each>) {
    _arg-prefix + str(id)
  } else {
    _kwarg-prefix + str(id)
  }
}

#let argument(key, value) = {
  if key.starts-with(_arg-prefix) {
    let key-index = key.trim(_arg-prefix)
    if key-index in ("all", "each") {
      key-index = label(key-index)
    } else {
      key-index = int(key-index)
    }

    return Argument(key-index, value)
  }

  if key.starts-with(_kwarg-prefix) {
    let key-name = key.trim(_kwarg-prefix)
    return Argument(key-name, value)
  }

  return Argument(key, value)
}

#let modify(..props) = class(
  "modifier",
  wrappers: props.pos(),
  args: props.named(),
)

#let build-object(obj) = (obj.constructor)(..obj.args, ..obj.kwargs)

#let update-or-rewrite(updater) = if class-of(updater) == "updater" { return updater.func } else { (..args) => updater }

#let process-object(base, modifiers) = {
  let wrappers = modifiers
    .map(m => m.wrappers)
    .sum(default: ())
    .map(f => {
      if class-of(f) != function { return it => f }
      return f
    })

  let result = base
  let args = modifiers
    .map(m => m.args.pairs().map(a => argument(..a)))
    .flatten()
    .sorted(key: a => {
      if class-of(a.value) == "updater" { 1 } else { 0 }
    })

  for a in args {
    if type(a.index) == str {
      if a.index not in result.kwargs.keys() {
        result.kwargs.insert(a.index, a.value)
      } else {
        result.kwargs.at(a.index) = (update-or-rewrite(a.value))(result.kwargs.at(a.index))
      }
    } else if type(a.index) == int {
      if result.args.len() <= a.index {
        result.args.insert(a.index, a.value)
      } else {
        result.args.at(a.index) = (update-or-rewrite(a.value))(result.args.at(a.index))
      }
    } else if a.index == <all> {
      result.args = (update-or-rewrite(a.value))(result.args)
    } else if a.index == <each> {
      result.args = result.args.map(update-or-rewrite)
    } else {
      panic("Unknown argument editor")
    }
  }

  return utils.pipe(build-object(result), ..wrappers)
}

/// Runs the object through series of modifications.
/// -> any
#let put(
  /// The created object
  /// -> array
  obj,
) = {
  let (base, ..modifiers) = obj
  modifiers = modifiers.map(m => {
    if class-of(m) == "modifier" { return m }
    if class-of(m) == function { return modify(m) }
    if class-of(m) == dictionary { return modify(..m) }
    return modify(it => m)
  })

  return process-object(base, modifiers)
}

/// Updates the specified property using a function or 
/// set the property to the specified value without earlier modifications.
/// -> updater
#let update(
  /// The new value to set
  /// -> function | any
  func
) = {
  if class-of(func) != function { func = it => func }
  Updater(func)
}
