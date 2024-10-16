require("src/literals")
Parser = {}
Parser.newAst = require("src/AST")
local color = require("src/color")

local errorTable = {
    [1] = "Too many operations given",
    [2] = "Unknown token",
    [3] = "Too many arguments given",
    [4] = "Too few arguments given",
    [5] = "Incorrect argument type",
    [6] = "Attempt to perform operation on nil",
    [7] = "No operation given",
    [8] = "Unknown operation",
    [9] = "Can't assign value to protected variable"
}

function ParseProgram(line)
    local tokens = SplitLine(line)
    if tokens[1] ~= "(" then
        return 0
    end
    for i,v in ipairs(tokens) do
        --print(v)
    end
    return Parser.newAst(tokens,2,false)
end

function ProcessErrors(errorNum)
    io.write(color.fg(0xc4).."Error: "..errorTable[errorNum])
    print(color.reset)
end

function PrettyPrinter(tree,str)
    local newString = ""

    if type(tree) ~= "table" then
        ProcessErrors(tree)
        return ""
    end

    if tree.value then
        newString = color.fg(tree.color) .. tree.value .. color.reset
    else
        newString = "\27[32m( "
        newString = newString .. "\27[33m" .. tree.operation .. "\27[0m"
        for i = 1, #tree.values do
            local testError = PrettyPrinter(tree.values[i],str)
            if testError == "" then
                return ""
            end
            newString = newString .. "  " .. testError .. ""
        end
        newString = newString .. " \27[32m)\27[0m"
    end

    return str .. newString
end