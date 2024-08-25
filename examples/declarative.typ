#import "../src/lib.typ" as fletchart

#import fletchart.elements: action, condition, choice, input-output, process
#import fletchart.declarative: fc-declarative


#fc-declarative({
  let actionA = action("a", "A", fill: color.fuchsia)
  let actionB = action("b", "B", destination: actionA)
  let actionC = action("c", "C", destination: "a")
  let actionD = action("d", "D", type: input-output)
  condition("x", "X", choice(actionC), choice(actionB), choice(actionD))
  actionC
  actionB
  actionA
  actionD
}, elements-style-override: (process.name: (fill: color.orange)), debug: true)