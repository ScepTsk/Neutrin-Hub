game.StarterGui:SetCore(
    "SendNotification",
    {
        Title = "Neutrin Hub",
        Text = "Loading",
        Duration = 1
    })
--// Webhook 
local placeId = game.PlaceId
local jobId = game.JobId

local sea1 = 2753915549
local sea2 = 4442272183
local sea3 = 7449423635

local CheckSea
if placeId == sea1 then
    CheckSea = "Sea 1"
elseif placeId == sea2 then
    CheckSea = "Sea 2"
elseif placeId == sea3 then
    CheckSea = "Sea 3"
else
    CheckSea = "unknown sea"
end

local Players = game:GetService("Players")
local playerCount = #game:GetService("Players"):GetPlayers()

local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
local ExecutorUsing = identifyexecutor()
local HttpService = game:GetService("HttpService")
local Data =
{
    ["embeds"] = {
        {
            ["title"] = "**Script Neutrin Hub Log**",
            ["url"] = "https://www.roblox.com/users/"..game.Players.LocalPlayer.UserId,
            ["description"] = "",  -- Xóa phần hiển thị UserId
            ["color"] = tonumber("65280"),
            ["thumbnail"] = {["url"] = "https://cdn.discordapp.com/attachments/1315892490351411251/1330807326428499968/Screenshot_2024-10-01-10-06-47-767_com.miui.gallery-edit.jpg?ex=678f5267&is=678e00e7&hm=9ec317e6698983fb3e98fc57c74535c93e96d14ade50b7a009d06a4653e65559&"},
            ["fields"] = {
                {
                    ["name"] = "Name:",
                    ["value"] = "```"..game.Players.LocalPlayer.DisplayName.."```", 
                    ["inline"] = true
                },
                {
                    ["name"] = "Acc:",
                    ["value"] = "```"..game.Players.LocalPlayer.Name.."```",  
                    ["inline"] = true
                },
                {
                    ["name"] = "Execute:",
                    ["value"] = "```"..ExecutorUsing.."```",
                    ["inline"] = true
                },
                {
                    ["name"] = "Sea:",
                    ["value"] = "```" .. CheckSea.."```", 
                    ["inline"] = true
                }
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }
    }
}

local Headers = {["Content-Type"] = "application/json"}
local Encoded = HttpService:JSONEncode(Data)

local Request = http_request or request or HttpPost or syn.request
local Final = {Url = "https://discord.com/api/webhooks/1505102111367630918/vVsgqAF97kXZT2fQixPqohhHiLryivs56PZy5tHN8JyIWuq15djyXRq2VKe1OJVYP3AW", Body = Encoded, Method = "POST", Headers = Headers}
Request(Final)
