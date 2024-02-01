;; query to parse a source file contract name if it exists
((contract_declaration
   (identifier) @contractName
))

((library_declaration
   (identifier) @contractName
))

((interface_declaration
   (identifier) @contractName
))
