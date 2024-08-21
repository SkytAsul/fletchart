#import "@preview/fletcher:0.5.1": diagram, node, edge

 #let flowchart-parse-links(elements, links) = {
  let new-links = ()
  for link in links{
    let position = elements.position(x => x == link.destination.value)
    assert(position != none, message: "Cannot find destination")
    link.destination = position
    new-links.push(link)
  }
  return new-links
 }

#let flowchart-parse-elements(elements) = {
  assert(type(elements) == content, message: "elements parameter has wrong type")

  let original-elements = ()
  let internal-elements = ()

  for content-piece in elements.children{
    assert(content-piece.func() == metadata, message: "Invalid content child type")
    let obj = content-piece.value

    if obj.class == "element" {
      original-elements.push(obj)
      let new-links = flowchart-parse-links(original-elements, obj.links)
      obj.links = new-links
      obj.insert("predecessors", ())
      internal-elements.push(obj)

      for link in new-links {
        let dest-element = internal-elements.at(link.destination)
        dest-element.predecessors.push(internal-elements.len() - 1)
        internal-elements.at(link.destination) = dest-element
      }
    } else {
      error("Unknown object class")
    }
  }

  return internal-elements
}

#let flowchart-create-element-node(internal-element, coordinates) = {
  node(coordinates, ..internal-element.node-options)
}

#let flowchart-layout-branch(internal-elements, index, layouted, coordinates) = {
  if str(index) in layouted { return (:) }

  let element = internal-elements.at(index)
  let self-layouted = (:)
  self-layouted.insert(str(index), coordinates)

  let link-from = int((element.links.len() - 1) / 2)
  let link-to = link-from + element.links.len()
  let last-x = coordinates.at(0) - link-from
  for (link-index, (destination, ..rest)) in range(link-from, link-to).zip(element.links) {
    let x = last-x
    let y = coordinates.at(1)
    if link-index == 0 or elements.links.len() > 3 {
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
1: 0
2: 0 1
3: -1 0 1
4: -1 0 1 2
5: -2 -1 0 1 2
*/

#let flowchart-layout(internal-elements) = {
  let layouted = (:)
  let last-x = 0
  for (index, element) in internal-elements.enumerate() {
    layouted += flowchart-layout-branch(internal-elements, index, layouted, (last-x, 0))
    last-x = layouted.values().map(x => x.at(0)).sorted().last() + 1
  }
  return layouted
}

#let flowchart(elements) = {
  let internal-elements = flowchart-parse-elements(elements)
  
  [#internal-elements]

  let layouted = flowchart-layout(internal-elements)

  [#layouted]
}

#import "elements.typ": *
#flowchart({
  let action1 = action("a")
  action1
  let action2 = action("b", destination: action1)
  action2
  action("c", destination: action2)
})

/*
TODO: pass to an explicit identifier
*/
