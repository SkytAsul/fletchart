#import "deps.typ": cetz
#import cetz.draw

// Replace `auto` with a value
#let map-auto(value, fallback) = if value == auto { fallback } else { value }

#let cetz-rect-double(node, extrude) = {
  let double-w = 5pt
	let r = node.corner-radius
	let (w, h) = node.size.map(i => i/2 + extrude)

	// we first draw the outer rectangle otherwise the fill would overwrite
	// the inner rectangle
  w += double-w
	draw.rect(
		(-w, -h), (+w, +h),
		radius: if r != none { r + extrude },
	)
  w -= double-w
	draw.rect(
		(-w, -h), (+w, +h),
		radius: if r != none { r + extrude },
	)
}
