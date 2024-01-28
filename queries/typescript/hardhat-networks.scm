;;query networks in hardhat.config.ts
(( lexical_declaration
    (variable_declarator
        (type_annotation
            (type_identifier) @type (#eq? @type "HardhatUserConfig") 
        )
        (object (pair
            (property_identifier) @prop (#eq? @prop "networks")
            (object (pair
                (property_identifier) @networkName
            )) 
        ) @networks ) 
    )
))

(( lexical_declaration
    (variable_declarator
        (type_annotation
            (type_identifier) @type (#eq? @type "HardhatUserConfig") 
        )
        (object (pair
            (property_identifier) @prop (#eq? @prop "networks")
            (object (pair
                (string
                    (string_fragment) @networkName
                ) 
            ))
        ) @networks ) 
    )
))
