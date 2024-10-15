LiteralTypes = {}
LiteralTypes.integer = {"-?%d+",1}
LiteralTypes.symbol = {"%S+",2}
LiteralTypes.literal = {"["..LiteralTypes.integer[1]..LiteralTypes.symbol[1].."]+",3}
LiteralTypes.expr = {"%b()",4}
LiteralTypes.program = {".*",5}
LiteralTypes.float = {"-?%d*%.%d+",6}
LiteralTypes.str = {"%b\"\"",7}
LiteralTypes.char = {"\'.?\'",8}


function IdentifyLiteral(str)
    local typeMatches = {}

    for i,v in pairs(LiteralTypes) do
        if CheckString(str,v[1]) then
            local duplicateTest = 0
            for j,k in ipairs(typeMatches) do
                if v[2] == k then
                    duplicateTest = 1
                end
            end
            if duplicateTest == 0 then table.insert(typeMatches,v[2]) end
        end
    end

    return typeMatches
end

function CheckString(str, pattern)
    local patStart, patEnd = string.find(str, pattern)
    if patStart == 1 and patEnd == string.len(str) then
        return true
    end
    return false
end

function SplitLine(line)
    line = string.gsub(line,"%("," ( ")
    line = string.gsub(line,"%)"," ) ")
    local tokens = {}
    for token in string.gmatch(line,LiteralTypes.literal[1]) do
        table.insert(tokens,token)
    end
    return tokens
end