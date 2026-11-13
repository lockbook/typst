// Test raw blocks.

--- raw-empty paged ---
// Empty raw block.
Empty raw block:``.

--- raw-consecutive-single-backticks paged ---
// No extra space.
`A``B`

--- raw-block-no-parbreaks paged ---
// Multiline block splits paragraphs.

Text
```rust
fn code() {}
```
Text

--- raw-more-backticks paged ---
// Lots of backticks inside.
````
```backticks```
````

--- raw-trimming paged ---
// Trimming.

// Space between "rust" and "let" is trimmed.
The keyword ```rust let```.

// Trimming depends on number backticks.
(``) \
(` untrimmed `) \
(``` trimmed` ```) \
(``` trimmed ```) \
(``` trimmed```) \

--- raw-single-backtick-lang paged ---
// Single ticks should not have a language.
`rust let`

--- raw-dedent-first-line paged ---
// First line is not dedented and leading space is still possible.
     ```   A
        B
       C
     ```

--- raw-dedent-empty-line paged ---
// Do not take empty lines into account when computing dedent.
```
        A

        B
```

--- raw-dedent-last-line paged ---
// Take last line into account when computing dedent.
```
        A

        B
    ```

--- raw-empty-inline eval ---
#let raw = ``
#test(raw.text, "")
#test(raw.block, false)

--- raw-empty-spaces eval ---
#let raw = ```   ```
#test(raw.text, "")
#test(raw.block, false)

--- raw-empty-newlines eval ---
#let raw = ```


```
#test(raw.text, "\n")
#test(raw.block, true)

--- raw-newlines-backtick eval ---
#let raw = ```

`

```
#test(raw.text, "\n`\n")
#test(raw.block, true)

--- raw-backtick eval ---
#let raw = ``` ` ```
#test(raw.text, "`")
#test(raw.block, false)

--- raw-lang-backtick eval ---
#let raw = ```lang ` ```
#test(raw.lang, "lang")
#test(raw.text, "`")
#test(raw.block, false)

--- raw-lang-backtick-no-space eval ---
// The language tag stops at a backtick even without whitespace.
// TODO: Do we want this behavior? It was not discussed in #7337.
#let raw = ```lang`test ` ```
#test(raw.lang, "lang")
#test(raw.text, "`test `")
#test(raw.block, false)

--- raw-lang-space eval ---
// The language tag stops at a space.
#let raw = ```lang test ```
#test(raw.lang, "lang")
#test(raw.text, "test ")
#test(raw.block, false)

--- raw-lang--multi-space eval ---
// The language tag only discards one space.
#let raw = ```lang  test```
#test(raw.lang, "lang")
#test(raw.text, " test")
#test(raw.block, false)

--- raw-lang-newline eval ---
// The language tag stops at a newline.
#let raw = ```lang
test
```
#test(raw.lang, "lang")
#test(raw.text, "test")
#test(raw.block, true)

--- raw-lang-no-text eval ---
// Warning: 12-22 empty raw text
// Hint: 12-22 Typst is treating `lang` as the language tag
// Hint: 15-19 to treat this as text, add a space after the initial backticks
#let raw = ```lang```
#test(raw.lang, "lang")
#test(raw.text, "")
#test(raw.block, false)

--- raw-lang-non-ident eval ---
// The language tag does not have to be a valid identifier.
// Warning: 15-25 no whitespace between language tag and raw text
// Hint: 15-19 if the current behavior is correct, please add a space after `lang`
// Hint: 15-19 otherwise, add a space or newline after the initial backticks
// Hint: 15-25 currently, Typst is treating `lang` as the language tag
// Hint: 15-25 in the next version of Typst, this will change and we will treat all text until the first whitespace as the language tag
#let raw = ```lang.tag++ test```
#test(raw.lang, "lang")
#test(raw.text, ".tag++ test")
#test(raw.block, false)

--- raw-lang-starts-non-ident eval ---
// Test the language tag starting with non-identifier characters.
// Warning: 15-31 no whitespace before raw text
// Hint: 15-31 in the next version of Typst, this text will be treated as the language tag for this element
// Hint: 15-31 to avoid this, add a space after the initial backticks
#let raw = ```!@#$%^&*()_+lang test```
#test(raw.text, "!@#$%^&*()_+lang test")
// Error: 11-15 field "lang" in raw is not known at this point
#test(raw.lang, none)
#test(raw.block, false)

--- raw-blocky eval ---
// The first line and the last line are ignored.
#let raw = {
```
test
```
}
#test(raw.text, "test")
#test(raw.block, true)

