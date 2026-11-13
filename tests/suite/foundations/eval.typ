--- eval eval ---
// Test the eval function.
#test(eval("1 + 2"), 3)
#test(eval("1 + x", scope: (x: 3)), 4)
#test(eval("let x = x + 1; x + 1", scope: (x: 1)), 3)

--- eval-mode paged ---
// Test evaluation in other modes.
#eval("[_Hello" + " World!_]") \
#eval("_Hello" + " World!_", mode: "markup") \
#eval("RR_1^NN", mode: "math", scope: (RR: math.NN, NN: math.RR))

--- eval-syntax-error-1 eval ---
// Error: 7-12 expected pattern
#eval("let")

--- eval-in-show-rule paged ---
#show raw: it => text(font: "PT Sans", eval("[" + it.text + "]"))

Interacting
```
#set text(blue)
Blue #move(dy: -0.15em)[🌊]
```

--- eval-runtime-error eval ---
// Error: 7-17 cannot continue outside of loop
#eval("continue")

--- eval-syntax-error-2 eval ---
// Error: 7-12 expected semicolon or line break
#eval("1 2")

--- issue-2055-math-eval paged ---
// Evaluating a math expr should renders the same as an equation
#eval(mode: "math", "f(a) = cases(a + b\, space space x >= 3,a + b\, space space x = 5)")

$f(a) = cases(a + b\, space space x >= 3,a + b\, space space x = 5)$

--- issue-6067-eval-warnings paged empty ---
// Test that eval shows warnings from the executed code.
// Warning: 7-11 no text within stars
// Hint: 7-11 using multiple consecutive stars (e.g. **) has no additional effect
#eval("**", mode: "markup")
