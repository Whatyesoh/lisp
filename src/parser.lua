require("src/literals")
Parser = {}
Parser.newAst = require("src/AST")
local color = require("src/color")

local operationTable = {
    ["*"] = function(val1,val2)
        return val1 * val2
    end,
    ["+"] = function(val1,val2)
        return val1 + val2
    end,
    ["-"] = function(val1,val2)
        return val1 - val2
    end,
    ["/"] = function(val1,val2)
        return val1 / val2
    end,
    ["%"] = function(val1,val2)
        return val1 % val2
    end
}

local errorTable = {
    [1] = "Too many operations given",
    [2] = "Unknown token"
}

function ParseProgram(line)
    local tokens = SplitLine(line)
    if tokens[1] ~= "(" then
        return 0
    end
    return Parser.newAst(tokens,2,false)[1]
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
            newString = newString .. "  " .. PrettyPrinter(tree.values[i],str) .. ""
        end
        newString = newString .. " \27[32m)\27[0m"
    end

    return str .. newString
end