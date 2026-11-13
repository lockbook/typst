// Test references.

--- ref-basic paged html ---
#set heading(numbering: "1.")

= Introduction <intro>
See @setup.

== Setup <setup>
As seen in @intro, we proceed.

--- ref-label-missing paged ---
// Error: 1-5 label `<foo>` does not exist in the document
@foo

--- ref-label-duplicate paged ---
= First <foo>
= Second <foo>

// Error: 1-5 label `<foo>` occurs multiple times in the document
@foo

--- ref-form-page paged ---
#set page(numbering: "1")

Text <text> is on #ref(<text>, form: "page").
See #ref(<setup>, form: "page").

#set page(supplement: [p.])

== Setup <setup>
Text seen on #ref(<text>, form: "page").
Text seen on #ref(<text>, form: "page", supplement: "Page").

--- issue-4536-non-whitespace-before-ref paged empty ---
// Test reference with non-whitespace before it.
#figure[] <1>
#test([(#ref(<1>))], [(@1)])

--- ref-to-empty-label-not-possible paged ---
// @ without any following label should just produce the symbol in the output
// and not produce a reference to a label with an empty name.
@

--- ref-function-empty-label eval ---
// using ref() should also not be possible
// Error: 6-7 unexpected less-than operator
// Error: 7-8 unexpected greater-than operator
#ref(<>)
