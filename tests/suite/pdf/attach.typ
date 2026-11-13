// Test file attachments. The tests here so far are unsatisfactory because we
// have no PDF testing infrastructure. That should be improved in the future.

--- pdf-attach paged empty ---
#pdf.attach("/assets/text/hello.txt")
#pdf.attach(
  "/assets/data/details.toml",
  relationship: "supplement",
  mime-type: "application/toml",
  description: "Information about a secret project",
)

--- pdf-attach-zero-bytes paged empty ---
#pdf.attach("file", bytes(()))

--- pdf-attach-invalid-relationship eval ---
#pdf.attach(
  "/assets/text/hello.txt",
  // Error: 17-23 expected "source", "data", "alternative", "supplement", or none
  relationship: "test",
  mime-type: "text/plain",
  description: "A test file",
)

--- pdf-attach-invalid-data eval ---
// Error: 39-46 expected bytes, found string
#pdf.attach("/assets/text/hello.txt", "hello")
