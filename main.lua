require 'engine'
require 'shared'
require 'arena'
require 'buy_screen'
require 'objects'
require 'player'
require 'enemies'


function init()
  shared_init()

  input:bind('move_left', {'a', 'left'})
  input:bind('move_right', {'d', 'right'})
  input:bind('move_up', {'w', 'up'})
  input:bind('move_down', {'s', 'down'})

  local s = {tags = {sfx}}
  shoot1 = Sound('Shooting Projectile (Classic) 11.ogg', s)
  archer1 = Sound('Releasing Bow String 1.ogg', s)
  wizard1 = Sound('Wind Bolt 20.ogg', s)
  swordsman1 = Sound('Heavy sword woosh 1.ogg', s)
  swordsman2 = Sound('Heavy sword woosh 19.ogg', s)
  scout1 = Sound('Throwing Knife (Thrown) 3.ogg', s)
  scout2 = Sound('Throwing Knife (Thrown) 4.ogg', s)
  arrow_hit_wall1 = Sound('Arrow Impact wood 3.ogg', s)
  arrow_hit_wall2 = Sound('Arrow Impact wood 1.ogg', s)
  hit1 = Sound('Player Takes Damage 17.ogg', s)
  hit2 = Sound('Body Head (Headshot) 1.ogg', s)
  hit3 = Sound('Kick 16.ogg', s)
  proj_hit_wall1 = Sound('Player Takes Damage 2.ogg', s)
  enemy_die1 = Sound('Bloody punches 7.ogg', s)
  enemy_die2 = Sound('Bloody punches 10.ogg', s)
  magic_area1 = Sound('Fire bolt 10.ogg', s)
  magic_hit1 = Sound('Shadow Punch 1.ogg', s)
  magic_die1 = Sound('Magical Impact 27.ogg', s)
  knife_hit_wall1 = Sound('Shield Impacts Sword 1.ogg', s)
  blade_hit1 = Sound('Sword impact (Flesh) 2.ogg', s)
  player_hit1 = Sound('Body Fall 2.ogg', s)
  player_hit2 = Sound('Body Fall 18.ogg', s)
  player_hit_wall1 = Sound('Wood Heavy 5.ogg', s)
  pop1 = Sound('Pop sounds 10.ogg', s)
  heal1 = Sound('Buff 3.ogg', s)
  spawn1 = Sound('Buff 13.ogg', s)
  alert1 = Sound('Click.ogg', s)
  elementor1 = Sound('Wind Bolt 18.ogg', s)
  saboteur_hit1 = Sound('Explosion Flesh_01.ogg', s)
  saboteur_hit2 = Sound('Explosion Flesh_02.ogg', s)
  saboteur1 = Sound('Male Jump 1.ogg', s)
  saboteur2 = Sound('Male Jump 2.ogg', s)
  saboteur3 = Sound('Male Jump 3.ogg', s)
  spark1 = Sound('Spark 1.ogg', s)
  spark2 = Sound('Spark 2.ogg', s)
  spark3 = Sound('Spark 3.ogg', s)
  stormweaver1 = Sound('Buff 8.ogg', s)
  cannoneer1 = Sound('Cannon shots 1.ogg', s)
  cannoneer2 = Sound('Cannon shots 7.ogg', s)
  cannon_hit_wall1 = Sound('Cannon impact sounds (Hitting ship) 4.ogg', s)
  pet1 = Sound('Wolf barks 5.ogg', s)
  turret1 = Sound('Sci Fi Machine Gun 7.ogg', s)
  turret2 = Sound('Sniper Shot_09.ogg', s)
  turret_hit_wall1 = Sound('Concrete 6.ogg', s)
  turret_hit_wall2 = Sound('Concrete 7.ogg', s)
  turret_deploy = Sound('321215__hybrid-v__sci-fi-weapons-deploy.ogg', s)
  rogue_crit1 = Sound('Dagger Stab (Flesh) 4.ogg', s)
  rogue_crit2 = Sound('Sword hits another sword 6.ogg', s)

  warrior = Image('warrior')
  ranger = Image('ranger')
  healer = Image('healer')
  mage = Image('mage')
  rogue = Image('rogue')
  nuker = Image('nuker')
  conjurer = Image('conjurer')
  enchanter = Image('enchanter')
  psy = Image('psy')

  class_colors = {
    ['warrior'] = yellow[0],
    ['ranger'] = green[0],
    ['healer'] = green[0],
    ['conjurer'] = yellow[0],
    ['mage'] = blue[0],
    ['nuker'] = blue[0],
    ['rogue'] = red[0],
    ['enchanter'] = red[0],
    ['psy'] = fg[0],
  }

  class_color_strings = {
    ['warrior'] = 'yellow',
    ['ranger'] = 'green',
    ['healer'] = 'green',
    ['conjurer'] = 'yellow',
    ['mage'] = 'blue',
    ['nuker'] = 'blue',
    ['rogue'] = 'red',
    ['enchanter'] = 'red',
    ['psy'] = 'fg',
  }

  character_colors = {
    ['vagrant'] = fg[0],
    ['swordsman'] = yellow[0],
    ['wizard'] = blue[0],
    ['archer'] = green[0],
    ['scout'] = red[0],
    ['cleric'] = green[0],
    ['outlaw'] = red[0],
    ['blade'] = yellow[0],
    ['elementor'] = blue[0],
    ['saboteur'] = red[0],
    ['stormweaver'] = red[0],
    ['sage'] = blue[0],
    ['squire'] = yellow[0],
    ['cannoneer'] = green[0],
    ['dual_gunner'] = green[0],
    ['hunter'] = green[0],
    ['chronomancer'] = blue[0],
    ['spellblade'] = blue[0],
    ['psykeeper'] = fg[0],
    ['engineer'] = yellow[0],
  }

  character_color_strings = {
    ['vagrant'] = 'fg',
    ['swordsman'] = 'yellow',
    ['wizard'] = 'blue',
    ['archer'] = 'green',
    ['scout'] = 'red',
    ['cleric'] = 'green',
    ['outlaw'] = 'red',
    ['blade'] = 'yellow',
    ['elementor'] = 'blue',
    ['saboteur'] = 'red',
    ['stormweaver'] = 'red',
    ['sage'] = 'blue',
    ['squire'] = 'yellow',
    ['cannoneer'] = 'green',
    ['dual_gunner'] = 'green',
    ['hunter'] = 'green',
    ['chronomancer'] = 'blue',
    ['spellblade'] = 'blue',
    ['psykeeper'] = 'fg',
    ['engineer'] = 'yellow',
  }

  character_classes = {
    ['vagrant'] = {'ranger', 'warrior', 'psy'},
    ['swordsman'] = {'warrior'},
    ['wizard'] = {'mage'},
    ['archer'] = {'ranger'},
    ['scout'] = {'rogue'},
    ['cleric'] = {'healer'},
    ['outlaw'] = {'warrior', 'rogue'},
    ['blade'] = {'warrior', 'nuker'},
    ['elementor'] = {'mage', 'nuker'},
    ['saboteur'] = {'rogue', 'conjurer', 'nuker'},
    ['stormweaver'] = {'enchanter'},
    ['sage'] = {'mage', 'nuker'},
    ['squire'] = {'warrior', 'healer', 'enchanter'},
    ['cannoneer'] = {'ranger', 'nuker'},
    ['dual_gunner'] = {'ranger', 'rogue'},
    ['hunter'] = {'ranger', 'conjurer'},
    ['chronomancer'] = {'mage', 'enchanter'},
    ['spellblade'] = {'mage', 'rogue'},
    ['psykeeper'] = {'healer', 'psy'},
    ['engineer'] = {'conjurer'},
  }

  character_descriptions = {
    ['vagrant'] = function(dmg) return '[fg]shoots a projectile that deals [yellow]' .. dmg .. '[fg] damage' end,
    ['swordsman'] = function(dmg) return '[fg]deals [yellow]' .. dmg .. '[fg] damage in an area around the unit' end,
    ['wizard'] = function(dmg) return '[fg]shoots a projectile that deals [yellow]' .. dmg .. ' AoE[fg] damage' end,
    ['archer'] = function(dmg) return '[fg]shoots an arrow that deals [yellow]' .. dmg .. '[fg] damage and pierces' end,
    ['scout'] = function(dmg) return '[fg]throws a knife that deals [yellow]' .. dmg .. '[fg] damage and chains [yellow]3[fg] times' end,
    ['cleric'] = function() return '[fg]heals every unit for [yellow]10%[fg] max hp when any one drops below [yellow]50%[fg] max hp' end,
    ['outlaw'] = function(dmg) return '[fg]throws a fan of [yellow]5[] knives, each dealing [yellow]' .. dmg .. '[fg] damage' end,
    ['blade'] = function(dmg) return '[fg]throws multiple blades that deal [yellow]' .. dmg .. ' AoE[fg] damage' end,
    ['elementor'] = function(dmg) return '[fg]deals [yellow]' .. dmg .. ' AoE[fg] damage to a random target' end,
    ['saboteur'] = function(dmg) return '[fg]calls [yellow]4[] saboteus to seek targets and deal [yellow]' .. dmg .. ' AoE[fg] damage' end,
    ['stormweaver'] = function(dmg) return '[fg]infuses all allied projectiles with chain lightning that deals [yellow]+' .. dmg .. '[fg] damage on hit' end,
    ['sage'] = function(dmg) return '[fg]shoots a slow projectile that draws enemies in' end,
    ['squire'] = function(dmg) return '[yellow]+10 dmg[fg] & [yellow]+25 def[fg] to adjacent units, heal them for [yellow]10%[fg] max hp every 8 seconds' end, 
    ['cannoneer'] = function(dmg) return '[fg]shoots a projectile that deals [yellow]' .. dmg .. ' AoE[fg] damage' end,
    ['dual_gunner'] = function() return '[fg]shoots two parallel projectiles' end,
    ['hunter'] = function(dmg) return '[fg]shoots an arrow that deals [yellow]' .. dmg .. '[fg] damage and has a [yellow]20%[fg] chance to summon a pet' end,
    ['chronomancer'] = function() return '[yellow]+25% aspd[fg] to adjacent units' end,
    ['spellblade'] = function(dmg) return '[fg]throws knives that deal [yellow]' .. dmg .. '[fg] damage, pierce and spiral outwards' end,
    ['psykeeper'] = function() return '[fg]all damage taken is stored and distributed as healing to all allies' end,
    ['engineer'] = function(dmg) return '[fg]drops sentries that shoot bursts of projectiles, each dealing [yellow]' .. dmg .. '[fg] damage' end,
  }

  character_stats = {

  }

  units = {}
  resource = 0

  main = Main()
  main:add(BuyScreen'buy_screen')
  main:go_to('buy_screen', 0)
end


function update(dt)
  main:update(dt)
end


function draw()
  shared_draw(function()
    main:draw()
  end)
end


function love.run()
  return engine_run({
    game_name = 'SNAKRX',
    window_width = 480*3,
    window_height = 270*3,
  })
end
