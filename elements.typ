#import "@preview/fletcher:0.4.5" as fletcher
#import fletcher.shapes: diamond, pill, rect

#let internal-element(shape, content, links) = {
  metadata((
    class: "element",
    node-options: (shape: shape, label: content),
    links: links
  ))
}

#let internal-link(destination, label) = {
  (
    destination: destination,
    label: label
  )
}

#let condition(content, ..choices) = {
  internal-element(
    diamond,
    content,
    choices.pos().map(choice => internal-link(choice.destination, choice.label))
  )
}

#let choice(destination, label: none) = {
  (
    destination: destination,
    label: label
  )
}

#let action(content, destination: none) = {
  internal-element(
    rect,
    content,
    if destination == none {()} else {(internal-link(destination, none),)}
  )
}