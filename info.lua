PLUGIN.Title = "Server Information"
PLUGIN.Author = "Gliktch"
PLUGIN.Version = "0.5"
PLUGIN.Description = "Displays basic information about the server, including hostname, ip:port and common server settings."

function PLUGIN:Init()
  print("Loading Server Information mod...")
  self:AddChatCommand( "info", self.cmdInfo )
  self:CollectValues()
--  if (infotimer) then infotimer:Destroy() end
--  infotimer = timer.Repeat( 15, self.CollectValues )
  timer.Repeat( 15, self.CollectValues )
end

function PLUGIN:CollectValues()

 -- Main server info
  hostname = Rust.server.hostname
  hostip   = Rust.server.ip
  hostport = Rust.server.port

 -- Most common settings
  sleep    = Rust.sleepers.on
  pvp      = Rust.server.pvp
  craftin  = Rust.crafting.instant

-- Further useful settings
  maxplay  = Rust.server.maxplayers
  airmin   = Rust.airdrop.min_players
  craftts  = Rust.crafting.timescale
  craftws  = Rust.crafting.workbench_speed
  falldmg  = Rust.falldamage.enabled
  daydur   = Rust.env.daylength
  nightdur = Rust.env.nightlength
  decaysec = Rust.decay.deploy_maxhealth_sec
  durmult  = Rust.conditionloss.damagemultiplier
  durmulta = Rust.conditionloss.armorhealthmult

-- Less common settings
  voicedis = Rust.voice.distance
  ctimeout = Rust.server.clienttimeout
  srvgroup = Rust.server.steamgroup
  tickrate = Rust.decay.decaytickrate
  fallminv = Rust.falldamage.min_vel
  fallmaxv = Rust.falldamage.max_vel
  legstime = Rust.falldamage.injury_length
  locktime = Rust.player.backpackLockTime
  autotime = Rust.save.autosavetime

  if ((not hostip) or (hostip == "")) then
      local url = "http://ifconfig.me/ip"
      local request = webrequest.Send(url, function(code, response)
      -- Check for HTTP success
      if (code == 200) then
          hostip = response
          -- if self.Config.verbose then
          print("Server Information: External IP detected as " .. tostring(response))
          -- end
      else
          error("Server Information: Failed to retrieve external IP (Error " .. tostring(code) .. ").")
      end
  end

end

function PLUGIN:toboolean(var)
  return not not var
end

function PLUGIN:round(num, dec)
  local pow = 10^(dec or 0)
  return math.floor(num * pow + 0.5) / pow
end

function PLUGIN:cmdInfo( netuser, args )

  local decaytext = ""
  if decaysec == 43200 then
      decaytext = "at the standard rate."
  elseif decaysec < 43200 then
      decaytext = "FASTER, about " .. round(43200 / decaysec, 2) .. "x the normal rate."
  elseif decaysec > 43200 then
      decaytext = "SLOWER, about 1/" .. round(decaysec / 43200, 2) .. "th the normal rate."
  end

  rust.SendChatToUser( netuser, "Server: " .. hostname .. " (" .. tostring( #rust.GetAllNetUsers() ) .. "/" .. maxplay .. ")")
  rust.SendChatToUser( netuser, "To connect manually, you can use net.connect " .. hostip .. ":" .. hostport .. " in the F1 console.")
  rust.SendChatToUser( netuser, "Sleepers are " .. (toboolean(sleep) and "ON" or "OFF") .. ", PVP is " .. (toboolean(pvp) and "ON" or "OFF") .. ", Fall Damage is " .. (toboolean(falldmg) and "ON" or "OFF") .. ", and Decay is " .. decaytext)
  rust.SendChatToUser( netuser, "Instant crafting is " .. (toboolean(craftin) and "ON" or "OFF, but the Crafting Timescale is " .. craftts .. " and reduced by " .. craftws .. "x when at a Workbench."))

end

function PLUGIN:SendHelpText( netuser )
    rust.SendChatToUser( netuser, "Use /info to list the details and basic settings of this server." )
end
