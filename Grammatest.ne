
var_name -> [a-zA-Z] [a-zA-Z0-9_]:* {% ([first, other])=>first+other.join("") %}