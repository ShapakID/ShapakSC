-- ============================================================
--  MyIP - cek IP publik sendiri + UID + nama akun (ImGui)
--  Paste ke Bothax → menu 'MyIP (Shapak)' muncul di ImGui
--  Klik tombol untuk cek. Ganti script lain aman (hook terpisah).
--  (c) ShapakID
-- ============================================================

-- Guard anti double-load
if _G.MYIP_LOADED then
    LogToConsole("`4[MyIP] Sudah ter-load. Jangan paste 2x.")
    return
end
_G.MYIP_LOADED = true

local checking = false
local hasil = {"Belum dicek. Klik 'Cek IP Saya'."}

local function cek()
    local me = GetLocal()
    local uid  = (me and me.userid) or "?"
    local nama = (me and me.name) or "?"
    local cl   = GetClient()
    local server = (cl and cl.address) or "?"
    hasil = {
        "UID  : " .. uid,
        "Nama : " .. nama,
        "Server: " .. server,
        "---",
    }
    -- IP publik
    local ok1, r1 = pcall(function() return MakeRequest("https://api.ipify.org", "GET") end)
    if ok1 and r1 and r1.content and r1.content ~= "" then
        hasil[#hasil+1] = "IP publik: " .. r1.content
    else
        hasil[#hasil+1] = "`4IP publik: gagal"
    end
    -- Lokasi + ISP
    local ok2, r2 = pcall(function() return MakeRequest("https://ipapi.co/json/", "GET") end)
    if ok2 and r2 and r2.content and r2.content ~= "" then
        local c = r2.content
        local city = c:match('"city"%s*:%s*"([^"]*)"') or "?"
        local co   = c:match('"country_name"%s*:%s*"([^"]*)"') or "?"
        local org  = c:match('"org"%s*:%s*"([^"]*)"') or "?"
        hasil[#hasil+1] = "Lokasi: " .. city .. ", " .. co
        hasil[#hasil+1] = "ISP   : " .. org
    else
        hasil[#hasil+1] = "`4Lokasi: gagal"
    end
end

AddHook('OnDraw', 'MyIPUI', function() pcall(function()
    if ImGui.Begin('MyIP (Shapak)') then
        if checking then
            ImGui.Text("Working...")
        else
            if ImGui.Button("Cek IP Saya") then
                checking = true
                RunThread(function()
                    cek()
                    checking = false
                end)
            end
        end
        ImGui.Separator()
        for _, line in ipairs(hasil) do
            ImGui.Text(line)
        end
        ImGui.Text(checking and "..." or "Ready")
    end
    ImGui.End()
end) end)

LogToConsole("`2[MyIP] Loaded. Buka menu 'MyIP (Shapak)' di ImGui.")
