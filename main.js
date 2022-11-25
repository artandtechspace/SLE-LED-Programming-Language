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

    console.log(parser.results.length);
    
    console.log(JSON.stringify(parser.results));

    // Checks for multiple resulted parses
    if(parser.results.length > 1)
        console.log(`\n\nDetected multiple. ${areAllObjectEqual(parser.results) ? "But they are all equal" : "But they are different!!!"}`);
}catch(e){
    console.log(e.message);
}