--- raw-blocky-dedent eval ---
// A blocky raw should handle dedents.
#let raw = {
```
test
```
}
#test(raw.text, "test")
#test(raw.block, true)

--- raw-blocky-dedent-firstline eval ---
// When there is content in the first line, we discard a single whitespace char.
#let raw = ``` test
  ```
#test(raw.text, "test")
#test(raw.block, true)

--- raw-blocky-dedent-firstline2 eval ---
// When there is content in the first line, we discard a single whitespace char.
#let raw = ``` test
```
#test(raw.text, "test")
#test(raw.block, true)

--- raw-blocky-dedent-firstline3 eval ---
// The first line is not affected by dedent, and the middle lines don't consider
// the whitespace prefix of the first line.
#let raw = ``` test
     test2
  ```
#test(raw.text, "test\n   test2")
#test(raw.block, true)

--- raw-blocky-dedent-firstline4 eval ---
// The first line is not affected by dedent, and the middle lines don't consider
// the whitespace prefix of the first line.
#let raw = ```     test
  test2
  ```
#test(raw.text, "    test\ntest2")
#test(raw.block, true)

--- raw-blocky-dedent-lastline eval ---
#let raw = ```
  test
 ```
#test(raw.text, " test")
#test(raw.block, true)

--- raw-blocky-dedent-lastline2 eval ---
#let raw = ```
  test
  ```
#test(raw.text, "test")
#test(raw.block, true)

--- raw-blocky-tab eval ---
#let raw = {
```
	test
```
}
#test(raw.text, "\ttest")
#test(raw.block, true)

--- raw-blocky-tab-dedent eval ---
// This one is a bit problematic because there is a trailing tab below "test"
// which the editor constantly wants to remove.
#let raw = eval("```\n\ttest\n  \n ```")
#test(raw.text, "test\n ")
#test(raw.block, true)

--- raw-extra-first-line-ws eval ---
#let raw = eval("```   \n```")
#test(raw.text, "")
#test(raw.block, true)

--- raw-tab-size paged ---
#set raw(tab-size: 8)

```tsv
Year	Month	Day
2000	2	3
2001	2	1
2002	3	10
```

--- raw-show-set paged ---
// Text show rule
#show raw: set text(font: "Roboto")
`Roboto`

--- raw-align-default paged ---
// Text inside raw block should be unaffected by outer alignment by default.
#set align(center)
#set page(width: 180pt)
#set text(6pt)

```py
def something(x):
  return x

a = 342395823859823958329
b = 324923
```

--- raw-align-specified paged ---
// Text inside raw block should follow the specified alignment.
#set page(width: 180pt)
#set text(6pt)

#align(center, raw(
  lang: "typ",
  block: true,
  align: right,
  "#let f(x) = x\n#align(center, line(length: 1em))",
))

--- raw-align-invalid eval ---
// Error: 17-20 expected `start`, `left`, `center`, `right`, or `end`, found top
#set raw(align: top)

--- raw-inline-multiline paged ---
#set page(width: 180pt)
#set text(6pt)
#set raw(lang:"python")

Inline raws, multiline e.g. `for i in range(10):
  # Only this line is a comment.
  print(i)` or otherwise e.g. `print(j)`, are colored properly.

Inline raws, multiline e.g. `
# Appears blocky due to linebreaks at the boundary.
for i in range(10):
  print(i)
