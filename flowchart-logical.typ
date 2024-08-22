#import "flowchart.typ": fc-declarative
#import "elements.typ": *

#let logic-action(type, content) = {
  metadata((
    class: "action",
    type: type,
    content: content
  ))
}

#let fc-process(content) = logic-action(process, content)
#let fc-predefined-process(content) = logic-action(predefined-process, content)
#let fc-begin(content) = logic-action(beginning, content)
#let fc-end(content) = logic-action(end, content)
#let fc-io(content) = logic-action(input-output, content)

/// Parses the elements from a logical content
/// and returns an ordered list of elements.
#let parse-contents(logic, n) = {
  assert.eq(type(logic), content, message: "logic parameter has wrong type")

  let elements = ()
  let next-element

  let logic-elements = if logic.has("children") { logic.children } else { (logic,) }

  for content-piece in logic-elements.rev(){
    if content-piece.func() != metadata {
      content-piece = fc-process(content-piece)
    }

    assert.eq(content-piece.func(), metadata, message: "Invalid content child type")
    let obj = content-piece.value

    if obj.class == "action" {
      n += 1
      if obj.type == end { next-element = none }
      next-element = action(str(n), obj.content, destination: next-element, type: obj.type)
      elements.push(next-element)
      if obj.type == beginning { next-element = none }
    } else if obj.class == "if" {
      let choices = ()
      for (branch-label, branch-logic) in ((obj.yes-label, obj.yes), (obj.no-label, obj.no)) {
        let branch-elements = parse-contents(branch-logic, n)
        n += branch-elements.len()
        elements += branch-elements.rev()
        choices.push(choice(branch-elements.at(0), label: branch-label))
      }
      n += 1
      next-element = condition(str(n), obj.content, ..choices)
      elements.push(next-element)
    } else {
      assert(false, "Unknown object class " + obj.class)
    }
  }

  return elements.rev()
}

/// Creates an "if" branching
/// Cannot name it "if" because it's a reserved keyword. Same for "no": cannot name it "else".
#let fc-if(content, yes-label: "yes", yes, no-label: "no", no) = {
  // we do not parse and create the condition element right here
  // because we lack context on how to decide the ID of the element
  metadata((
    class: "if",
    content: content,
    yes-label: yes-label,
    yes: yes,
    no-label: no-label,
    no: no
  ))
}

/// Creates a flowchart based on a logical block.
#let fc-logical(logic, debug: false) = {
  let elements = parse-contents(logic, 0)

  let elements-content = elements.join()

  fc-declarative(elements-content, debug: debug)
}