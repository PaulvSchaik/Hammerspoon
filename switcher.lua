-- hs.chooser Aerospace vensterswitcher in aangepaste stijl

local chooser = nil

local style = {
    font = { name = "MesloLGS NF", size = 14 },
    color = { red = 0.471, green = 0.663, blue = 1, alpha = 1 }
}

-- Gebruik Aerospace om vensters op te halen
function getAerospaceWindows()
    local items = {}

    local task = hs.task.new("/opt/homebrew/bin/aerospace", function(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            hs.alert("Aerospace faalde")
            print("[Aerospace fout] exit code:", exitCode)
            print(stdErr)
            return
        end

        if not stdOut or stdOut:match("^%s*$") then
            hs.alert("Lege uitvoer van Aerospace")
            print("[Aerospace] Geen output ontvangen")
            return
        end

        local success, result = pcall(function()
            local cleaned = stdOut:match("%[.*%]") or stdOut
            return hs.json.decode(cleaned)
        end)

        if not success or type(result) ~= "table" then
            hs.alert("Aerospace JSON fout")
            print("--- Aerospace output ---")
            print(stdOut)
            print("--- Einde output ---")
            return
        end

        for _, win in ipairs(result) do
            if win["app-name"] and win["window-title"] and win["window-id"] then
                table.insert(items, {
                    text = hs.styledtext.new(win["app-name"] .. " → " .. win["window-title"], style),
                    id = win["window-id"]
                })
            end
        end

        if chooser then chooser:delete() end

        if #items == 0 then
            hs.alert("Geen vensters via Aerospace")
            return
        end

        chooser = hs.chooser.new(function(choice)
            if not choice then return end
            if choice.id then
                local focusTask = hs.task.new("/opt/homebrew/bin/aerospace", function(exitCode, stdOut, stdErr)
                    print("[Aerospace focus] exit code:", exitCode)
                    print("stdout:", stdOut)
                    print("stderr:", stdErr)
                end, {"focus", "--window-id", tostring(choice.id)})
                focusTask:start()
            end
        end)

        chooser:choices(items)
        chooser:placeholderText("Wissel venster (Aerospace)…")
        chooser:searchSubText(false)
        chooser:show()
    end, {"list-windows", "--all", "--json"})

    task:start()
end

function showAppSwitcher()
    getAerospaceWindows()
end

-- Alt + Tab
hs.hotkey.bind({"alt"}, "tab", function()
    hs.timer.doAfter(0.1, function()
        showAppSwitcher()
    end)
end)

-- URL-handler
hs.urlevent.bind("showAppSwitcher", function()
    hs.timer.doAfter(0.1, function()
        showAppSwitcher()
    end)
end)

