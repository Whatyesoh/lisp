local operationTable = {
    ["*"] = {function(vals)
        local val = vals[1]
        for i=1,#vals-1 do val = val * vals[i] end
        return val
    end,2,0,0,{1,6}},
    ["+"] = {function(vals)
        local val = vals[1]
        for i=2,#vals do val = val + vals[i] end
        return val
    end,2,0,0,{1,6}},
    ["-"] = {function(vals)
        return vals[1] - vals[2]
    end,2,2,0,{1,6}},
    ["/"] = {function(vals)
        return vals[1] / vals[2]
    end,2,2,0,{1,6}},
    ["%"] = {function(vals)
        return vals[1] % vals[2]
    end,2,2,0,{1,6}},
    ["="] = {function(vals)
        if vals[1] == vals[2] then
            return 1
        end
        return 0
    end,2,2,0,{5}},
    [">"] = {function(vals)
        if vals[1] > vals[2] then
            return 1
        end
        return 0
    end,2,2,0,{1,6}},
    ["<"] = {function(vals)
        if vals[1] < vals[2] then
            return 1
        end
        return 0
    end,2,2,0,{1,6}},
    ["concat"] = {function(vals)
        return string.sub(vals[1],2,string.len(vals[1])-1) .. string.sub(vals[2],2,string.len(vals[2])-1)
    end,2,2,0,{8,7}},
    ["substring"] = {function(vals)
        return string.sub(string.sub(vals[1],2,string.len(vals[1])-1),vals[2],vals[3])
    end,3,3,1,{7,1,1}},
    ["print"] = {function(vals)
        io.write(vals[1])
        return nil
    end,1,1,0,{5}},
    ["input"] = {function(vals)
        PrintNewLine = false
        return io.read()
    end,0,0,0,{}},
    ["tostring"] = {function(vals)
        if CheckString(vals[1],7) then
            return vals[1]
        end
        return "\"" .. vals[1] .. "\""
    end,1,1,0,{5}},
    ["unstring"] = {function(vals)
        return string.sub(vals[1],2,string.len(vals[1])-1)
    end,1,1,0,{7}},
    ["upper"] = {function(vals)
        return string.upper(vals[1])
    end,1,1,0,{5}},
    ["lower"] = {function(vals)
        return string.lower(vals[1])
    end,1,1,0,{5}}
}

local logicOperations = {
    ["and"] = {function(vals)
        local val = tonumber(Eval(vals[1])[1])
        if val == 1 then
            val = tonumber(Eval(vals[2])[1])
            if val == 1 then
                return 1
            end
        end
        return 0
    end,2},
    ["or"] = {function(vals)
        local val = tonumber(Eval(vals[1])[1])
        if val == 1 then
            return 1
        end
        val = tonumber(Eval(vals[2])[1])
        if val == 1 then
            return 1
        end
        return 0
    end,2},
    ["not"] = {function(vals)
        local val = tonumber(Eval(vals[1])[1])
        if val == 1 then
            return 0
        end
        return 1
    end,1},
    ["if"] = {function(vals)
        local val = tonumber(Eval(vals[1])[1])
        local evaluate
        if val == 1 then
            evaluate = Eval(vals[2])
            if evaluate == "" then
                return ""
            end
            return evaluate[1]
        end
        evaluate = Eval(vals[3])
        if evaluate == "" then
            return ""
        end
        return evaluate[1]
    end,3}
}

local function checkOperationTypes(operation,vals,types)
    local check = false
    if operationTable[operation][4] == 0 then
        for j,k in ipairs(vals) do
            check = false
            for i,v in ipairs(operationTable[operation][5]) do
                for l,m in ipairs(types[j]) do
                    if m == v then
                        check = true
                    end
                end
            end
            if check == false then
                return false
            end
        end
    else
        check = true
        local check2 = false
        for i,v in ipairs(operationTable[operation][5]) do
            check2 = false
            for j,k in ipairs(types[i]) do
                if k == v then
                    check2 = true
                end
            end
            if not check2 then
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
        return {tree.value,tree.types}
    else
        local operation = tree.operation

        if logicOperations[operation] then
            if #tree.values == logicOperations[operation][2] then
                local result = logicOperations[operation][1](tree.values)
                if result == "" then
                    return ""
                end
                return {result,IdentifyLiteral(result)}
            elseif #tree.values < logicOperations[operation][2] then
                ProcessErrors(4)
                return ""
            else
                ProcessErrors(3)
                return ""
            end
        elseif operationTable[operation] then
            if (#tree.values > operationTable[operation][3]) and (operationTable[operation][3] ~= 0) then
                ProcessErrors(3)
                return ""
            elseif #tree.values < operationTable[operation][2] and (operationTable[operation][2] ~= 0) then
                ProcessErrors(4)
                return ""
            end
            local vals = {}
            local types = {}
            for i = 1,#tree.values do
                local testError = Eval(tree.values[i])
                if testError then
                    if type(testError) ~= "table" then
                        return ""
                    end
                end
                if not testError then
                    ProcessErrors(6)
                    return ""
                elseif testError == "" then
                    return ""
                end
                table.insert(vals,testError[1])
                table.insert(types,testError[2])
            end
            if not checkOperationTypes(operation,vals,types) then
                ProcessErrors(5)
                return ""
            end
            local result = operationTable[operation][1](vals)
            return {result,IdentifyLiteral(result)}
        else
            if #tree.values == 1 then
                if not Variables[operation] or Variables[operation][2] == 1 then
                    Variables[operation] = {}
                    table.insert(Variables[operation],Eval(tree.values[1])[1])
                    table.insert(Variables[operation],1)
                else
                    ProcessErrors(9)
                    return ""
                end
            else
                ProcessErrors(8)
                return ""
                --return {operation,{IdentifyLiteral(operation)}}
            end
        end
    end
end