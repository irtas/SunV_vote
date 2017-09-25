								--[[
								##################
								#    Irtas       #
								#    Momaki      #
								#SunV_vote.client#
								#     2017       #
								##################
											--]]



--Il faut réinitialiser la bd une fois les éléctions finis pour éviter de garder les valeurs !!



DrawDistance = 1

local Pos = {x = -266.786, y = -2035.08, z = 30.1456}
local Circle = {x = 7, y = 7, z = 2.0}
local Color = {r = 20, g = 150, b = 200}
local Type = 1
ConfirmMes = false


CANDIDATS = {}


-- Le menu de la Mairie
RegisterNetEvent("elec:getCandidats")
AddEventHandler("elec:getCandidats", function(ALLCANDIDATS)
    CANDIDATS = {}
    CANDIDATS = ALLCANDIDATS
end)



function MenuMairie()
	TriggerServerEvent("elec:recherchedecandidats")-- appel de la liste
    ped = GetPlayerPed(-1)
    MenuTitle = "Mairie"
    ClearMenu()
    Menu.addButton("Voter","CandidatListe",nil)
    Menu.addButton("Se présenter","ConfirmParticipate",nil)
end

--On va delander la liste des candidats pour les afficher sur plusieurs bouttons

function CandidatListe()
	TriggerServerEvent("elec:recherchedecandidats")-- appel de la liste
	ped = GetPlayerPed(-1)
	MenuTitle = "Voter"
	ClearMenu()
	for ind, value in pairs(CANDIDATS) do
		Menu.addButton(tostring(value.candidatsNom) .. " " .. tostring(value.candidatsPrenom) .. " : " .. tonumber(value.votes), "ConfirmVote", ind) 
	end
		Menu.addButton("Retour","MenuMairie",nil)
end

--Pour confirmer sa participation aux éléctions

function ConfirmParticipate()
		TriggerServerEvent("elec:recherchedecandidats")-- appel de la liste
		ped = GetPlayerPed(-1)
		MenuTitle = "Valider"
		ClearMenu()
		Menu.addButton("Oui","participateyes",nil)
		Menu.addButton("Non","MenuMairie",nil)
end

-- Pour confirmer son vote

function ConfirmVote(id)
TriggerServerEvent("elec:recherchedecandidats")-- appel de la liste
local id = id
	MenuTitle = "Confimer"
	ClearMenu()
	Menu.addButton("Oui","voteyes",id)
	Menu.addButton("Non","MenuMairie",nil)
end

function participateyes()	
    TriggerServerEvent("elec:sepresenter")
	MenuMairie()
end

function voteyes(id)
local id = id
	TriggerServerEvent("elec:voteyes",id)
	MenuMairie()
	TriggerServerEvent("elec:recherchedecandidats")-- appel de la liste
end
-----------------------------------------------------

function drawTxt(text, font, centre, x, y, scale, r, g, b, a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

Citizen.CreateThread(function()
	while true do

		Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1), true)

		if (Vdist(coords.x, coords.y, coords.z, Pos.x, Pos.y, Pos.z, true) < DrawDistance) then
		 DrawMarker(Type, Pos.x, Pos.y, Pos.z, 0, 0.0, 0.0, 0, 0.0, 0.0, Circle.x, Circle.y, Circle.z, Color.r, Color.g, Color.b, 100, false, true, 2, false, false, false, false)
			if(Vdist(coords.x, coords.y, coords.z, Pos.x, Pos.y, Pos.z, true) < Circle.x) then
				drawTxt('Utiliser ~g~E~s~ pour ~b~voter~s~ ou ~b~participer', 2, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
				if IsControlJustPressed(1, 38) then
         			MenuMairie()
          			Menu.hidden = not Menu.hidden
          			if IsControlJustPressed(1, 177) then
          				Menu.hidden = true
          			end
				end
				Menu.renderGUI()
			end
		end
	end
end)



Menu = {}
Menu.GUI = {}
Menu.buttonCount = 0
Menu.selection = 0
Menu.hidden = true
MenuTitle = "Menu"

----------------------------------------------------------------

