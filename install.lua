file_name = "programs.txt"

shell.run("wget", arg[1])

if fs.exists(file_name) then
    file = fs.open(file_name,"r") 
    contents = file.readAll()
    file.close()
    programs = textutils.unserialise(contents)
else
    programs = {}
end

table.insert(programs, arg[1])
file = fs.open(file_name, "w+")
file.writeLine(textutils.serialise(programs))
file.close()