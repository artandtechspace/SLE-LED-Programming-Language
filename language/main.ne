@builtin "whitespace.ne"

# I dont know how to load different files without an error yet,
# so here is a very big single gramma file. Your welcome

program
    -> additive_float {% id %}
    |  bin_or_int {% id %}


#
# Integer Section
#

# Integer Operator precedence:
# 1. Unary
# 2. Multiply / Divide / Modulo
# 3. Addition / Subtraction
# 4. Binary And
# 5. Binary XOR
# 6. Binary OR

@{%
    function TokenInt(number){
        return {
            type: "int",
            value: number
        }
    }

    function TokenAdditiveInt(left, operator, right){
        return {
            type: "additive_int",
            left,
            operator,
            right
        }
    }

    function TokenMultiplicativeInt(left, operator, right){
        return {
            type: "multiplicative_int",
            left,
            operator,
            right
        }
    }

    function TokenUnaryInt(optOperator, content){
        return {
            type: "unary_int",
            content,
            operator: optOperator === null ? "+" : optOperator
        }
    }

    function TokenFloatToInt(base){
        return {
            type: "float_to_int",
            value: base
        }
    }

    function TokenIntFunction(name, args){
        return {
            type: "function_int",
            name,
            args
        }
    }

    function TokenIntVariable(name){
        return {
            type: "variable_int",
            name
        }
    }

    function TokenIntVariableAndIncreament(name, operator, before){
        return {
            type: "variable_int_incre",
            operator,
            before
        }
    }

    function TokenIntShift(left, operator, right){
        return {
            type: "int_shift",
            operator,
            left,
            right
        }
    }

    function TokenIntBinaryOp(left, operator, right){
        return {
            type: "int_binop",
            left,
            right,
            operator
        }
    }
%}

float_to_int
    -> additive_float ":i"
        {%
            ([value,_])=>TokenFloatToInt(value)
        %}

bin_or_int
    -> bin_or_int _ "|" _ bin_xor_int
        {%
            ([left, _ ,_2, _3, right]) => TokenIntBinaryOp(left, "|", right)
        %}
    | bin_xor_int {% id %}

bin_xor_int
    -> bin_xor_int _ "^" _ bin_and_int
        {%
            ([left, _ ,_2, _3, right]) => TokenIntBinaryOp(left, "^", right)
        %}
    | bin_and_int {% id %}

bin_and_int
    -> bin_and_int _ "&" _ shifted_int
        {%
            ([left, _ ,_2, _3, right]) => TokenIntBinaryOp(left, "&", right)
        %}
    | shifted_int {% id %}

shifted_int
    # Its important that the recursion for shifted_int is on the right side to resolve the expression correctly
    -> shifted_int _ shift_character _ additive_int
        {%
            ([left, _, operator, _1, right]) => TokenIntShift(left, operator[0][0], right)
        %}
    | additive_int {% id %} 

additive_int
    -> multiplicative_int _ [+-] _ additive_int
         {%
            ([left, _, operator, _1, right]) => TokenAdditiveInt(left, operator, right)
         %}
    |  multiplicative_int  {%id%}

multiplicative_int
    -> unary_expression_int _ [*/%] _ multiplicative_int
        {%
            ([left, _, operator, _1, right]) => TokenMultiplicativeInt(left, operator, right)
        %}
    |  unary_expression_int  {%id%}

unary_expression_int
    -> simple_int {%id%}
    | [+-]:? _ "(" _ additive_int _ ")"
        {%
            ([optOperator,_4,_,_1,content,_2,_3])=>TokenUnaryInt(optOperator, content)
        %}
    | function_int {%id%}
    | variable_int {%id%}

function_int
    -> var_name _ "(" _ func_parameters_int _ ")"
        {%
            ([name, _,_1,_2,args,_3,_4])=>TokenIntFunction(name, args)
        %}

func_parameters_int
    -> additive_int _ "," _  func_parameters_int
        {%
            ([addedId, _,_1,_2, preArr])=>[addedId, ...preArr]
        %}
    | additive_int

