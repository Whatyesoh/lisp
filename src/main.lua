require("src/AST")
require("src/literals")
require("src/parser")
require("src/eval")
local color = require("src/color")

PrintTime = false
local helpMessage = ".quit/.exit - end the program\n.help - list of commands and their functionsn\n.timing - print runtime for each line (toggle)"

function ProcessLine(line)
    local startTime = os.clock()

    if string.sub(line,1,1) == "." then
        local commandResult = ProcessCommand(line)
        if commandResult ~= 1 then 
            return commandResult 
        end 
    elseif string.sub(line,1,1) == "(" and string.sub(line,string.len(line),string.len(line)) == ")" then
        local value = Eval(ParseProgram(line))
        if value == "" then
            return 0
        end
        if not PrintTime then return 1 end
    else
        io.write(line)
    end
    if PrintTime then io.write(" ", color.fg(0x3c)..string.format("%.2f",os.clock()-startTime),"s",color.reset) end
        
    io.write("\n")
    return 1
end

function ProcessCommand(command)
    if CheckString(command:sub(2,#command),LiteralTypes.expr[1]) then
        local parsedCommand = (PrettyPrinter(ParseProgram(command:sub(2,#command)),""))
        if parsedCommand ~= "" then
            io.write(parsedCommand)
        else
            return 0
        end
    end

    if command == ".quit" or command == ".exit" then
        return 0
    end 

    if command == ".timing" then
        PrintTime = not PrintTime
        if PrintTime then
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
        local lineCount = 1
        for line in file:lines() do
            io.write(lineCount .. "| ")
            if ProcessLine(line) ~= 1 then
                break
            end
            lineCount = lineCount + 1
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