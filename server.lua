									--[[
								##################
								#    Irtas       #
								#    Momaki      #
								#SunV_vote.server#
								#     2017       #
								##################
											--]]



RegisterServerEvent('elec:recherchedecandidats')
RegisterServerEvent('elec:voteyes')
RegisterServerEvent('elec:participateyes')

----liste des candidats----
AddEventHandler("elec:recherchedecandidats", function()
local mysource = source
TriggerEvent('es:getPlayerFromId', source, function(user)
	candidats = {}
	local player = user.getIdentifier()
	
    MySQL.Async.fetchAll("SELECT * FROM elections WHERE candidat = @candidat", {['@candidat'] = 1}, function(result)
      for _, v in ipairs(result) do
		  candidats[tonumber(v.id)] = {["candidatsNom"] = v.candidatsNom, ["candidatsPrenom"] = v.candidatsPrenom, ["votes"] = v.votes}
		  print (v.id, v.candidatsNom, v.candidatsPrenom, v.votes)
      end
      TriggerClientEvent("elec:getCandidats", mysource, candidats)
    end)
end)	
end)


----insert bdd du candidat------
RegisterServerEvent('elec:sepresenter')
AddEventHandler('elec:sepresenter', function()
local source = source
        TriggerEvent('es:getPlayerFromId', source, function(user)
          local player = user.getIdentifier()
		   GetplayerPresente(player, function (result)
			if  result then	
	  TriggerClientEvent("itinerance:notif", source, "~r~Vous avez déjà candidat~s~")
			else
           MySQL.Async.execute("INSERT INTO elections (`candidatsNom`, `candidatsPrenom`) VALUES (@candidatsNom, @candidatsPrenom)", {['@candidatsNom'] = user.getNom(), ['@candidatsPrenom'] = user.getPrenom()})
		   MySQL.Async.execute("INSERT INTO listeparticipants (`identifier`, `nom`, `prenom`) VALUES (@identifier, @nom, @prenom)", {['@identifier'] = player, ['@nom'] = user.getNom(), ['@prenom'] = user.getPrenom()})
           TriggerClientEvent("itinerance:notif", source, "~g~Vous particpez maintenant aux éléctions. Bonne chance !~s~")
           end
		  end)
		end)
end)

-----vote-----------
AddEventHandler('elec:voteyes', function(id)
local source = source
local voteavant = Getvoies(id)
local voteajout = "1"
local votetotal = voteavant+voteajout 
print("test")
	TriggerEvent('es:getPlayerFromId', source, function(user)	
	local player = user.getIdentifier()	
		Getplayer(player, function (result)
			print (result)
			if  result then	
	  TriggerClientEvent("itinerance:notif", source, "~r~Vous avez déjà voté~s~")	  
			else
	  MySQL.Sync.execute("UPDATE elections SET `votes` = @votes WHERE id = @id", {['@id'] = id, ['@votes'] = votetotal})
	  MySQL.Async.execute("INSERT INTO listevotants (`identifier`, `nom`, `prenom`) VALUES (@identifier, @nom, @prenom)", { ['@identifier'] = player, ['@nom'] = user.getNom(), ['@prenom'] = user.getPrenom()})
	  TriggerClientEvent("itinerance:notif", source, "~g~Vous avez voté, félicitation~s~")
			end
			
	end)
end)	
	
end)


----recupere le nombre de voies par candidat-------
function Getvoies(id)
  local result = MySQL.Sync.fetchAll("SELECT votes FROM elections WHERE id = @id", {['@id'] = id})
  return tostring(result[1].votes)
end

---recherche le joueur s'il a voté---------
function Getplayer(player, callback)
print (player)
	MySQL.Async.fetchAll("SELECT identifier FROM listevotants WHERE identifier = @identifier", {['@identifier'] = player}, function (result)
	print (result)
		if(result[1] ~= nil) then
			callback(true)
		else
			callback(false)
		end
	end)

end

---recherche le joueur est deja candidat---------

function GetplayerPresente(player, callback)
print (player)
    MySQL.Async.fetchAll("SELECT identifier FROM listeparticipants WHERE identifier = @identifier", {['@identifier'] = player}, function (result)
    print (result)
        if(result[1] ~= nil) then
            callback(true)
        else
            callback(false)
        end
    end)
end