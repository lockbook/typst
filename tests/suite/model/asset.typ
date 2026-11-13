--- asset bundle ---
#asset("data.json", "[1, 2]")

--- asset-outside-of-bundle paged ---
// Error: 2-20 assets are only supported in the bundle target
// Hint: 2-20 try enabling the bundle target
#asset("a.txt", "")

--- asset-nested bundle ---
// The error here is not ideal ...
#document("a.pdf")[
  // Error: 4-22 assets are only supported in the bundle target
  // Hint: 4-22 try enabling the bundle target
  #asset("a.txt", "")
]

--- asset-log bundle ---
#let log(..s) = [#metadata(s.pos().join("", default: ""))<log>]

#let compute-and-display(x) = {
  log("Start")
  let x = 1
  for _ in range(5) {
    x += x
    log("x = ", str(x))
  }
  log("End")
  [x is #x]
}

#document("index.html", compute-and-display(5))

#context asset(
  "log.txt",
  query(<log>).map(it => it.value).join("\n", default: ""),
)
