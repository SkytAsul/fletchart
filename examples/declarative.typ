#import "../src/lib.typ" as fletchart

#import fletchart.elements: action, condition, choice
#import fletchart.declarative: fc-declarative


#fc-declarative({
  let actionA = action("a", "A")
  let actionB = action("b", "B", destination: actionA)
  let actionC = action("c", "C", destination: "a")
  let actionD = action("d", "D")
  condition("x", "X", choice(actionC), choice(actionB), choice(actionD))
  actionC
  actionB
  actionA
  actionD
}, debug: true)