require("lualibs.lua")

function printHeading(file)
  local json = getJsonFromFile(file)
  for key, value in pairs(json) do
    tex.print("\\begin{center}")

    -- Name
    tex.print("\\textbf{\\Large " .. value["name"] .. "}\\\\")

    -- Address (assuming 'address' key in your JSON, replace as needed)
    if value["address"] then
        tex.print(value["address"] .. "\\\\")
    end

    -- LinkedIn, GitHub, and Email
    tex.print("\\href{https://linkedin.com/in/" .. value["linkedin"] .. "}{linkedin.com/in/" .. value["linkedin"] .. "}")
    tex.print(" | \\href{https://github.com/" .. value["github"] .. "}{github.com/" .. value["github"] .. "}")
    tex.print(" | \\href{mailto:" .. value["email"] .. "}{" .. value["email"] .. "}")
    tex.print(" | {" .. value["phone"] .. "}")

    tex.print("\\end{center}")
  end
end

function printEduItems(file)
  local json = getJsonFromFile(file)
  for key, value in pairs(json) do
    tex.print("\\resumeEduEntry")
    tex.print("{" .. value["school"] .. "}")
    tex.print("{" .. value["school_location"] .. "}")
    tex.print("{" .. value["degree"] .. "}")
    tex.print("{" .. value["time_period"] .. "}")
  end
end

function printExpItems(file)
  local json = getJsonFromFile(file)
  for key, value in pairs(json) do
    tex.print("\\resumeExpEntry")
    tex.print("{" .. markdownToLatex(value["company"]) .. "}")
    tex.print("{" .. value["company_location"] .. "}")
    tex.print("{" .. value["role"] .. "}")
    
    local skills = string.gsub(value["skills"], "・", " $\\cdot$ ")
    tex.print("{" .. skills .. "}")

    tex.print("{" .. value["time_duration"] .. "}")

    tex.print("\\resumeItemListStart")
    for innerKey, innerValue in pairs(value["details"]) do
      tex.print("\\resumeItem")
      tex.print("{" .. markdownToLatex(innerValue) .. "}")
    end
    tex.print("\\resumeItemListEnd")
  end
end

function printProjItems(file)
  local json = getJsonFromFile(file)
  for key, value in pairs(json) do

    tex.print("\\resumeProjEntry")
    tex.print("{" .. value["title"] .. "}")

    local skills = ""
    if value["skills"] and #value["skills"] > 0 then
      skills = skills .. " [ " .. table.concat(value["skills"], ", ") .. " ]"
    end
    if value["links"] and #value["links"] > 0 then
      local formattedLinks = {}
      for _, link in ipairs(value["links"]) do
        table.insert(formattedLinks, markdownToLatex(link))
      end
      skills = skills .. " [ " .. table.concat(formattedLinks, ", ") .. " ]"
    end
    tex.print("{" .. skills .. "}")

    tex.print("\\resumeItemListStart")
    for innerKey, innerValue in pairs(value["details"]) do
      tex.print("\\resumeItem")
      tex.print("{" .. innerValue .. "}")
    end
    tex.print("\\resumeItemListEnd")
  end
end

function printOrgItems(file)
  local json = getJsonFromFile(file)
  tex.print("\\item")
  tex.print("\\resumeItemListStart")
  for key, value in pairs(json) do
    tex.print("\\resumeOrgItem")
    tex.print("{" .. value["title"] .. "}")
    tex.print("{" .. value["description"] .. "}")
  end
  tex.print("\\resumeItemListEnd")
end

function printList(file, primary)
  local json = getJsonFromFile(file)
  local skills = {}
  for _, value in pairs(json) do
    for _, language_or_technology in ipairs(value[primary]) do
      table.insert(skills, language_or_technology)
    end
  end
  tex.print(table.concat(skills, ", "))
end

function getJsonFromFile(file)
  local fileHandle = io.open(file)
  local jsonString = fileHandle:read('*a')
  fileHandle:close()
  local jsonData = utilities.json.tolua(jsonString)
  return jsonData
end

function markdownToLatex(input)
  -- Handle bold text
  local start, finish = string.find(input, "%*%*(.-)%*%*")
  while start do
      local boldText = string.sub(input, start + 2, finish - 2)
      input = string.sub(input, 1, start - 1) .. "\\textbf{" .. boldText .. "}" .. string.sub(input, finish + 1, -1)
      start, finish = string.find(input, "%*%*(.-)%*%*")
  end

  -- Handle hyperlinks
  start, finish, text, url = string.find(input, "%[(.-)%]%((.-)%)")
  while start do
      input = string.sub(input, 1, start - 1) .. "\\href{" .. url .. "}{" .. text .. "}" .. string.sub(input, finish + 1, -1)
      start, finish, text, url = string.find(input, "%[(.-)%]%((.-)%)")
  end

  return input
end


