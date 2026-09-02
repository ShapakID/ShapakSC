-- ============================================================
--  SHAPAK SC HUB  v0.2  (c) ShapakID  -- licensed via whitelist
--  Paste ke Bothax -> execute. Jalan di ImGui.
--  Flow: fetch whitelist -> cek UID -> valid? menu : stop+log
--  Update UID pembeli = edit whitelist.txt di repo (no re-encrypt)
-- ============================================================

-- >>> KONFIGURASI (ubah sesuai kebutuhan) <<<
local REPO_BASE   = "https://raw.githubusercontent.com/ShapakID/ShapakHub/main/"
local WHITELIST   = "https://raw.githubusercontent.com/ShapakID/ShapakHub/main/whitelist.txt"
local WEBHOOK_URL = ""   -- isi URL webhook Discord kamu
local SCRIPTS = {
    -- nama tampil di menu  ->  file _enc di repo
    { name = "SC-1  Rotasi PTHT+PNB",  file = "rotasi.lua_enc" },
    { name = "SC-2  PTHT",             file = "ptht.lua_enc" },
    { name = "SC-3  PNB",              file = "pnb.lua_enc" },
    { name = "SC-4  Auto Gems",        file = "auto_gems.lua_enc" },
    { name = "SC-5  MyIP",             file = "myip.lua_enc" },
}
-- ---------------------------------------------

if _G.SHAPAK_HUB_LOADED then
    LogToConsole("`4[ShapakHub] Sudah load. Jangan paste 2x.")
    return
end
_G.SHAPAK_HUB_LOADED = true

local authed   = false
local checking = true
local status   = "Memeriksa lisensi..."

local me = GetLocal()
local MY_UID = (me and me.userid) or 0
local MY_NAME = (me and me.name) or "?"

local function logDiscord(text)
    if WEBHOOK_URL == "" then return end
    pcall(function()
        MakeRequest(WEBHOOK_URL, "POST",
            { ["Content-Type"] = "application/json" },
            '{"content":"' .. text .. '"}')
    end)
end

local function validate()
    -- Ambil whitelist dari GitHub (PUBLIK, tanpa auth)
    local ok, res = pcall(function() return MakeRequest(WHITELIST, "GET") end)
    if not ok or not res or not res.content then
        status = "`4Gagal fetch whitelist"
        checking = false
        return
    end
    -- whitelist.txt: satu UID per baris
    local found = false
    for line in (res.content.."\n"):gmatch("([^\r\n]+)") do
        local v = tonumber(line:match("%d+"))
        if v and v == MY_UID then found = true break end
    end
    if found then
        authed = true
        status = "`2Licensed. UID " .. MY_UID
        logDiscord("**Login SC Hub** | UID: " .. MY_UID .. " | Nick: " .. MY_NAME)
    else
        authed = false
        status = "`4Tidak berlisensi. UID " .. MY_UID .. " tak ada di whitelist."
        logDiscord("**:warning: AKSES DITOLAK** | UID: " .. MY_UID .. " | Nick: " .. MY_NAME)
    end
    checking = false
end

RunThread(validate)

AddHook('OnDraw', 'ShapakHubUI', function() pcall(function()
    if ImGui.Begin('Shapak SC Hub') then
        ImGui.Text("UID  : " .. MY_UID)
        ImGui.Text("Nick : " .. MY_NAME)
        ImGui.Separator()
        if checking then
            ImGui.Text("Memeriksa lisensi...")
        elseif authed then
            ImGui.Text(status)
            ImGui.Separator()
            for _, sc in ipairs(SCRIPTS) do
                if ImGui.Button(sc.name) then
                    local url = REPO_BASE .. sc.file
                    local r = MakeRequest(url, "GET")
                    if r and r.content and r.content ~= "" then
                        pcall(function() LoadEncrypt(r.content) end)
                    else
                        LogToConsole("`4[ShapakHub] Gagal fetch: " .. url)
                    end
                end
            end
        else
            ImGui.TextWrapped(status)
        end
        ImGui.Separator()
        if ImGui.Button("Cek Ulang Lisensi") and not checking then
            checking = true
            RunThread(validate)
        end
    end
    ImGui.End()
end) end)

LogToConsole("`2[ShapakHub] Loaded (UID "..MY_UID..").")
