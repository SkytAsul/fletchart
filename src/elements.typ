#import "internals.typ": internal-element, internal-link
#import "utils.typ": cetz-rect-double
#import "deps.typ": fletcher
#import fletcher.shapes: diamond, pill, rect, parallelogram

#let decision = (name: "decision", shape: diamond.with(fit: 0), fill: color.teal)
#let beginning = (name: "beginning", shape: pill, fill: color.teal)
#let end = (name: "end", shape: pill, fill: color.teal)
#let process = (name: "process", shape: rect, fill: none)
#let predefined-process = (name: "predefined-process", shape: cetz-rect-double, fill: color.orange)
#let input-output = (name: "input-output", shape: parallelogram, fill: color.lime)

/// Creates a condition with as many choices as needed.
#let condition(id, content, ..choices) = {
  internal-element(
    id,
    decision,
    pad(1em, content),
    choices.pos().map(choice => internal-link(choice.destination, choice.label))
  )
}

/// Creates a single choice with a destination and an optional label.
#let choice(destination, label: none) = {
  (
    destination: destination,
    label: label
  )
}

/// Creates an action with an optional destination.
/// 
/// - id (str): unique ID of the action
/// - content (content): content displayed in the action block
/// - destination (str, element): next element (optional)
/// - type (beginning, end, process, predefined-process, input-output, dict): type of the action
#let action(id, content, destination: none, type: process) = {
  internal-element(
    id,
    type,
    content,
    if destination == none {()} else {(internal-link(destination, none),)}
  )
}

#let set-links(element, links) = {
  let obj = element.value
  obj.links = links
  return metadata(obj)
}
