file_name = "programs.txt"
function getFileNameFromGithubLink(src)
    for i = #src, 1, -1 do
        if src:sub(i, i) == "/" then
            return src:sub(i+1, #src)
        end
    end
end

file = fs.open(file_name, "r")
contents = file.readAll()
file.close()
programs = textutils.unserialise(contents)

for i, program in pairs(programs) do
    shell.run("rm", getFileNameFromGithubLink(program))
    shell.run("wget", program)
end
