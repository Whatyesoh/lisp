require("src/AST")
require("src/literals")
require("src/parser")
local color = require("src/color")

local printTime = false
local helpMessage = ".quit/.exit - end the program\n.help - list of commands and their functionsn\n.timing - print runtime for each line (toggle)"

function ProcessLine(line)
    local startTime = os.clock()

    if string.sub(line,1,1) == "." then
        local commandResult = ProcessCommand(line)
        if commandResult ~= 1 then 
            return commandResult 
        end 
    elseif CheckString(line,LiteralTypes.expr[1]) then
        local parsedCommand = (PrettyPrinter(ParseProgram(line),""))
        if parsedCommand ~= "" then
            io.write(parsedCommand)
        else
            return 0
        end
    else
        io.write(line)
    end
    if printTime then io.write(" ", string.format("%.2f",os.clock()-startTime),"s") end
        
    io.write("\n")
    return 1
end

function ProcessCommand(command)
    if command == ".quit" or command == ".exit" then
        return 0
    end 

    if command == ".timing" then
        printTime = not printTime
        if printTime then
            io.write("Displaying Timings")
        else
            io.write("Done Displaying Timings")
        end
    end

    if command == ".help" then
        print(helpMessage)
        return 0
    end

    if command == ".test" then
        print(color.chart())
    end

    return 1
end

if arg[1] then
    local file = io.open(arg[1],"r")
    if file then
        for line in file:lines() do
            if ProcessLine(line) ~= 1 then
                break
            end
        end
    end
    io.close(file)
else
    while (1) do
        io.write("lisp> ")
        local input = io.read()
        if ProcessLine(input) ~= 1 then
            break
        end
    end
end