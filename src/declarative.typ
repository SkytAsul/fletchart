#import "internals.typ": flowchart-create

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

/// Creates a flowchart based on a list of elements.
#let fc-declarative(elements, debug: false) = {
  let internal-elements = flowchart-parse-elements(elements)

  flowchart-create(internal-elements, debug)
}
