file_name = "programs.txt"

shell.run("wget", arg[1])

if fs.exists(file_name) then
    file = fs.open(file_name,"r") 
    contents = file.readAll()
    file.close()
    programs = textutils.unserialise(contents)
else
    programs = {
        "https://raw.githubusercontent.com/Gedeon23/cc-query/master/programs/install.lua",
        "https://raw.githubusercontent.com/Gedeon23/cc-query/master/programs/update.lua"
    }
    shell.run("wget", programs[1])
    shell.run("wget", programs[2])
end

table.insert(programs, arg[1])
file = fs.open(file_name, "w")
file.writeLine(textutils.serialise(programs))
file.close()