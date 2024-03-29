;;query describe blocks 
(( expression_statement
    ( call_expression
        function: ( identifier ) @func_id (#eq? @func_id "describe")
        arguments: ( arguments
            (string
                (string_fragment) @namespace.name
            ) 
        ) 
    ) @namespace.definition
)) 

;;query for it blocks wich use functions
( (expression_statement
    (call_expression
        function: (identifier) @func_id (#eq? @func_id "describe")
        (arguments (function_expression
          (statement_block
            (expression_statement
                (call_expression
                    function: (identifier) @test_func_id (#eq? @test_func_id "it")
                    arguments: (arguments
                            (string
                                (string_fragment) @test.name
                            ) 
                    ) @test.definition
                )
            )
          )
        ))
    )
) ) 

;;query for it blocks wich use arrow functions
( (expression_statement
    (call_expression
        function: (identifier) @func_id (#eq? @func_id "describe")
        (arguments (arrow_function
          (statement_block
            (expression_statement
                (call_expression
                    function: (identifier) @test_func_id (#eq? @test_func_id "it")
                    arguments: (arguments
                            (string
                                (string_fragment) @test.name
                            ) 
                    ) @test.definition
                )
            )
          )
        ))
    )
) ) 
