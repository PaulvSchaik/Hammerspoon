-- hs.chooser menu to display all Aerospace configured key-binds
local chooser = nil

local style = {
    font = { name = "MesloLGS NF", size = 14 },
    color = { red = 0.471, green = 0.663, blue = 1, alpha = 1 }
}

function getAerospaceShortcuts()
    local items = {}

    local task = hs.task.new("/opt/homebrew/bin/aerospace", function(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            hs.alert("Fout bij ophalen sneltoetsen")
            print("[Aerospace shortcuts] exit code:", exitCode)
            print(stdErr)
            return
        end

        print("--- Aerospace output ---")
        print(stdOut)
        print("--- Einde output ---")

        local success, result = pcall(function()
            return hs.json.decode(stdOut)
        end)

        if not success or type(result) ~= "table" then
            hs.alert("Kon sneltoetsen niet parseren")
            return
        end

        for binding, command in pairs(result) do
            table.insert(items, {
                text = hs.styledtext.new(binding, style),
                subText = command,
                command = command
            })
        end

        table.sort(items, function(a, b)
            return (a.subText or ""):lower() < (b.subText or ""):lower()
        end)

        if chooser then
            chooser:delete()
        end

        if #items == 0 then
            hs.alert("Geen sneltoetsen gevonden")
            return
        end

        chooser = hs.chooser.new(function(choice)
            if not choice then
                chooser:hide()
                return
            end

            local binding = choice.text:getString()
            local fullCmd = "/opt/homebrew/bin/aerospace trigger-binding " .. binding .. " --mode main"
            local output, status, typ, rc = hs.execute(fullCmd, true)

            print("[Trigger binding] Command:", fullCmd)
            print("[Trigger binding] Output:", output)
            print("[Trigger binding] Status:", status)
            print("[Trigger binding] Type:", typ)
            print("[Trigger binding] Exit code:", rc)

            if not status then
                hs.alert("Fout bij uitvoeren binding")
            end
            chooser:hide()
        end)

        chooser:choices(items)
        chooser:placeholderText("Kies een Aerospace-actie…")
        chooser:searchSubText(true)
        chooser:show()
    end, { "config", "--get", "mode.main.binding", "--json" })

    task:start()
end

-- Cmd + ; opens the menu
hs.hotkey.bind({ "cmd" }, ";", function()
    hs.timer.doAfter(0.1, function()
        getAerospaceShortcuts()
    end)
end)

-- URL-handler
hs.urlevent.bind("showAerospaceShortcuts", function()
    hs.timer.doAfter(0.1, function()
        getAerospaceShortcuts()
    end)
end)