function Menu.addButton(name, func,args)
	local yoffset = 0.3
	local xoffset = 0
	local xmin = 0.0
	local xmax = 0.3
	local ymin = 0.05
	local ymax = 0.05
	Menu.GUI[Menu.buttonCount+1] = {}
	Menu.GUI[Menu.buttonCount+1]["name"] = name
	Menu.GUI[Menu.buttonCount+1]["func"] = func
	Menu.GUI[Menu.buttonCount+1]["args"] = args
	Menu.GUI[Menu.buttonCount+1]["active"] = false
	Menu.GUI[Menu.buttonCount+1]["xmin"] = xmin + xoffset
	Menu.GUI[Menu.buttonCount+1]["ymin"] = ymin * (Menu.buttonCount + 0.01) +yoffset
	Menu.GUI[Menu.buttonCount+1]["xmax"] = xmax 
	Menu.GUI[Menu.buttonCount+1]["ymax"] = ymax 
	Menu.buttonCount = Menu.buttonCount+1
end


function Menu.updateSelection() 
	if IsControlJustPressed(3, 173) then 
		if(Menu.selection < Menu.buttonCount -1 ) then
			Menu.selection = Menu.selection +1
		else
			Menu.selection = 0
		end		
	elseif IsControlJustPressed(3, 172) then
		if(Menu.selection > 0)then
			Menu.selection = Menu.selection -1
		else
			Menu.selection = Menu.buttonCount-1
		end	
	elseif IsControlJustPressed(3, 176)  then
		MenuCallFunction(Menu.GUI[Menu.selection +1]["func"], Menu.GUI[Menu.selection +1]["args"])
	end
	local iterator = 0
	for id, settings in ipairs(Menu.GUI) do
		Menu.GUI[id]["active"] = false
		if(iterator == Menu.selection ) then
			Menu.GUI[iterator +1]["active"] = true
		end
		iterator = iterator +1
	end
end

function Menu.renderGUI()
	if not Menu.hidden then
		Menu.renderButtons()
		Menu.updateSelection()
	end
end

function Menu.renderBox(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(xMin, yMin,xMax, yMax, color1, color2, color3, color4);
end

function Menu.renderButtons()
local yoffset = 0.3
local xoffset = 0

		SetTextFont(1)
		SetTextProportional(0)
		SetTextScale(1.0, 1.0)
		SetTextColour(255, 255, 255, 255)
		SetTextDropShadow(0, 0, 0, 0,255)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
		SetTextCentre(2)
		SetTextEntry("STRING")
		AddTextComponentString(string.upper(MenuTitle))
		DrawText((xoffset + 0.07), (yoffset - 0.065 - 0.0125 ))
		Menu.renderBox(xoffset,0.3,(yoffset - 0.05),0.05,20,20,255,150)
		
		
	for id, settings in pairs(Menu.GUI) do
		local screen_w = 0
		local screen_h = 0
		screen_w, screen_h =  GetScreenResolution(0, 0)
		
		if(settings["active"]) then
			boxColor = {255,255,255,150}
			SetTextColour(0, 0, 0, 255)
		else			
			boxColor = {0,0,0,150}
			SetTextColour(255, 255, 255, 255)	
		end
		SetTextFont(0)
		SetTextScale(0.0,0.35)
		SetTextCentre(false)
--		SetTextDropShadow(0, 0, 0, 0, 0)
		SetTextEdge(0, 0, 0, 0, 0)
		SetTextEntry("STRING") 
		AddTextComponentString(settings["name"])
		DrawText(settings["xmin"]+ 0.01, (settings["ymin"] - 0.0125 )) 
		Menu.renderBox(settings["xmin"] ,settings["xmax"], settings["ymin"], settings["ymax"],boxColor[1],boxColor[2],boxColor[3],boxColor[4])
	 end
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function MenuCallFunction(fnc, arg)
	_G[fnc](arg)
end



Citizen.CreateThread(function()
		blip = AddBlipForCoord(-230.755, -2040.28, 27.75)
		SetBlipSprite(blip, 419)
		SetBlipAsShortRange(blip, true)
		SetBlipColour(blip, 0)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Mairie")
		EndTextCommandSetBlipName(blip)
    
end)


-------------------------------------------------------------------------