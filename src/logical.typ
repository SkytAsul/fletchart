#import "declarative.typ": fc-declarative
#import "elements.typ": *
#import "utils.typ": map-auto

#let logic-action(type, content, ..node-options) = {
  assert(node-options.pos().len() == 0, message: "Cannot pass non-named node options.")
  metadata((
    class: "action",
    type: type,
    content: content,
    node-options: node-options.named()
  ))
}

#let fc-process = logic-action.with(process)
#let fc-predefined-process = logic-action.with(predefined-process)
#let fc-begin = logic-action.with(beginning)
#let fc-end = logic-action.with(end)
#let fc-io = logic-action.with(input-output)

/// Creates an "if" branching.
/// - content (content): Content shown on the condition block.
/// 
/// - yes (content): Content of the "yes" branch.
/// 
///   Same type as the #the-param[fc-logical][content].
/// 
/// - yes-label (str, content): Label shown on the "yes" arrow.
/// 
/// - no (content): Content of the "no" branch.
/// 
///   Same type as the #the-param[fc-logical][content].
/// 
/// - no-label (str, content): Label shown on the "no" arrow.
#let fc-if(content, yes-label: auto, yes, no-label: auto, no, ..node-options) = {
  // Cannot name it "if" because it's a reserved keyword. Same for "no": cannot name it "else".
  assert(node-options.pos().len() == 0, message: "Cannot pass non-named node options.")
  
  // We do not parse and create the condition element right here
  // because we lack context on how to decide the ID of the element.
  metadata((
    class: "if",
    content: content,
    yes-label: yes-label,
    yes: yes,
    no-label: no-label,
    no: no,
    node-options: node-options.named()
  ))
}

/// Parses the elements from a logical content
/// and returns an ordered list of elements.
/// - logic (content): content to parse the logic from
/// - n (int): amount of elements already parsed
/// - options (dict): options of the logic flowchart
/// - next-element (element): element that should follow the parsed ones in the logical order
#let parse-contents(logic, n, options, next-element: none) = {
  assert.eq(type(logic), content, message: "logic parameter has wrong type")

  let elements = ()

  let logic-elements = if logic.has("children") { logic.children } else { (logic,) }

  let content-accumulator = []

  for (index, content-piece) in logic-elements.rev().enumerate(){
    if content-piece.func() != metadata {
      content-accumulator = content-piece + content-accumulator

      if index + 1 == logic-elements.len() or logic-elements.at(index - 1).func() == metadata {
        content-piece = fc-process(content-accumulator)
        content-accumulator = []
      } else {
        continue
      }
    }

    assert.eq(content-piece.func(), metadata, message: "Invalid content child type")
    let obj = content-piece.value

    if obj.class == "action" {
      n += 1
      if obj.type == end { next-element = none }
      next-element = action(str(n), obj.content, destination: next-element, type: obj.type, ..obj.node-options)
      elements.push(next-element)
      if obj.type == beginning { next-element = none }
    } else if obj.class == "if" {
      let choices = ()
      for (branch-label, branch-label-default, branch-logic) in ((obj.yes-label, options.if-yes-label, obj.yes), (obj.no-label, options.if-no-label, obj.no)) {
        let branch-elements = parse-contents(branch-logic, n, options, next-element: next-element)
        if branch-elements.len() == 0 { continue }

        n += branch-elements.len()
        elements += branch-elements.rev()
        choices.push(choice(branch-elements.at(0), label: map-auto(branch-label, branch-label-default)))
      }
      n += 1
      next-element = condition(str(n), obj.content, ..choices, ..obj.node-options)
      elements.push(next-element)
    } else {
      assert(false, "Unknown object class " + obj.class)
    }
  }

  return elements.rev()
}

/// Creates a flowchart based on a logical block.
/// - elements (content): Content of the flowchart.
/// 
///   A combination of `fc-if`, `fc-process`, `fc-predinfed-process`,
///   `fc-begin`, `fc-end` and `fc-io` function calls, or `content` objects.
/// 
/// - if-yes-label (str, content): default value of #the-param[fc-if][yes-label]
/// 
/// - if-no-label (str, content): default value of #the-param[fc-if][no-label]
/// 
/// - other configuration parameters, the same ones as in `fc-declarative`.
#let fc-logical(logic, if-yes-label: "yes", if-no-label: "no", elements-style-override: (:), debug: false) = {
  let options = (
    if-yes-label: if-yes-label,
    if-no-label: if-no-label
  )
  
  let elements = parse-contents(logic, 0, options)

  let elements-content = elements.join()

  fc-declarative(
    elements-content,
    elements-style-override: elements-style-override,
    debug: debug
  )
}