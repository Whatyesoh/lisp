local ast = {}
ast.__index = ast

local function newAst(tokens, index, isKnown)
    local errorNum = nil
    local self = setmetatable({},ast)
    self.value = nil
    self.values = {nil,nil}
    self.operation = nil
    self.float = nil
    self.str = nil
    self.color = 0x74

    if isKnown then
        self.value = tokens[index]
        self.values = {nil,nil}
        self.operation = nil
    else
        self.value = nil
        local valueCount = 1
        local loopCount = 0
        local expressionData
    
        for i = index,#tokens do
            local token = tokens[i]
            if token == "(" then
                loopCount = loopCount + 1
                expressionData = newAst(tokens,i + 1,false)
                self.values[valueCount] = expressionData[1]
                valueCount = valueCount + 1
            elseif token == ")" then
                if loopCount > 0 then
                    loopCount = loopCount - 1
                else
                    break
                end
            else
                if loopCount == 0 then
                    if CheckString(token,LiteralTypes.integer[1]) or CheckString(token,LiteralTypes.float[1]) or CheckString(token,LiteralTypes.str[1]) then
                        expressionData = newAst(tokens,i,true)
                        self.values[valueCount] = expressionData[1]
                        valueCount = valueCount + 1
                    elseif CheckString(token,LiteralTypes.symbol[1]) then
                        if self.operation then
                            return {1, 1}
                        end
                        self.operation = token
                    else
                        return {2,2}
                    end
                end
            end
        end
    end

    return {self,errorNum}
end

return newAst