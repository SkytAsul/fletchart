#import "internals.typ": internal-element, internal-link
#import "utils.typ": cetz-rect-double
#import "deps.typ": fletcher
#import fletcher.shapes: diamond, pill, rect, parallelogram

#let decision = (name: "decision", node-options: (shape: diamond.with(fit: 0), fill: color.orange.desaturate(50%)))
#let beginning = (name: "beginning", node-options: (shape: pill, fill: color.red.desaturate(50%)))
#let end = (name: "end", node-options: (shape: pill, fill: color.red.desaturate(50%)))
#let process = (name: "process", node-options: (shape: rect, fill: color.aqua.desaturate(50%)))
#let predefined-process = (name: "predefined-process", node-options: (shape: cetz-rect-double, fill: color.blue.desaturate(70%)))
#let input-output = (name: "input-output", node-options: (shape: parallelogram, fill: color.purple.desaturate(60%)))

#let resolve-style(base, overrides) = {
  let result = base
  for (key, value) in overrides.pairs() {
    result.insert(key, value)
  }
  return result
}

#let element(id, content, links, type, node-options) = {
  internal-element(
    id,
    content,
    links,
    options => {
      let style = type.node-options
      if type.name in options.elements-style-override {
        style = resolve-style(style, options.elements-style-override.at(type.name))
      }
      style = resolve-style(style, node-options)
      return style
    }
  )
}

/// Creates a condition with as many choices as needed.
/// - id (str): unique ID of the element
/// - content (content): content displayed in the decision block
/// - args (args): choices of this condition
///   and additional named options to pass to the `node` function from fletcher.
/// 
///   The options defined here will take precedence over the default options
///   of the the decision type and the overrides defined in
///   #the-param[fc-declarative][elements-style-override].
#let condition(id, content, ..args) = {
  element(
    id,
    pad(1em, content),
    args.pos().map(choice => internal-link(choice.destination, choice.label)),
    decision,
    args.named()
  )
}

/// Creates a single choice with a destination and an optional label.
#let choice(destination, label: none) = {
  (
    destination: destination,
    label: label
  )
}

/// Creates an action with a type and an optional destination.
/// 
/// - id (str): unique ID of the element
/// - content (content): content displayed in the action block
/// - destination (str, element): next element (optional)
/// - type (beginning, end, process, predefined-process, input-output, dict): type of the action
/// - node-options (args): additional named options to pass to the `node` function from fletcher.
/// 
///   The options defined here will take precedence over the default options
///   of the #the-param[action][type] and the overrides defined in
///   #the-param[fc-declarative][elements-style-override].
#let action(id, content, destination: none, type: process, ..node-options) = {
  assert(node-options.pos().len() == 0, message: "Cannot pass non-named node options.")
  
  element(
    id,
    content,
    if destination == none {()} else {(internal-link(destination, none),)},
    type,
    node-options.named()
  )
}

#let raw-element(id, content, links: (), ..node-options) = {
  assert(node-options.pos().len() == 0, message: "Cannot pass non-named node options.")

  internal-element(
    id,
    content,
    links,
    _ => node-options.named()
  )
}

#let set-links(element, links) = {
  let obj = element.value
  obj.links = links
  return metadata(obj)
}