` or otherwise e.g. `print(j)`, are colored properly.

--- raw-html html ---
This is ```typ *inline*```.
```typ
#[
  #set text(blue)
  *Hello* _world_!
]
```

--- raw-html-inline-spaces html ---
This has `double  spaces  inside`, which should be kept.

--- raw-line paged ---
#set page(width: 200pt)

```rs
fn main() {
    println!("Hello, world!");
}
```

#show raw.line: it => {
  box(stack(
    dir: ltr,
    box(width: 15pt)[#it.number],
    it.body,
  ))
  linebreak()
}

```rs
fn main() {
    println!("Hello, world!");
}
```

--- raw-line-alternating-fill paged ---
#set page(width: 200pt)
#show raw: it => stack(dir: ttb, ..it.lines)
#show raw.line: it => {
  box(
    width: 100%,
    height: 1.75em,
    inset: 0.25em,
    fill: if calc.rem(it.number, 2) == 0 {
      luma(90%)
    } else {
      white
    },
    align(horizon, stack(
      dir: ltr,
      box(width: 15pt)[#it.number],
      it.body,
    ))
  )
}

```typ
#show raw.line: block.with(
  fill: luma(60%)
);

Hello, world!

= A heading for good measure
```

--- raw-line-text-fill paged ---
#set page(width: 200pt)
#show raw.line: set text(fill: red)

```py
import numpy as np

def f(x):
    return x**2

x = np.linspace(0, 10, 100)
y = f(x)

print(x)
print(y)
```

--- raw-line-scripting paged empty ---

// Test line extraction works.

#show raw: code => {
  for i in code.lines {
    test(i.count, 10)
  }

  test(code.lines.at(0).text, "import numpy as np")
  test(code.lines.at(1).text, "")
  test(code.lines.at(2).text, "def f(x):")
  test(code.lines.at(3).text, "    return x**2")
  test(code.lines.at(4).text, "")
  test(code.lines.at(5).text, "x = np.linspace(0, 10, 100)")
  test(code.lines.at(6).text, "y = f(x)")
  test(code.lines.at(7).text, "")
  test(code.lines.at(8).text, "print(x)")
  test(code.lines.at(9).text, "print(y)")
  test(code.lines.at(10, default: none), none)
}

```py
import numpy as np

def f(x):
    return x**2

x = np.linspace(0, 10, 100)
y = f(x)

print(x)
print(y)
```

--- raw-empty-lines paged ---
// Test raw with multiple empty lines.

#show raw: block.with(width: 100%, fill: gray)

```




```

--- issue-6961-tab-crlf-raw-indent paged ---
#let snippet = (
  ```
  A
    BC
    D
  ```
)

#raw(
  snippet.text.replace("  ", "\t").replace("\n", "\r\n"),
  block: true,
)

--- issue-3191-raw-justify paged ---
// Raw blocks should not be justified by default.
```
a b c --------------------
```

#show raw: set par(justify: true)
```
a b c --------------------
```

--- issue-3191-raw-normal-paragraphs-still-shrink paged ---
// In normal paragraphs, spaces should still be shrunk.
// The first line here serves as a reference, while the second
// uses non-breaking spaces to create an overflowing line
// (which should shrink).
~~~~No shrinking here

~~~~The~spaces~on~this~line~shrink

--- issue-3820-raw-space-when-end-with-backtick paged ---
```typ
`code`
```

  ```typ
  `code`
  ```

--- issue-5760-disable-cjk-latin-spacing-in-raw paged ---

```typ
#let hi = "你好world"
```

#show raw: set text(cjk-latin-spacing: auto)
```typ
#let hi = "你好world"
```

--- issue-6559-equality-between-raws eval ---

#test(`foo`, `foo`)
#assert.ne(`foo`, `bar`)

--- raw-unclosed eval ---
// Test unterminated raw text.
//
// Note: This test should be the final one in the file because it messes up
// syntax highlighting.
//
// Error: 1:1-2:1 unclosed raw text
`endless
