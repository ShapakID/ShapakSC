-- ============================================================
--  SHAPAK SC HUB  v0.1  (c) ShapakID
--  Paste ini ke Bothax sekali → menu di ImGui
--  Tarik script2 encrypted dari repo GitHub → LoadEncrypt
-- ============================================================

-- >>> KONFIGURASI (ubah sesuai repo kamu) <<<
local REPO_OWNER   = "ShapakID"
local REPO_NAME    = "ShapakSC"
local REPO_BRANCH  = "main"
-- Daftar script: nama tampil -> nama file _enc di repo (tanpa .enc)
-- Nanti bisa diubah jadi fetch dari index.txt di server biar update tanpa ganti hub.
local SC_SCRIPTS = {
    { name = "SC-1   Rotasi PTHT+PNB",   file = "rotasi_enc" },
    { name = "SC-2   Auto Gems",          file = "auto_gems_enc" },
}
-- ---------------------------------------------

local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_OWNER, REPO_NAME, REPO_BRANCH)

-- Anti double-hub (kalau di-paste 2x, jangan nambah hook lagi)
if _G.SHAPAK_HUB_LOADED then
    LogToConsole("`4[ShapakHub] `0Sudah ter-load. Jangan paste 2x.")
    return
end
_G.SHAPAK_HUB_LOADED = true

local busy = false
local status = "Idle"

local function fetchScript(file)
    local url = BASE_URL .. file .. ".enc"
    local ok, res = pcall(function() return MakeRequest(url, "GET") end)
    if not ok or not res or not res.content or res.content == "" then
        return false, "Fetch gagal / kosong: " .. url
    end
    local ok2, err = pcall(function() LoadEncrypt(res.content) end)
    if not ok2 then
        return false, "LoadEncrypt gagal: " .. tostring(err)
    end
    return true, "Loaded: " .. file
end

AddHook('OnDraw', 'ShapakHubUI', function() pcall(function()
    if ImGui.Begin('Shapak SC Hub') then
        ImGui.Text('Script tersedia:')
        ImGui.Separator()
        for i, sc in ipairs(SC_SCRIPTS) do
            if ImGui.Button(sc.name) then
                if not busy then
                    busy = true
                    status = "Loading " .. sc.file .. "..."
                    local m = { i = i }
                    RunThread(function()
                        local ok, msg = fetchScript(SC_SCRIPTS[m.i].file)
                        if ok then status = "`2" .. msg
                        else status = "`4" .. msg end
                        busy = false
                    end)
                end
            end
        end
        ImGui.Separator()
        ImGui.Text(status)
        ImGui.Text(busy and "Working..." or "Ready")
    end
    ImGui.End()
end) end)

LogToConsole("`2[ShapakHub] `0Loaded. Buka menu 'Shapak SC Hub'.")
