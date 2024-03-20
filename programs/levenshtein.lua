function levenshtein(str1, str2)
    local d = {}
    for i = 0, #str2 do
        if i == 0 then
            local d1 = {}
            for j = 0, #str1 do
                table.insert(d1, j)
            end
            table.insert(d, d1)
        else
            table.insert(d, {i})
        end
    end

    for i = 1, #str2 do
        for j = 1, #str1 do
            a = 0
            if str1:sub(i,i) ~= str2:sub(j,j) then
                a = 1
            end
            d[i+1][j+1] = min(d[i][j]+a, d[i][j+1]+1, d[i+1][j]+1)
        end
    end

    return d
end

function min(...)
    list = {...}
    local min = list[1]
    for i = 2, #list do
        if min > list[i] then
            min = list[i]
        end
    end

    return min
end