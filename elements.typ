#import "@preview/fletcher:0.5.1" as fletcher
#import fletcher.shapes: diamond, pill, rect, parallelogram
#import fletcher.deps.cetz.draw

#let internal-element(id, shape, content, links) = {
  metadata((
    class: "element",
    id: id,
    node-options: (shape: shape, label: content),
    links: links
  ))
}

#let internal-link(destination, label) = {
  if type(destination) == content and destination.func() == metadata and destination.value.class == "element" {
    destination = destination.value.id
  } else if type(destination) != str {
    panic("Wrong destination format")
  }
  (
    destination: destination,
    edge-options: (label: label),
  )
}

#let set-links(element, links) = {
  let obj = element.value
  obj.links = links
  return metadata(obj)
}

/// Creates a condition with as many choices as needed.
#let condition(id, content, ..choices) = {
  internal-element(
    id,
    diamond.with(fit: 0),
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

#let rect-double(node, extrude) = {
  let double-w = -5pt
	let r = node.corner-radius
	let (w, h) = node.size.map(i => i/2 + extrude)
	draw.rect(
		(-w, -h), (+w, +h),
		radius: if r != none { r + extrude },
	)
  w += double-w
	draw.rect(
		(-w, -h), (+w, +h),
		radius: if r != none { r + extrude },
	)
}

#let beginning = ("beginning", pill)
#let end = ("end", pill)
#let process = ("process", rect)
#let predefined-process = ("predefined-process", rect-double)
#let input-output = ("input-output", parallelogram)

/// Creates an action with an optional destination.
/// 
/// - id (str): unique ID of the action
/// - content (content): content displayed in the action block
/// - destination (str, element): next element (optional)
/// - type (beginning, end, process, predefined-process, input-output): type of the action
#let action(id, content, destination: none, type: process) = {
  internal-element(
    id,
    type.at(1),
    content,
    if destination == none {()} else {(internal-link(destination, none),)}
  )
}
