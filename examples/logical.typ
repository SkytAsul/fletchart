#import "../src/lib.typ" as fletchart

#import fletchart.logical: fc-logical, fc-if, fc-process, fc-begin, fc-end, fc-io, fc-predefined-process


#fc-logical({
  fc-begin[Thing]
  fc-if([Condition ?], {
      fc-io[Some IO]
  }, {
    [A random process]
    fc-if([Another condition ?], yes-label: "valid", {
      fc-predefined-process()[Predefined\ process]
    }, no-label: "invalid", {
      fc-end[Alright bye]
    })
  })
  fc-end[Followup and end]
}, debug: true)