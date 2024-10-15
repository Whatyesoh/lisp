LiteralTypes = {}
LiteralTypes.integer = {"-?%d+",1}
LiteralTypes.symbol = {"%S+",2}
LiteralTypes.expr = {"%b()",4}
LiteralTypes.program = {".*",5}
LiteralTypes.float = {"-?%d*%.%d+",6}
LiteralTypes.str = {"%b\"\"",7}
LiteralTypes.char = {"\'.?\'",8}
LiteralTypes.literal = {"["..LiteralTypes.integer[1]..LiteralTypes.symbol[1].."]+",3}


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
    local strings = {}
    local tokens = {}

    local startIndex
    local endIndex

    startIndex, endIndex = string.find(line,LiteralTypes.literal[1])

    table.insert(tokens,{startIndex,endIndex})

    while (1) do
        startIndex, endIndex = string.find(line,LiteralTypes.literal[1],tokens[#tokens][2]+1)
        if not startIndex then
            break
        end
        table.insert(tokens,{startIndex,endIndex})
    end

    startIndex, endIndex = string.find(line,LiteralTypes.str[1])

    if startIndex then

        table.insert(strings,{startIndex,endIndex})

        while (1) do
            startIndex, endIndex = string.find(line,LiteralTypes.str[1],strings[#strings][2]+1)
            if not startIndex then
                break
            end
            table.insert(strings,{startIndex,endIndex})
        end
    end

    local finalTokens = {}

    local strIndex = 1
    for i,v in ipairs(tokens) do
        while (strings[strIndex] and strings[strIndex][1] <= v[1]) do
            table.insert(finalTokens,strings[strIndex])
            strIndex = strIndex + 1
        end
        local check = true
        for j,k in ipairs(strings) do
            if v[1] >= k[1] and v[2] <= k[2] then
                check = false
            end            
        end
        if check then
            table.insert(finalTokens,v)
        end
    end

    tokens = {}

    for i,v in ipairs(finalTokens) do
        table.insert(tokens,string.sub(line,v[1],v[2]))
    end
    return tokens
end