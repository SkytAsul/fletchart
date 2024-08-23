# fletchart
`fletchart` (contraction of `fletcher` and `flowchart`) is a Typst package made to easily create flowcharts using the `fletcher` package.

## How to use
There are two ways of creating flowcharts with `fletchart`:
1. The "declarative" way, where you create every element and manually setup the links between them. To use it:
    ```typst
    #import "src/lib.typ" as fletchart
    #import fletchart.declarative: fc-declarative
    #import fletchart.elements: *

    #fc-declarative({
        // your elements here
    })
    ```
1. The "logical" way, where you declare a logic structure with custom if-else blocks which will be automatically turned to a flowchart. To use it:
    ```typst
    #import "src/lib.typ" as fletchart
    #import fletchart.logical: fc-logical, fc-if, fc-process, fc-begin, fc-end, fc-io, fc-predefined-process

    #fc-logical({
        // your logic here
    })
    ```

## Examples
You can find examples in the [examples](examples) folder.