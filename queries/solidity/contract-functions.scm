;; query to parse functions of a contract
((contract_declaration
   (contract_body
        (function_definition) @function
   )
))

((library_declaration
   (contract_body
        (function_definition) @function
   )
))