variable_int
    -> ("++" | "--") var_name
        {%
            ([op,name])=>TokenIntVariableAndIncreament(name, op[0][0], true)
        %}
    |  var_name ( "++" | "--" )
        {%
            ([name,op])=>TokenIntVariableAndIncreament(name, op[0][0], false)
        %}
    |  var_name
        {%
            ([name])=>TokenIntVariable(name)
        %}

#
# Float Section
#

# Float Operator precedence:
# 1. Unary
# 2. Multiply / Divide / Modulo
# 3. Addition / Subtraction

@{%
    function TokenFloat(number){
        return {
            type: "float",
            value: number
        }
    }

    function TokenAdditiveFloat(left, operator, right){
        return {
            type: "additive_float",
            left,
            operator,
            right
        }
    }

    function TokenMultiplicativeFloat(left, operator, right){
        return {
            type: "multiplicative_float",
            left,
            operator,
            right
        }
    }

    function TokenUnaryFloat(optOperator, content){
        return {
            type: "unary_float",
            content,
            operator: optOperator === null ? "+" : optOperator
        }
    }

    function TokenIntToFloat(base){
        return {
            type: "int_to_float",
            value: base
        }
    }

    function TokenFloatFunction(name, args){
        return {
            type: "function_float",
            name,
            args
        }
    }

    function TokenFloatVariable(name){
        return {
            type: "variable_float",
            name
        }
    }

    function TokenFloatVariableAndIncreament(name, operator, before){
        return {
            type: "variable_float_incre",
            operator,
            before
        }
    }
%}

int_to_float
    -> additive_int ":f"
        {%
            ([value,_])=>TokenIntToFloat(value)
        %}

additive_float
    -> multiplicative_float _ [+-] _ additive_float
         {%
            ([left, _, operator, _1, right]) => TokenAdditiveFloat(left, operator, right)
         %}
    |  multiplicative_float  {%id%}

multiplicative_float
    -> unary_expression_float _ [*/] _ multiplicative_float
        {%
            ([left, _, operator, _1, right]) => TokenMultiplicativeFloat(left, operator, right)
        %}
    |  unary_expression_float  {%id%}

unary_expression_float
    -> simple_float {%id%}
    | [+-]:? _ "(" _ additive_float _ ")"
        {%
            ([optOperator,_4,_,_1,content,_2,_3])=>TokenUnaryFloat(optOperator, content)
        %}
    | function_float {%id%}
    | variable_float {%id%}

function_float
    -> var_name _ "(" _ func_parameters_float _ ")"
        {%
            ([name, _,_1,_2,args,_3,_4])=>TokenFloatFunction(name, args)
        %}

func_parameters_float
    -> additive_float _ "," _  func_parameters_float
        {%
            ([addedId, _,_1,_2, preArr])=>[addedId, ...preArr]
        %}
    | additive_float

variable_float
    -> ("++" | "--") var_name
        {%
            ([op,name])=>TokenFloatVariableAndIncreament(name, op[0][0], true)
        %}
    |  var_name ( "++" | "--" )
        {%
            ([name,op])=>TokenFloatVariableAndIncreament(name, op[0][0], false)
        %}
    |  var_name
        {%
            ([name])=>TokenFloatVariable(name)
        %}

simple_float
    -> simple_number "." digits "f":?
        {%
            ([preComma, _, afterComma])=>TokenFloat(Number(preComma.toString()+"."+afterComma))
        %}
    |  simple_number "f" {% data=>TokenFloat(data[0]) %}
    |  int_to_float {% id %}

simple_int
    -> simple_number "i":? {% data=>TokenInt(data[0]) %}
    |  float_to_int {% id %}



shift_character -> ("<<" | ">>") {%id%}

simple_number
    -> ("+" | "-"):? digits
        {%
            ([optChar, number])=>{
                return Number((optChar === null ? "+" : optChar[0])+number)
            }
        %}

digits
    -> [0-9]:+ {% data=>data[0].join("") %}

var_name -> [a-zA-Z] [a-zA-Z0-9_]:* {% ([first, other])=>first+other.join("") %}