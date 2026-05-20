local steam = {}

function steam.init()
  return true
end

function steam.shutdown()
end

function steam.runCallbacks()
end

steam.friends = {}

function steam.friends.setRichPresence()
  return true
end

steam.userStats = {}

function steam.userStats.requestCurrentStats()
  return true
end

function steam.userStats.resetAllStats()
  return true
end

function steam.userStats.setAchievement()
  return true
end

function steam.userStats.storeStats()
  return true
end

return steam
