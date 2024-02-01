;; query to parse a function node without parameters and gets a function signature 
((function_definition
    (identifier) @functionName
    (function_body) @functionBody
))

;; query to parse a function node with parameters and gets a function signature 
((function_definition
    (identifier) @functionName
    (parameter
        (type_name) @paramType
    )
    (function_body) @functionBody
))
