local ast = {}
ast.__index = ast

local function newAst(tokens, index, isKnown)
    local errorNum = nil
    local self = setmetatable({},ast)
    self.value = nil
    self.types = {}
    self.values = {nil,nil}
    self.operation = nil
    self.float = nil
    self.str = nil
    self.color = 0x74

    if tokens[index] == "(" then
        return 7
    end

    if isKnown then
        self.value = tokens[index]
        self.values = {nil,nil}
        self.operation = nil
        self.types = IdentifyLiteral(self.value)
        for i,v in ipairs(self.types) do
            if v == 7 or v == 8 then
                self.value = string.sub(self.value,2,#self.value-1)
            end
        end
    else
        self.value = nil
        local valueCount = 1
        local loopCount = 0
        local expressionData
    
        for i = index,#tokens do
            local token = tokens[i]
            if token == "(" then
                loopCount = loopCount + 1
                if loopCount == 1 then
                    expressionData = newAst(tokens,i + 1,false)
                    self.values[valueCount] = expressionData
                    valueCount = valueCount + 1
                end
            elseif token == ")" then
                if loopCount > 0 then
                    loopCount = loopCount - 1
                else
                    break
                end
            else
                if loopCount == 0 then
                    if self.operation then
                        expressionData = newAst(tokens,i,true)
                        self.values[valueCount] = expressionData
                        valueCount = valueCount + 1
                    else
                        if self.operation then
                            return 1
                        end
                        self.operation = token
                    end
                end
            end
        end
    end

    return self
end

return newAst