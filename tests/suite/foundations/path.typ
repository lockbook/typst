--- path eval ---
#test(
  repr(path("hi/there.txt")),
  "path(\"/tests/suite/foundations/hi/there.txt\")",
)

--- path-backslash eval ---
// Error: 7-21 path must not contain a backslash
// Hint: 7-21 use forward slashes instead: `"to/file.txt"`
// Hint: 7-21 in earlier Typst versions, backslashes indicated path separators on Windows
// Hint: 7-21 this behavior is no longer supported as it is not portable
#path("to\\file.txt")
