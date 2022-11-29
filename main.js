const nearley = require("nearley");
const compile = require("nearley/lib/compile");
const generate = require("nearley/lib/generate");
const nearleyGrammar = require("nearley/lib/nearley-language-bootstrapped");
const fs = require("fs");

const read=file=>fs.readFileSync(file,{encoding:'utf8', flag:'r'});

function compileGrammar(sourceCode) {
    // Parse the grammar source into an AST
    const grammarParser = new nearley.Parser(nearleyGrammar);
    grammarParser.feed(sourceCode);
    const grammarAst = grammarParser.results[0]; // TODO check for errors

    // Compile the AST into a set of rules
    const grammarInfoObject = compile(grammarAst, {});
    // Generate JavaScript code from the rules
    const grammarJs = generate(grammarInfoObject, "grammar");

    // Pretend this is a CommonJS environment to catch exports from the grammar.
    const module = { exports: {} };
    eval(grammarJs);

    return module.exports;
}

const grammar = compileGrammar(read("./language/main.ne"));

const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));

const languageInput = read("./Input.txt");

function areAllObjectEqual(objArr){
    var base = JSON.stringify(objArr[0]);

    for(var i = 1; i < objArr.length; i++){
        if(JSON.stringify(objArr[i]) !== base)
            return false;
    }

    return true;
}

try{
    
    
    parser.feed(languageInput);

    if(parser.results.length == 0){
        console.log("EOF-Error");
        return;
    }

    if(parser.results.length > 1){
        if(areAllObjectEqual(parser.results)){
            console.log("[INFO] Found multiple parse-results. They are equal though\n");
        }else{
            console.log("#####################################################################\nFound multiple parse results that are different\n#####################################################################\n");
            console.log(JSON.stringify(parser.results));
            return;
        }
    }
    console.log(JSON.stringify(parser.results[0]));
    
}catch(e){
    if(e.message === undefined)
        console.log(e);
    else
        console.log(e.message);
}