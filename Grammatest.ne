
@{%

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
%}

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

var_name -> [a-zA-Z] [a-zA-Z0-9_]:* {% ([first, other])=>first+other.join("") %}