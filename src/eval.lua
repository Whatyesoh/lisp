local operationTable = {
    ["*"] = {function(vals)
        local val = vals[1]
        for i=1,#vals-1 do val = val * vals[i] end
        return val
    end,2,0,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    ["+"] = {function(vals)
        local val = vals[1]
        for i=1,#vals-1 do val = val + vals[i] end
        return val
    end,2,0,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    ["-"] = {function(vals)
        return vals[1] - vals[2]
    end,2,2,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    ["/"] = {function(vals)
        return vals[1] / vals[2]
    end,2,2,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    ["%"] = {function(vals)
        return vals[1] % vals[2]
    end,2,2,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    ["="] = {function(vals)
        if vals[1] == vals[2] then
            return 1
        end
        return 0
    end,2,2,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    [">"] = {function(vals)
        if vals[1] > vals[2] then
            return 1
        end
        return 0
    end,2,2,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    ["<"] = {function(vals)
        if vals[1] < vals[2] then
            return 1
        end
        return 0
    end,2,2,0,{LiteralTypes.integer[1],LiteralTypes.float[1]}},
    ["concat"] = {function(vals)
        return string.sub(vals[1],2,string.len(vals[1])-1) .. string.sub(vals[2],2,string.len(vals[2])-1)
    end,2,2,1,{LiteralTypes.str[1],LiteralTypes.str[1]}},
    ["substring"] = {function(vals)
        return string.sub(string.sub(vals[1],2,string.len(vals[1])-1),vals[2],vals[3])
    end,3,3,1,{LiteralTypes.str[1],LiteralTypes.integer[1],LiteralTypes.integer[1]}}
}

local function checkOperationTypes(operation,vals)
    local check = false
    if operationTable[operation][4] == 0 then
        for j,k in ipairs(vals) do
            check = false
            for i,v in ipairs(operationTable[operation][5]) do
                if CheckString(k,v) then
                    check = true
                end
            end
            if check == false then
                return false
            end
        end
    else
        check = true
        for i,v in ipairs(operationTable[operation][5]) do
            if not CheckString(vals[i],v) then
                check = false
            end
        end
        return check
    end
    return true
end


function Eval(tree)
    if type(tree) ~= "table" then
        ProcessErrors(tree)
        return ""
    end

    if tree.value then
        return tree.value
    else
        local operation = tree.operation
        if (#tree.values > operationTable[operation][3]) and (operationTable[operation][3] ~= 0) then
            ProcessErrors(3)
            return ""
        elseif #tree.values < operationTable[operation][2] and (operationTable[operation][2] ~= 0) then
            ProcessErrors(4)
            return ""
        end
        local vals = {}
        for i = 1,#tree.values do
            local testError = Eval(tree.values[i])
            if testError == "" then
                return ""
            end
            table.insert(vals,testError)
        end
        if not checkOperationTypes(operation,vals) then
            ProcessErrors(5)
            return ""
        end
        return operationTable[operation][1](vals)
    end
end