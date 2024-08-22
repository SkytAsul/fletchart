#import "@preview/fletcher:0.5.1": diagram, node, edge

#let flowchart-parse-elements(elements-args) = {
  assert.eq(type(elements-args), content, message: "elements parameter has wrong type")

  let internal-elements = (:)

  let elements = if elements-args.has("children") { elements-args.children } else { (elements-args,) }

  for content-piece in elements{
    assert.eq(content-piece.func(), metadata, message: "Invalid content child type")
    let obj = content-piece.value

    if obj.class == "element" {
      internal-elements.insert(obj.id, obj)
    } else {
      panic("Unknown object class " + obj.class)
    }
  }

  return internal-elements
}

#let flowchart-process-links(elements) = {
  for id in elements.keys() {
    elements.at(id).insert("predecessors", ())
  }
  for element in elements.values() {
    for link in element.links {
        let dest-element = elements.at(link.destination)
        dest-element.predecessors.push(element.id)
        elements.at(link.destination) = dest-element
      }
  }
  return elements
}

#let flowchart-layout-branch(internal-elements, id, layouted, coordinates) = {
  if id in layouted { return (:) }

  let element = internal-elements.at(id)
  let self-layouted = (:)
  self-layouted.insert(id, coordinates)

  let link-from = -int((element.links.len() - 1) / 2)
  let link-to = link-from + element.links.len()
  let link-indexes = range(link-from, link-to)
  let last-x = coordinates.at(0) + link-from
  for (link-index, (destination, ..rest)) in link-indexes.zip(element.links) {
    let x = last-x
    let y = coordinates.at(1)
    if link-index == 0 or element.links.len() > 3 {
      y += 1
    }
    if link-index == 0 {
      // move prev layouted to realign with 0
    }
    
    let link-layouted = flowchart-layout-branch(internal-elements, destination, layouted + self-layouted, (x, y))
    self-layouted += link-layouted
    if link-layouted.len() != 0{
      last-x = link-layouted.values().map(x => x.at(0)).sorted().last() + 1
    }
  }

  return self-layouted
}

/*
Branches order depending on amount of choices:
1: 0
2: 0 1
3: -1 0 1
4: -1 0 1 2
5: -2 -1 0 1 2
*/

#let flowchart-layout(internal-elements) = {
  let layouted = (:)
  let last-x = 0
  for element in internal-elements.values() {
    layouted += flowchart-layout-branch(internal-elements, element.id, layouted, (last-x, 0))
    last-x = layouted.values().map(x => x.at(0)).sorted().last() + 1
  }
  return layouted
}

#let flowchart-create-element-node(internal-element, coordinates) = {
  node(pos: coordinates, ..internal-element.node-options)
}

#let flowchart-create-link-edge(internal-link, from, to) = {
  edge(vertices: (from, to), ..internal-link.edge-options)
}

#let flowchart-create(internal-elements, debug) = {
  internal-elements = flowchart-process-links(internal-elements)

  let layouted = flowchart-layout(internal-elements)

  if debug [
    *Internal elements details:*
    #internal-elements
    
    *Elements layout positions:*
    #layouted

  ]

  let nodes = ()
  let edges = ()
  for element in internal-elements.values() {
    nodes.push(flowchart-create-element-node(element, layouted.at(element.id)))
    for link in element.links {
      edges.push(flowchart-create-link-edge(link, layouted.at(element.id), layouted.at(link.destination)))
    }
  }
  diagram(nodes, edges, node-stroke: 1pt, node-outset: 0pt, node-inset: .7em, debug: debug, spacing: 3em)
}

/// Creates a flowchart based on a list of elements.
#let fc-declarative(elements, debug: false) = {
  let internal-elements = flowchart-parse-elements(elements)

  flowchart-create(internal-elements, debug)
}
