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
  input:bind('enter', {'space', 'return'})

  music.volume = 0

  local s = {tags = {sfx}}
  dot1 = Sound('Magical Swoosh 18.ogg', s)
  gun_kata1 = Sound('Pistol Shot_07.ogg', s)
  gun_kata2 = Sound('Pistol Shot_08.ogg', s)
  dual_gunner1 = Sound('Revolver Shot_07.ogg', s)
  dual_gunner2 = Sound('Revolver Shot_08.ogg', s)
  ui_hover1 = Sound('bamboo_hit_by_lord.ogg', s)
  ui_switch1 = Sound('Switch.ogg', s)
  ui_switch2 = Sound('Switch 3.ogg', s)
  ui_transition1 = Sound('Wind Bolt 8.ogg', s)
  ui_transition2 = Sound('Wind Bolt 12.ogg', s)
  headbutt1 = Sound('Wind Bolt 14.ogg', s)
  critter1 = Sound('Critters eating 2.ogg', s)
  critter2 = Sound('Crickets Chirping 4.ogg', s)
  critter3 = Sound('Popping bloody Sac 1.ogg', s)
  force1 = Sound('Magical Impact 18.ogg', s)
  error1 = Sound('Error 2.ogg', s)
  coins1 = Sound('Coins 7.ogg', s)
  coins2 = Sound('Coins 8.ogg', s)
  coins3 = Sound('Coins 9.ogg', s)
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
  hit3 = Sound('Kick 16_1.ogg', s)
  hit4 = Sound('Kick 16_2.ogg', s)
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
  pop2 = Sound('467951__benzix2__ui-button-click.ogg', s)
  pop3 = Sound('258269__jcallison__mouth-pop.ogg', s)
  confirm1 = Sound('80921__justinbw__buttonchime02up.ogg', s)
  heal1 = Sound('Buff 3.ogg', s)
  spawn1 = Sound('Buff 13.ogg', s)
  buff1 = Sound('Buff 14.ogg', s)
  spawn_mark1 = Sound('Bonus 2.ogg', s)
  spawn_mark2 = Sound('Bonus.ogg', s)
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
  cascade = Sound('Kubbi - Ember - 04 Cascade.ogg', {tags = {music}})

  warrior = Image('warrior')
  ranger = Image('ranger')
  healer = Image('healer')
  mage = Image('mage')
  rogue = Image('rogue')
  nuker = Image('nuker')
  conjurer = Image('conjurer')
  enchanter = Image('enchanter')
  psyker = Image('psyker')
  trapper = Image('trapper')
  forcer = Image('forcer')
  swarmer = Image('swarmer')
  voider = Image('voider')

  class_colors = {
    ['warrior'] = yellow[0],
    ['ranger'] = green[0],
    ['healer'] = green[0],
    ['conjurer'] = orange[0],
    ['mage'] = blue[0],
    ['nuker'] = red[0],
    ['rogue'] = red[0],
    ['enchanter'] = blue[0],
    ['psyker'] = fg[0],
    ['trapper'] = orange[0],
    ['forcer'] = yellow[0],
    ['swarmer'] = purple[0],
    ['voider'] = purple[0],
  }

  class_color_strings = {
    ['warrior'] = 'yellow',
    ['ranger'] = 'green',
    ['healer'] = 'green',
    ['conjurer'] = 'orange',
    ['mage'] = 'blue',
    ['nuker'] = 'red',
    ['rogue'] = 'red',
    ['enchanter'] = 'blue',
    ['psyker'] = 'fg',
    ['trapper'] = 'orange',
    ['forcer'] = 'yellow',
    ['swarmer'] = 'purple',
    ['voider'] = 'purple',
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
    ['saboteur'] = orange[0],
    ['stormweaver'] = blue[0],
    ['sage'] = purple[0],
    ['squire'] = yellow[0],
    ['cannoneer'] = orange[0],
    ['dual_gunner'] = green[0],
    ['hunter'] = green[0],
    ['chronomancer'] = blue[0],
    ['spellblade'] = blue[0],
    ['psykeeper'] = fg[0],
    ['engineer'] = orange[0],
    ['plague_doctor'] = purple[0],
    ['fisherman'] = yellow[0],
    ['juggernaut'] = yellow[0],
    ['lich'] = blue[0],
    ['cryomancer'] = blue[0],
    ['pyromancer'] = red[0],
    ['corruptor'] = purple[0],
    ['beastmaster'] = red[0],
    ['launcher'] = orange[0],
    ['spiker'] = orange[0],
    ['assassin'] = purple[0],
    ['host'] = purple[0],
    ['carver'] = green[0],
    ['bane'] = purple[0],
    ['psykino'] = fg[0],
    ['arbalester'] = green[0],
    ['barbarian'] = yellow[0],
    ['sapper'] = blue[0],
    ['priest'] = green[0],
    ['burrower'] = orange[0],
    ['flagellant'] = fg[0],
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
    ['saboteur'] = 'orange',
    ['stormweaver'] = 'blue',
    ['sage'] = 'purple',
    ['squire'] = 'yellow',
    ['cannoneer'] = 'orange',
    ['dual_gunner'] = 'green',
    ['hunter'] = 'green',
    ['chronomancer'] = 'blue',
    ['spellblade'] = 'blue',
    ['psykeeper'] = 'fg',
    ['engineer'] = 'orange',
    ['plague_doctor'] = 'purple',
    ['fisherman'] = 'yellow',
    ['juggernaut'] = 'yellow',
    ['lich'] = 'blue',
    ['cryomancer'] = 'blue',
    ['pyromancer'] = 'red',
    ['corruptor'] = 'purple',
    ['beastmaster'] = 'red',
    ['launcher'] = 'orange',
    ['spiker'] = 'orange',
    ['assassin'] = 'purple',
    ['host'] = 'purple',
    ['carver'] = 'green',
    ['bane'] = 'purple',
    ['psykino'] = 'fg',
    ['arbalester'] = 'green',
    ['barbarian'] = 'yellow',
    ['sapper'] = 'blue',
    ['priest'] = 'green',
    ['burrower'] = 'orange',
    ['flagellant'] = 'fg',
  }

  character_classes = {
    ['vagrant'] = {'psyker', 'ranger', 'warrior'},
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
    ['sage'] = {'nuker'},
    ['squire'] = {'warrior', 'enchanter'},
    ['cannoneer'] = {'ranger', 'nuker'},
    ['dual_gunner'] = {'ranger', 'rogue'},
    ['hunter'] = {'ranger', 'conjurer', 'forcer'},
    ['chronomancer'] = {'mage', 'enchanter'},
    ['spellblade'] = {'mage', 'rogue'},
    ['psykeeper'] = {'healer', 'psyker'},
    ['engineer'] = {'conjurer'},
    ['plague_doctor'] = {'nuker', 'voider'},
    ['fisherman'] = {'trapper', 'warrior'},
    ['juggernaut'] = {'forcer', 'warrior'},
    ['lich'] = {'mage'},
    ['cryomancer'] = {'mage', 'voider'},
    ['pyromancer'] = {'mage', 'nuker', 'voider'},
    ['corruptor'] = {'ranger', 'swarmer'},
    ['beastmaster'] = {'rogue', 'swarmer'},
    ['launcher'] = {'trapper', 'forcer'},
    ['spiker'] = {'trapper', 'rogue'},
    ['assassin'] = {'rogue', 'voider'},
    ['host'] = {'conjurer', 'swarmer'},
    ['carver'] = {'conjurer', 'healer'},
    ['bane'] = {'swarmer', 'voider'},
    ['psykino'] = {'mage', 'psyker', 'forcer'},
    ['arbalester'] = {'ranger', 'forcer'},
    ['barbarian'] = {'warrior'},
    ['sapper'] = {'trapper', 'enchanter', 'healer'},
    ['priest'] = {'healer'},
    ['burrower'] = {'trapper', 'swarmer'},
    ['flagellant'] = {'psyker', 'enchanter'},
  }

  character_class_strings = {
    ['vagrant'] = '[fg]Psyker, [green]Ranger, [yellow]Warrior',
    ['swordsman'] = '[yellow]Warrior',
    ['wizard'] = '[blue]Mage',
    ['archer'] = '[green]Ranger',
    ['scout'] = '[red]Rogue',
    ['cleric'] = '[green]Healer',
    ['outlaw'] = '[yellow]Warrior, [red]Rogue',
    ['blade'] = '[yellow]Warrior, [red]Nuker',
    ['elementor'] = '[blue]Mage, [red]Nuker',
    ['saboteur'] = '[red]Rogue, [orange]Conjurer, [red]Nuker',
    ['stormweaver'] = '[blue]Enchanter',
    ['sage'] = '[red]Nuker',
    ['squire'] = '[yellow]Warrior, [blue]Enchanter',
    ['cannoneer'] = '[green]Ranger, [red]Nuker',
    ['dual_gunner'] = '[green]Ranger, [red]Rogue',
    ['hunter'] = '[green]Ranger, [orange]Conjurer, [yellow]Forcer',
    ['chronomancer'] = '[blue]Mage, Enchanter',
    ['spellblade'] = '[blue]Mage, [red]Rogue',
    ['psykeeper'] = '[green]Healer, [fg]Psyker',
    ['engineer'] = '[orange]Conjurer',
    ['plague_doctor'] = '[red]Nuker, [purple]Voider',
    ['fisherman'] = '[orange]Trapper, [yellow]Warrior',
    ['juggernaut'] = '[yellow]Forcer, Warrior',
    ['lich'] = '[blue]Mage',
    ['cryomancer'] = '[blue]Mage, [purple]Voider',
    ['pyromancer'] = '[blue]Mage, [red]Nuker, [purple]Voider',
    ['corruptor'] = '[green]Ranger, [purple]Swarmer',
    ['beastmaster'] = '[red]Rogue, [purple]Swarmer',
    ['launcher'] = '[orange]Trapper, [yellow]Forcer',
    ['spiker'] = '[orange]Trapper, [red]Rogue',
    ['assassin'] = '[red]Rogue, [purple]Voider',
    ['host'] = '[orange]Conjurer, [purple]Swarmer',
    ['carver'] = '[orange]Conjurer, [green]Healer',
    ['bane'] = '[purple]Swarmer, Voider',
    ['psykino'] = '[blue]Mage, [fg]Psyker, [yellow]Forcer',
    ['arbalester'] = '[green]Ranger, [yellow]Forcer',
    ['barbarian'] = '[yellow]Warrior',
    ['sapper'] = '[orange]Trapper, [blue]Enchanter, [green]Healer',
    ['priest'] = '[green]Healer',
    ['burrower'] = '[orange]Trapper, [purple]Swarmer',
    ['flagellant'] = '[fg]Psyker, [blue]Enchanter',
  }

  get_character_stat_string = function(character, level)
    local group = Group():set_as_physics_world(32, 0, 0, {'player', 'enemy', 'projectile', 'enemy_projectile'})
    local player = Player{group = group, leader = true, character = character, level = level, follower_index = 1}
    player:update(0)
    return '[red]HP: [red]' .. player.max_hp .. '[fg], [red]DMG: [red]' .. player.dmg .. '[fg], [green]ASPD: [green]' .. math.round(player.aspd_m, 2) .. 'x[fg], [blue]AREA: [blue]' ..
    math.round(player.area_dmg_m*player.area_size_m, 2) ..  'x[fg], [yellow]DEF: [yellow]' .. math.round(player.def, 2) .. '[fg], [green]MVSPD: [green]' .. math.round(player.v, 2) .. '[fg]'
  end

  get_character_stat = function(character, level, stat)
    local group = Group():set_as_physics_world(32, 0, 0, {'player', 'enemy', 'projectile', 'enemy_projectile'})
    local player = Player{group = group, leader = true, character = character, level = level, follower_index = 1}
    player:update(0)
    return math.round(player[stat], 2)
  end

  character_descriptions = {
    ['vagrant'] = function(lvl) return '[fg]shoots a projectile that deals [yellow]' .. get_character_stat('vagrant', lvl, 'dmg') .. '[fg] damage' end,
    ['swordsman'] = function(lvl) return '[fg]deals [yellow]' .. get_character_stat('swordsman', lvl, 'dmg') .. '[fg] damage in an area, deals extra [yellow]' ..
      math.round(get_character_stat('swordsman', lvl, 'dmg')/3, 2) .. '[fg] damage per unit hit' end,
    ['wizard'] = function(lvl) return '[fg]shoots a projectile that deals [yellow]' .. get_character_stat('wizard', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['archer'] = function(lvl) return '[fg]shoots an arrow that deals [yellow]' .. get_character_stat('archer', lvl, 'dmg') .. '[fg] damage and pierces' end,
    ['scout'] = function(lvl) return '[fg]throws a knife that deals [yellow]' .. get_character_stat('scout', lvl, 'dmg') .. '[fg] damage and chains [yellow]3[fg] times' end,
    ['cleric'] = function(lvl) return '[fg]heals a unit for [yellow]20%[fg] of its max hp when it drops below [yellow]50%[fg] max hp' end,
    ['outlaw'] = function(lvl) return '[fg]throws a fan of [yellow]5[fg] knives, each dealing [yellow]' .. get_character_stat('outlaw', lvl, 'dmg') .. '[fg] damage' end,
    ['blade'] = function(lvl) return '[fg]throws multiple blades that deal [yellow]' .. get_character_stat('blade', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['elementor'] = function(lvl) return '[fg]deals [yellow]' .. get_character_stat('elementor', lvl, 'dmg') .. ' AoE[fg] damage in a large area centered on a random target' end,
    ['saboteur'] = function(lvl) return '[fg]calls [yellow]2[fg] saboteurs to seek targets and deal [yellow]' .. get_character_stat('saboteur', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['stormweaver'] = function(lvl) return '[fg]infuses projectiles with chain lightning that deals [yellow]20%[fg] damage to [yellow]2[fg] enemies' end,
    ['sage'] = function(lvl) return '[fg]shoots a slow projectile that draws enemies in' end,
    ['squire'] = function(lvl) return '[yellow]+15%[fg] damage and defense to all allies' end, 
    ['cannoneer'] = function(lvl) return '[fg]shoots a projectile that deals [yellow]' .. 2*get_character_stat('cannoneer', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['dual_gunner'] = function(lvl) return '[fg]shoots two parallel projectiles, each dealing [yellow]' .. get_character_stat('dual_gunner', lvl, 'dmg') .. '[fg] damage' end,
    ['hunter'] = function(lvl) return '[fg]shoots an arrow that deals [yellow]' .. get_character_stat('hunter', lvl, 'dmg') .. '[fg] damage and has a [yellow]20%[fg] chance to summon a pet' end,
    ['chronomancer'] = function(lvl) return '[yellow]+20%[fg] attack speed to all allies' end,
    ['spellblade'] = function(lvl) return '[fg]throws knives that deal [yellow]' .. get_character_stat('spellblade', lvl, 'dmg') .. '[fg] damage, pierce and spiral outwards' end,
    ['psykeeper'] = function(lvl) return '[fg]all damage taken is stored up to [yellow]50%[fg] max HP and distributed as healing to all allies' end,
    ['engineer'] = function(lvl) return '[fg]drops sentries that shoot bursts of projectiles, each dealing [yellow]' .. get_character_stat('engineer', lvl, 'dmg') .. '[fg] damage' end,
    ['plague_doctor'] = function(lvl) return '[fg]creates an area that deals [yellow]' .. get_character_stat('plague_doctor', lvl, 'dmg') .. '[fg] damage per second' end,
    ['fisherman'] = function(lvl) return '[fg]throws a net that entangles enemies and prevents them from moving for [yellow]4[fg] seconds' end,
    ['juggernaut'] = function(lvl) return '[fg]creates a small area that deals [yellow]' .. get_character_stat('juggernaut', lvl, 'dmg') .. '[fg] damage and pushes enemies away with a strong force' end,
    ['lich'] = function(lvl) return '[fg]launches a chain frost that jumps [yellow]7[fg] times, dealing [yellow]' ..
      get_character_stat('lich', lvl, 'dmg') .. '[fg] damage and slowing enemies by [yellow]50%[fg] for [yellow]2[fg] seconds on hit' end,
    ['cryomancer'] = function(lvl) return '[fg]nearby enemies take [yellow]' .. get_character_stat('cryomancer', lvl, 'dmg') .. '[fg] damage per second and have [yellow]25%[fg] decreased movement speed' end,
    ['pyromancer'] = function(lvl) return '[fg]nearby enemies take [yellow]' .. get_character_stat('pyromancer', lvl, 'dmg') .. '[fg] damage per second and deal [yellow]25%[fg] decreased damage' end,
    ['corruptor'] = function(lvl) return '[fg]spawn [yellow]3[fg] small critters if the corruptor kills an enemy' end,
    ['beastmaster'] = function(lvl) return '[fg]spawn [yellow]2[fg] small critters if the beastmaster crits' end,
    ['launcher'] = function(lvl) return '[fg]creates a trap that launches enemies that trigger it' end,
    ['spiker'] = function(lvl) return '[fg]creates a trap that crits when triggered, dealing [yellow]' .. 4*get_character_stat('spiker', lvl, 'dmg') .. '[fg] damage' end,
    ['assassin'] = function(lvl) return '[fg]throws a piercing knife that deals [yellow]' .. get_character_stat('assassin', lvl, 'dmg') .. '[fg] damage and inflicts poison that deals [yellow]' ..
      get_character_stat('assassin', lvl, 'dmg')/2 .. '[fg] damage per second for [yellow]4[fg] seconds' end,
    ['host'] = function(lvl) return '[fg]creates [yellow]2[fg] overlords that periodically spawn small critters' end,
    ['carver'] = function(lvl) return '[fg]carves a statue that periodically heals for [yellow]20%[fg] max HP in an area around it' end,
    ['bane'] = function(lvl) return '[fg]spawn a small critter that explodes and deals [yellow]' .. get_character_stat('bane', lvl, 'dmg') .. '[fg] damage per second in an area' end,
    ['psykino'] = function(lvl) return '[fg]quickly pulls enemies together and then release them with a force' end,
    ['arbalester'] = function(lvl) return '[fg]launches a massive arrow that deals [yellow]' .. get_character_stat('arbalester', lvl, 'dmg') .. '[fg] damage and pushes enemies back, ignoring knockback resistances' end,
    ['barbarian'] = function(lvl) return '[fg]creates a small area that deals [yellow]' .. 4*get_character_stat('barbarian', lvl, 'dmg') .. '[fg] damage and stuns for [yellow]2[fg] seconds' end,
    ['sapper'] = function(lvl) return '[fg]creates a trap that steals [yellow]10%[fg] enemy HP and grants you [yellow]+25%[fg] movement speed' end,
    ['priest'] = function(lvl) return '[fg]heals all allies for [yellow]20%[fg] their max HP' end,
    ['burrower'] = function(lvl) return '[fg]creates a trap that contains [yellow]6[fg] small critters' end,
    ['flagellant'] = function(lvl) return '[fg]deals damage to self and grants [yellow]+4%[fg] damage to all allies per cast' end,
  }

  character_effect_names = {
    ['vagrant'] = '[fg]Champion',
    ['swordsman'] = '[yellow]Cleave',
    ['wizard'] = '[blue]Magic Missile',
    ['archer'] = '[green]Bounce Shot',
    ['scout'] = '[red]Dagger Resonance',
    ['cleric'] = '[green]Mass Heal ',
    ['outlaw'] = '[red]Flying Daggers',
    ['blade'] = '[yellow]Blade Resonance',
    ['elementor'] = '[blue]Windfield',
    ['saboteur'] = '[orange]Demoman',
    ['stormweaver'] = '[blue]Wide Lightning',
    ['sage'] = '[purple]Dimension Compression',
    ['squire'] = '[yellow]Repair',
    ['cannoneer'] = '[orange]Cannon Barrage',
    ['dual_gunner'] = '[green]Gun Kata',
    ['hunter'] = '[green]Feral Pack',
    ['chronomancer'] = '[blue]Quicken',
    ['spellblade'] = '[blue]Spiralism',
    ['psykeeper'] = '[fg]Crucio',
    ['engineer'] = '[orange]Upgrade',
    ['plague_doctor'] = '[purple]Black Death Steam',
    ['fisherman'] = '[yellow]Electric Net',
    ['juggernaut'] = '[yellow]Brutal Impact',
    ['lich'] = '[blue]Piercing Frost',
    ['cryomancer'] = '[blue]Frostbite',
    ['pyromancer'] = '[red]Ignite',
    ['corruptor'] = '[purple]Infestation',
    ['beastmaster'] = '[red]Call of the Wild',
    ['launcher'] = '[orange]Kineticism',
    ['spiker'] = '[orange]Caltrops',
    ['assassin'] = '[purple]Toxic Delivery',
    ['host'] = '[purple]Invasion',
    ['carver'] = '[green]World Tree',
    ['bane'] = '[purple]Baneling Swarm',
    ['psykino'] = '[fg]Magnetic Force',
    ['arbalester'] = '[green]Ballista Sinitra',
    ['barbarian'] = '[yellow]Berserk',
    ['sapper'] = '[blue]Chain Reaction',
    ['priest'] = '[green]Divine Intervention',
    ['burrower'] = '[orange]Zergling Rush',
    ['flagellant'] = '[red]Zealotry',
  }

  character_effect_names_gray = {
    ['vagrant'] = '[light_bg]Champion',
    ['swordsman'] = '[light_bg]Cleave',
    ['wizard'] = '[light_bg]Magic Missile',
    ['archer'] = '[light_bg]Bounce Shot',
    ['scout'] = '[light_bg]Dagger Resonance',
    ['cleric'] = '[light_bg]Mass Heal ',
    ['outlaw'] = '[light_bg]Flying Daggers',
    ['blade'] = '[light_bg]Blade Resonance',
    ['elementor'] = '[light_bg]Windfield',
    ['saboteur'] = '[light_bg]Demoman',
    ['stormweaver'] = '[light_bg]Wide Lightning',
    ['sage'] = '[light_bg]Dimension Compression',
    ['squire'] = '[light_bg]Repair',
    ['cannoneer'] = '[light_bg]Cannon Barrage',
    ['dual_gunner'] = '[light_bg]Gun Kata',
    ['hunter'] = '[light_bg]Feral Pack',
    ['chronomancer'] = '[light_bg]Quicken',
    ['spellblade'] = '[light_bg]Spiralism',
    ['psykeeper'] = '[light_bg]Crucio',
    ['engineer'] = '[light_bg]Upgrade',
    ['plague_doctor'] = '[light_bg]Black Death Steam',
    ['fisherman'] = '[light_bg]Electric Net',
    ['juggernaut'] = '[light_bg]Brutal Impact',
    ['lich'] = '[light_bg]Piercing Frost',
    ['cryomancer'] = '[light_bg]Frostbite',
    ['pyromancer'] = '[light_bg]Ignite',
    ['corruptor'] = '[light_bg]Infestation',
    ['beastmaster'] = '[light_bg]Call of the Wild',
    ['launcher'] = '[light_bg]Kineticism',
    ['spiker'] = '[light_bg]Caltrops',
    ['assassin'] = '[light_bg]Toxic Delivery',
    ['host'] = '[light_bg]Invasion',
    ['carver'] = '[light_bg]World Tree',
    ['bane'] = '[light_bg]Baneling Swarm',
    ['psykino'] = '[light_bg]Magnetic Force',
    ['arbalester'] = '[light_bg]Ballista Sinitra',
    ['barbarian'] = '[light_bg]Berserk',
    ['sapper'] = '[light_bg]Chain Reaction',
    ['priest'] = '[light_bg]Divine Intervention',
    ['burrower'] = '[light_bg]Zergling Rush',
    ['flagellant'] = '[light_bg]Zealotry',
  }

  character_effect_descriptions = {
    ['vagrant'] = function() return '[yellow]+10%[fg] damage and [yellow]+5%[fg] attack speed per active set' end,
    ['swordsman'] = function() return "[fg]the swordsman's damage is [yellow]doubled" end,
    ['wizard'] = function() return '[fg]the projectile chains [yellow]5[fg] times' end,
    ['archer'] = function() return '[fg]the arrow ricochets off walls [yellow]3[fg] times' end,
    ['scout'] = function() return '[yellow]+25%[fg] damage per chain and [yellow]+3[fg] chains' end,
    ['cleric'] = function() return '[fg]heals all units' end,
    ['outlaw'] = function() return "[yellow]+50%[fg] outlaw attack speed and his knives seek enemies" end,
    ['blade'] = function() return '[fg]deal additional [yellow]' .. get_character_stat('blade', 3, 'dmg')/2 .. '[fg] damage per enemy hit' end,
    ['elementor'] = function() return '[fg]slows enemies by [yellow]60%[fg] for [yellow]6[fg] seconds on hit' end,
    ['saboteur'] = function() return '[fg]the explosion has [yellow]50%[fg] chance to crit, increasing in size and dealing [yellow]2x[fg] damage' end,
    ['stormweaver'] = function() return "[fg]chain lightning's trigger area of effect and number of units hit is [yellow]doubled" end,
    ['sage'] = function() return '[fg]when the projectile expires deal [yellow]' .. 3*get_character_stat('sage', 3, 'dmg') .. '[fg] damage to all enemies under its influence' end,
    ['squire'] = function() return '[fg]you can reroll your item choices once, these opportunities stack if unused' end,
    ['cannoneer'] = function() return '[fg]showers the hit area in [yellow]5[fg] additional cannon shots that deal [yellow]' .. get_character_stat('cannoneer', 3, 'dmg')/2 .. '[fg] AoE damage' end,
    ['dual_gunner'] = function() return '[fg]every 5th attack shoot in rapid succession for [yellow]2[fg] seconds' end,
    ['hunter'] = function() return '[fg]summons [yellow]3[fg] pets and the pets ricochet off walls once' end,
    ['chronomancer'] = function() return '[fg]enemies take damave over time [yellow]50%[fg] faster' end,
    ['spellblade'] = function() return '[fg]faster projectile speed and tighter turns' end,
    ['psykeeper'] = function() return '[fg]also redistributes damage taken as damage to all enemies at [yellow]double[fg] value' end,
    ['engineer'] = function() return '[fg]every 3rd sentry dropped upgrade all sentries with [yellow]+100%[fg] damage and attack speed' end,
    ['plague_doctor'] = function() return '[fg]nearby enemies take an additional [yellow]' .. get_character_stat('plague_doctor', 3, 'dmg') .. '[fg] damage per second' end,
    ['fisherman'] = function() return '[fg]enemies caught take [yellow]' .. get_character_stat('fisherman', 3, 'dmg')/4 .. '[fg] damage per second' end,
    ['juggernaut'] = function() return '[fg]enemies pushed away by the juggernaut are instantly killed if they hit a wall' end,
    ['lich'] = function() return '[fg]chain frost decreases enemy defenses by [yellow]30[fg] for [yellow]4[fg] seconds' end,
    ['cryomancer'] = function() return '[fg]enemies killed by the cryomancer freeze nearby enemies, frozen enemies take increased damage and do not move' end,
    ['pyromancer'] = function() return '[fg]enemies killed by the pyromancer explode, dealing [yellow]' .. get_character_stat('pyromancer', 3, 'dmg') .. '[fg] AoE damage' end,
    ['corruptor'] = function() return '[fg]spawn [yellow]3[fg] small critters if the corruptor hits an enemy' end,
    ['beastmaster'] = function() return '[fg]spawn [yellow]2[fg] small critters if the beastmaster gets hit' end,
    ['launcher'] = function() return '[fg]enemies launched that hit other enemies push those enemies at double the force they were pushed' end,
    ['spiker'] = function() return '[fg]slows enemies hit by [yellow]50%[fg] for [yellow]2[fg] seconds and deals [yellow]' .. get_character_stat('spiker', 3, 'dmg') .. '[fg] damage per second' end,
    ['assassin'] = function() return '[fg]poison inflicted from crits deals [yellow]8x[fg] damage' end,
    ['host'] = function() return '[fg][yellow]+50%[fg] critter spawn rate' end,
    ['carver'] = function() return '[fg]carves a tree that heals in a bigger area and removes all buffs from enemies' end,
    ['bane'] = function() return '[fg]spawn [yellow]4[fg] banelings' end,
    ['psykino'] = function() return '[fg]enemies pulled together are forced to collide with each other multiple times' end,
    ['arbalester'] = function() return '[fg]enemies hit by the arrow have defense decreased by [yellow]100[fg] for [yellow]4[fg] seconds' end,
    ['barbarian'] = function() return '[fg][yellow]+50%[fg] attack speed' end,
    ['sapper'] = function() return '[fg]when a sapper trap is triggered other nearby traps are also triggered' end,
    ['priest'] = function() return '[fg]at the start of the round pick [yellow]3[fg] units at random and grants them a buff that prevents death once' end,
    ['burrower'] = function() return '[fg][yellow]triples[fg] the number of critters released' end,
    ['flagellant'] = function() return '[fg]deals damage to all allies instead and grants [yellow]+10%[fg] damage to all allies per cast' end,
  }

  character_stats = {
    ['vagrant'] = function(lvl) return get_character_stat_string('vagrant', lvl) end,
    ['swordsman'] = function(lvl) return get_character_stat_string('swordsman', lvl) end, 
    ['wizard'] = function(lvl) return get_character_stat_string('wizard', lvl) end, 
    ['archer'] = function(lvl) return get_character_stat_string('archer', lvl) end, 
    ['scout'] = function(lvl) return get_character_stat_string('scout', lvl) end, 
    ['cleric'] = function(lvl) return get_character_stat_string('cleric', lvl) end, 
    ['outlaw'] = function(lvl) return get_character_stat_string('outlaw', lvl) end, 
    ['blade'] = function(lvl) return get_character_stat_string('blade', lvl) end, 
    ['elementor'] = function(lvl) return get_character_stat_string('elementor', lvl) end, 
    ['saboteur'] = function(lvl) return get_character_stat_string('saboteur', lvl) end, 
    ['stormweaver'] = function(lvl) return get_character_stat_string('stormweaver', lvl) end, 
    ['sage'] = function(lvl) return get_character_stat_string('sage', lvl) end, 
    ['squire'] = function(lvl) return get_character_stat_string('squire', lvl) end, 
    ['cannoneer'] = function(lvl) return get_character_stat_string('cannoneer', lvl) end, 
    ['dual_gunner'] = function(lvl) return get_character_stat_string('dual_gunner', lvl) end, 
    ['hunter'] = function(lvl) return get_character_stat_string('hunter', lvl) end, 
    ['chronomancer'] = function(lvl) return get_character_stat_string('chronomancer', lvl) end, 
    ['spellblade'] = function(lvl) return get_character_stat_string('spellblade', lvl) end, 
    ['psykeeper'] = function(lvl) return get_character_stat_string('psykeeper', lvl) end, 
    ['engineer'] = function(lvl) return get_character_stat_string('engineer', lvl) end, 
    ['plague_doctor'] = function(lvl) return get_character_stat_string('plague_doctor', lvl) end,
    ['fisherman'] = function(lvl) return get_character_stat_string('fisherman', lvl) end,
    ['juggernaut'] = function(lvl) return get_character_stat_string('juggernaut', lvl) end,
    ['lich'] = function(lvl) return get_character_stat_string('lich', lvl) end,
    ['cryomancer'] = function(lvl) return get_character_stat_string('cryomancer', lvl) end,
    ['pyromancer'] = function(lvl) return get_character_stat_string('pyromancer', lvl) end,
    ['corruptor'] = function(lvl) return get_character_stat_string('corruptor', lvl) end,
    ['beastmaster'] = function(lvl) return get_character_stat_string('beastmaster', lvl) end,
    ['launcher'] = function(lvl) return get_character_stat_string('launcher', lvl) end,
    ['spiker'] = function(lvl) return get_character_stat_string('spiker', lvl) end,
    ['assassin'] = function(lvl) return get_character_stat_string('assassin', lvl) end,
    ['host'] = function(lvl) return get_character_stat_string('host', lvl) end,
    ['carver'] = function(lvl) return get_character_stat_string('carver', lvl) end,
    ['bane'] = function(lvl) return get_character_stat_string('bane', lvl) end,
    ['psykino'] = function(lvl) return get_character_stat_string('psykino', lvl) end,
    ['arbalester'] = function(lvl) return get_character_stat_string('arbalester', lvl) end,
    ['barbarian'] = function(lvl) return get_character_stat_string('barbarian', lvl) end,
    ['sapper'] = function(lvl) return get_character_stat_string('sapper', lvl) end,
    ['priest'] = function(lvl) return get_character_stat_string('priest', lvl) end,
    ['burrower'] = function(lvl) return get_character_stat_string('burrower', lvl) end,
    ['flagellant'] = function(lvl) return get_character_stat_string('flagellant', lvl) end,
  }

  class_stat_multipliers = {
    ['ranger'] = {hp = 1, dmg = 1.2, aspd = 1.5, area_dmg = 1, area_size = 1, def = 0.9, mvspd = 1.2},
    ['warrior'] = {hp = 1.4, dmg = 1.1, aspd = 0.9, area_dmg = 1, area_size = 1, def = 1.25, mvspd = 0.9},
    ['mage'] = {hp = 0.6, dmg = 1.4, aspd = 1, area_dmg = 1.25, area_size = 1.2, def = 0.75, mvspd = 1},
    ['rogue'] = {hp = 0.8, dmg = 1.3, aspd = 1.1, area_dmg = 0.6, area_size = 0.6, def = 0.8, mvspd = 1.4},
    ['healer'] = {hp = 1.2, dmg = 1, aspd = 0.5, area_dmg = 1, area_size = 1, def = 1.2, mvspd = 1},
    ['enchanter'] = {hp = 1.2, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1.2, mvspd = 1.2},
    ['nuker'] = {hp = 0.9, dmg = 1, aspd = 0.75, area_dmg = 1.5, area_size = 1.5, def = 1, mvspd = 1},
    ['conjurer'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 1},
    ['psyker'] = {hp = 1.5, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 0.5, mvspd = 1},
    ['trapper'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 0.75, mvspd = 1},
    ['forcer'] = {hp = 1.25, dmg = 1.1, aspd = 0.9, area_dmg = 0.75, area_size = 0.75, def = 1.2, mvspd = 1},
    ['swarmer'] = {hp = 1.2, dmg = 1, aspd = 1.25, area_dmg = 1, area_size = 1, def = 0.75, mvspd = 0.5},
    ['voider'] = {hp = 0.75, dmg = 1.3, aspd = 1, area_dmg = 0.8, area_size = 0.75, def = 0.6, mvspd = 0.8},
    ['seeker'] = {hp = 0.5, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 0.3},
    ['mini_boss'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 0.3},
    ['enemy_critter'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 0.5},
    ['saboteur'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 1.4},
  }

  local ylb1 = function(lvl) return lvl >= 2 and 'fg' or (lvl >= 1 and 'yellow' or 'light_bg') end
  local ylb2 = function(lvl) return (lvl >= 2 and 'yellow' or 'light_bg') end
  class_descriptions = {
    ['ranger'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']10%[' .. ylb2(lvl) .. ']/20% [fg]chance to release a barrage on attack to allied rangers' end,
    ['warrior'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']+25[' .. ylb2(lvl) .. ']/+50 [fg]defense to allied warriors' end,
    ['mage'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']-15[' .. ylb2(lvl) .. ']/-30 [fg]enemy defense' end,
    ['rogue'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']10%[' .. ylb2(lvl) .. ']/20% [fg]chance to crit to allied rogues, dealing [yellow]4x[] damage' end,
    ['healer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+30% [fg]healing effectiveness' end,
    ['enchanter'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+25% [fg]damage to all allies' end,
    ['nuker'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+25% [fg]area damage and size to allied nukers' end,
    ['conjurer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+25%[' .. ylb2(lvl) .. ']/+50% [fg]summon damage and duration' end,
    ['psyker'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+5%[' .. ylb2(lvl) .. ']/+10% [fg]damage and health per active set to allied psykers' end,
    ['trapper'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+1[' .. ylb2(lvl) .. ']/+2 [fg]extra traps released' end,
    ['forcer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+25%[' .. ylb2(lvl) .. ']/+50% [fg]knockback force to all allies' end,
    ['swarmer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+1[' .. ylb2(lvl) .. ']/+3 [fg]hits to critters' end,
    ['voider'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+25% [fg]damage over time to allied voiders' end,
  }

  tier_to_characters = {
    [1] = {'vagrant', 'swordsman', 'wizard', 'archer', 'scout', 'cleric'},
    [2] = {'saboteur', 'sage', 'squire', 'dual_gunner', 'hunter', 'chronomancer', 'fisherman', 'cryomancer', 'beastmaster', 'launcher', 'spiker', 'carver'},
    [3] = {'outlaw', 'elementor', 'stormweaver', 'spellblade', 'psykeeper', 'engineer', 'juggernaut', 'pyromancer', 'corruptor', 'assassin', 'bane', 'arbalester', 'burrower', 'flagellant'},
    [4] = {'priest', 'barbarian', 'psykino', 'lich', 'host', 'sapper', 'blade', 'plague_doctor', 'cannoneer'},
  }

  non_attacking_characters = {'cleric', 'stormweaver', 'squire', 'chronomancer', 'sage'}

  character_tiers = {
    ['vagrant'] = 1,
    ['swordsman'] = 1,
    ['wizard'] = 1,
    ['archer'] = 1,
    ['scout'] = 1,
    ['cleric'] = 1,
    ['outlaw'] = 3,
    ['blade'] = 4,
    ['elementor'] = 3,
    ['saboteur'] = 2,
    ['stormweaver'] = 3,
    ['sage'] = 2,
    ['squire'] = 2,
    ['cannoneer'] = 4,
    ['dual_gunner'] = 2,
    ['hunter'] = 2,
    ['chronomancer'] = 2,
    ['spellblade'] = 3,
    ['psykeeper'] = 3,
    ['engineer'] = 3,
    ['plague_doctor'] = 4,
    ['fisherman'] = 2,
    ['juggernaut'] = 3,
    ['lich'] = 4,
    ['cryomancer'] = 2,
    ['pyromancer'] = 3,
    ['corruptor'] = 3,
    ['beastmaster'] = 2,
    ['launcher'] = 2,
    ['spiker'] = 2,
    ['assassin'] = 3,
    ['host'] = 4,
    ['carver'] = 2,
    ['bane'] = 3,
    ['psykino'] = 4,
    ['arbalester'] = 3,
    ['barbarian'] = 4,
    ['sapper'] = 4,
    ['priest'] = 4,
    ['burrower'] = 3,
    ['flagellant'] = 3,
  }

  get_number_of_units_per_class = function(units)
    local rangers = 0
    local warriors = 0
    local healers = 0
    local mages = 0
    local nukers = 0
    local conjurers = 0
    local rogues = 0
    local enchanters = 0
    local psykers = 0
    local trappers = 0
    local forcers = 0
    local swarmers = 0
    local voiders = 0
    for _, unit in ipairs(units) do
      for _, unit_class in ipairs(character_classes[unit.character]) do
        if unit_class == 'ranger' then rangers = rangers + 1 end
        if unit_class == 'warrior' then warriors = warriors + 1 end
        if unit_class == 'healer' then healers = healers + 1 end
        if unit_class == 'mage' then mages = mages + 1 end
        if unit_class == 'nuker' then nukers = nukers + 1 end
        if unit_class == 'conjurer' then conjurers = conjurers + 1 end
        if unit_class == 'rogue' then rogues = rogues + 1 end
        if unit_class == 'enchanter' then enchanters = enchanters + 1 end
        if unit_class == 'psyker' then psykers = psykers + 1 end
        if unit_class == 'trapper' then trappers = trappers + 1 end
        if unit_class == 'forcer' then forcers = forcers + 1 end
        if unit_class == 'swarmer' then swarmers = swarmers + 1 end
        if unit_class == 'voider' then voiders = voiders + 1 end
      end
    end
    return {ranger = rangers, warrior = warriors, healer = healers, mage = mages, nuker = nukers, conjurer = conjurers, rogue = rogues,
      enchanter = enchanters, psyker = psykers, trapper = trappers, forcer = forcers, swarmer = swarmers, voider = voiders}
  end

  get_class_levels = function(units)
    local units_per_class = get_number_of_units_per_class(units)
    local units_to_class_level = function(number_of_units, class)
      if class == 'ranger' or class == 'warrior' or class == 'mage' or class == 'nuker' or class == 'rogue' then
        if number_of_units >= 6 then return 2
        elseif number_of_units >= 3 then return 1
        else return 0 end
      elseif class == 'healer' or class == 'conjurer' or class == 'enchanter' or class == 'psyker' or class == 'trapper' or class == 'forcer' or class == 'swarmer' or class == 'voider' then
        if number_of_units >= 4 then return 2
        elseif number_of_units >= 2 then return 1
        else return 0 end
      end
    end
    return {
      ranger = units_to_class_level(units_per_class.ranger, 'ranger'),
      warrior = units_to_class_level(units_per_class.warrior, 'warrior'),
      mage = units_to_class_level(units_per_class.mage, 'mage'),
      nuker = units_to_class_level(units_per_class.nuker, 'nuker'),
      rogue = units_to_class_level(units_per_class.rogue, 'rogue'),
      healer = units_to_class_level(units_per_class.healer, 'healer'),
      conjurer = units_to_class_level(units_per_class.conjurer, 'conjurer'),
      enchanter = units_to_class_level(units_per_class.enchanter, 'enchanter'),
      psyker = units_to_class_level(units_per_class.psyker, 'psyker'),
      trapper = units_to_class_level(units_per_class.trapper, 'trapper'),
      forcer = units_to_class_level(units_per_class.forcer, 'forcer'),
      swarmer = units_to_class_level(units_per_class.swarmer, 'swarmer'),
      voider = units_to_class_level(units_per_class.voider, 'voider'),
    }
  end

  get_classes = function(units)
    local classes = {}
    for _, unit in ipairs(units) do
      table.insert(classes, table.copy(character_classes[unit.character]))
    end
    return table.unify(table.flatten(classes))
  end

  class_set_numbers = {
    ['ranger'] = function(units) return 3, 6, get_number_of_units_per_class(units).ranger end,
    ['warrior'] = function(units) return 3, 6, get_number_of_units_per_class(units).warrior end,
    ['mage'] = function(units) return 3, 6, get_number_of_units_per_class(units).mage end,
    ['nuker'] = function(units) return 3, 6, get_number_of_units_per_class(units).nuker end,
    ['rogue'] = function(units) return 3, 6, get_number_of_units_per_class(units).rogue end,
    ['healer'] = function(units) return 2, 4, get_number_of_units_per_class(units).healer end,
    ['conjurer'] = function(units) return 2, 4, get_number_of_units_per_class(units).conjurer end,
    ['enchanter'] = function(units) return 2, 4, get_number_of_units_per_class(units).enchanter end,
    ['psyker'] = function(units) return 2, 4, get_number_of_units_per_class(units).psyker end,
    ['trapper'] = function(units) return 2, 4, get_number_of_units_per_class(units).trapper end,
    ['forcer'] = function(units) return 2, 4, get_number_of_units_per_class(units).forcer end,
    ['swarmer'] = function(units) return 2, 4, get_number_of_units_per_class(units).swarmer end,
    ['voider'] = function(units) return 2, 4, get_number_of_units_per_class(units).voider end,
  }

  level_to_tier_weights = {
    [1] = {90, 10, 0, 0},
    [2] = {80, 15, 5, 0},
    [3] = {75, 20, 5, 0},
    [4] = {70, 20, 10, 0},
    [5] = {70, 20, 10, 0},
    [6] = {65, 25, 10, 0},
    [7] = {60, 25, 15, 0},
    [8] = {55, 25, 15, 5},
    [9] = {50, 30, 15, 5},
    [10] = {50, 30, 15, 5},
    [11] = {45, 30, 20, 5},
    [12] = {45, 30, 20, 5},
    [13] = {40, 30, 20, 10},
    [14] = {40, 30, 20, 10},
    [15] = {35, 35, 20, 10},
    [16] = {30, 40, 20, 10},
    [17] = {20, 40, 25, 15},
    [18] = {20, 40, 25, 15},
    [19] = {15, 40, 30, 15},
    [20] = {10, 40, 30, 20},
    [21] = {5, 40, 35, 20},
    [22] = {5, 35, 35, 25},
    [23] = {5, 35, 35, 25},
    [24] = {0, 30, 40, 30},
    [25] = {0, 25, 40, 35},
  }

  level_to_gold_gained = {
    [1] = {2, 2},
    [2] = {2, 2},
    [3] = {4, 6},
    [4] = {2, 3},
    [5] = {3, 5},
    [6] = {6, 10},
    [7] = {4, 7}, 
    [8] = {4, 7},
    [9] = {10, 16},
    [10] = {5, 8},
    [11] = {5, 8},
    [12] = {12, 20},
    [13] = {6, 10},
    [14] = {6, 10},
    [15] = {14, 22},
    [16] = {8, 12},
    [17] = {8, 12},
    [18] = {16, 24}, 
    [19] = {8, 12},
    [20] = {10, 14}, 
    [21] = {20, 28},
    [22] = {11, 15},
    [23] = {11, 15},
    [24] = {24, 36},
    [25] = {100, 100},
  }

  level_to_boss = {
    [6] = 'speed_booster',
    [12] = 'exploder',
    [18] = 'swarmer',
    [24] = 'bouncer',
    [25] = 'randomizer',
  }

  gold = 2

  main = Main()
  main:add(BuyScreen'buy_screen')
  main:go_to('buy_screen', 22, {
    {character = 'fisherman', level = 3},
  })
  --[[
  main:add(Arena'arena')
  main:go_to('arena', 18, {
    {character = 'scout', level = 3},
    {character = 'engineer', level = 3},
    {character = 'wizard', level = 3},
    {character = 'swordsman', level = 3},
    {character = 'outlaw', level = 3},
    {character = 'archer', level = 3},
    {character = 'cannoneer', level = 3},
    {character = 'spellblade', level = 3},
  })
  ]]--
end


function update(dt)
  main:update(dt)

  if input.n.pressed then
    if sfx.volume == 0.5 then
      sfx.volume = 0
    elseif sfx.volume == 0 then
      sfx.volume = 0.5
    end
  end

  if input.m.pressed then
    if music.volume == 0.5 then
      music.volume = 0
    elseif music.volume == 0 then
      music.volume = 0.5
    end
  end
end


function draw()
  shared_draw(function()
    main:draw()
  end)
end


function love.run()
  return engine_run({
    game_name = 'SNKRX',
    window_width = 480*3,
    window_height = 270*3,
  })
end
