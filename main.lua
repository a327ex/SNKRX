require 'engine'
require 'shared'
require 'arena'
require 'buy_screen'
require 'objects'
require 'player'
require 'enemies'
require 'media'


function init()
  shared_init()

  input:bind('move_left', {'a', 'left', 'dpleft', 'm1'})
  input:bind('move_right', {'d', 'right', 'dpright', 'm2'})
  input:bind('move_up', {'w', 'up', 'dpup'})
  input:bind('move_down', {'s', 'down', 'dpdown'})
  input:bind('enter', {'space', 'return', 'fleft', 'fdown', 'fright'})

  local s = {tags = {sfx}}
  gambler1 = Sound('Collect 5.ogg', s)
  usurer1 = Sound('Shadow Punch 2.ogg', s)
  gold1 = Sound('Collect 5.ogg', s)
  gold2 = Sound('Coins - Gears - Slot.ogg', s)
  psychic1 = Sound('Magical Impact 13.ogg', s)
  fire1 = Sound('Fire bolt 3.ogg', s)
  fire2 = Sound('Fire bolt 5.ogg', s)
  fire3 = Sound('Fire bolt 10.ogg', s)
  earth1 = Sound('Earth Bolt 1.ogg', s)
  earth2 = Sound('Earth Bolt 14.ogg', s)
  earth3 = Sound('Earth Bolt 20.ogg', s)
  illusion1 = Sound('Buff 5.ogg', s)
  thunder1 = Sound('399656__bajko__sfx-thunder-blast.ogg', s)
  flagellant1 = Sound('Whipping Horse 3.ogg', s)
  bard2 = Sound('376532__womb-affliction__flute-trill.ogg', s)
  arcane2 = Sound('Magical Impact 12.ogg', s)
  frost1 = Sound('Frost Bolt 20.ogg', s)
  arcane1 = Sound('Magical Impact 26.ogg', s)
  pyro1 = Sound('Fire bolt 5.ogg', s)
  pyro2 = Sound('Explosion Fireworks_01.ogg', s)
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

  song1 = Sound('Kubbi - Ember - 01 Pathfinder.ogg', {tags = {music}})
  song2 = Sound('Kubbi - Ember - 02 Ember.ogg', {tags = {music}})
  song3 = Sound('Kubbi - Ember - 03 Firelight.ogg', {tags = {music}})
  song4 = Sound('Kubbi - Ember - 04 Cascade.ogg', {tags = {music}})
  song5 = Sound('Kubbi - Ember - 05 Compass.ogg', {tags = {music}})
  death_song = Sound('Kubbi - Ember - 09 Formed by Glaciers.ogg', {tags = {music}})

  lock_image = Image('lock')
  speed_booster_elite = Image('speed_booster_elite')
  exploder_elite = Image('exploder_elite')
  swarmer_elite = Image('swarmer_elite')
  forcer_elite = Image('forcer_elite')
  cluster_elite = Image('cluster_elite')
  warrior = Image('warrior')
  ranger = Image('ranger')
  healer = Image('healer')
  mage = Image('mage')
  rogue = Image('rogue')
  nuker = Image('nuker')
  conjurer = Image('conjurer')
  enchanter = Image('enchanter')
  psyker = Image('psyker')
  curser = Image('curser')
  forcer = Image('forcer')
  swarmer = Image('swarmer')
  voider = Image('voider')
  sorcerer = Image('sorcerer')
  mercenary = Image('mercenary')
  ouroboros_technique_r = Image('ouroboros_technique_r')
  ouroboros_technique_l = Image('ouroboros_technique_l')
  wall_echo = Image('wall_echo')
  wall_rider = Image('wall_rider')
  centipede = Image('centipede')
  intimidation = Image('intimidation')
  vulnerability = Image('vulnerability')
  temporal_chains = Image('temporal_chains')
  amplify = Image('amplify')
  amplify_x = Image('amplify_x')
  resonance = Image('resonance')
  ballista = Image('ballista')
  ballista_x = Image('ballista_x')
  point_blank = Image('point_blank')
  longshot = Image('longshot')
  blunt_arrow = Image('blunt_arrow')
  explosive_arrow = Image('explosive_arrow')
  divine_machine_arrow = Image('divine_machine_arrow')
  chronomancy = Image('chronomancy')
  awakening = Image('awakening')
  divine_punishment = Image('divine_punishment')
  berserking = Image('berserking')
  unwavering_stance = Image('unwavering_stance')
  ultimatum = Image('ultimatum')
  flying_daggers = Image('flying_daggers')
  assassination = Image('assassination')
  magnify = Image('magnify')
  echo_barrage = Image('echo_barrage')
  unleash = Image('unleash')
  reinforce = Image('reinforce')
  payback = Image('payback')
  blessing = Image('blessing')
  hex_master = Image('hex_master')
  whispers_of_doom = Image('whispers_of_doom')
  force_push = Image('force_push')
  heavy_impact = Image('heavy_impact')
  crucio = Image('crucio')
  immolation = Image('immolation')
  call_of_the_void = Image('call_of_the_void')
  spawning_pool = Image('spawning_pool')
  hive = Image('hive')
  void_rift = Image('void_rift')
  star = Image('star')
  arrow = Image('arrow')

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
    ['curser'] = purple[0],
    ['forcer'] = yellow[0],
    ['swarmer'] = orange[0],
    ['voider'] = purple[0],
    ['sorcerer'] = blue2[0],
    ['mercenary'] = yellow2[0],
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
    ['curser'] = 'purple',
    ['forcer'] = 'yellow',
    ['swarmer'] = 'orange',
    ['voider'] = 'purple',
    ['sorcerer'] = 'blue2',
    ['mercenary'] = 'yellow2',
  }

  character_names = {
    ['vagrant'] = 'Vagrant',
    ['swordsman'] = 'Swordsman',
    ['wizard'] = 'Wizard',
    ['magician'] = 'Magician',
    ['archer'] = 'Archer',
    ['scout'] = 'Scout',
    ['cleric'] = 'Cleric',
    ['outlaw'] = 'Outlaw',
    ['blade'] = 'Blade',
    ['elementor'] = 'Elementor',
    ['saboteur'] = 'Saboteur',
    ['stormweaver'] = 'Stormweaver',
    ['sage'] = 'Sage',
    ['squire'] = 'Squire',
    ['cannoneer'] = 'Cannoneer',
    ['dual_gunner'] = 'Dual Gunner',
    ['hunter'] = 'Hunter',
    ['chronomancer'] = 'Chronomancer',
    ['spellblade'] = 'Spellblade',
    ['psykeeper'] = 'Psykeeper',
    ['engineer'] = 'Engineer',
    ['plague_doctor'] = 'Plague Doctor',
    ['barbarian'] = 'Barbarian',
    ['juggernaut'] = 'Juggernaut',
    ['lich'] = 'Lich',
    ['cryomancer'] = 'Cryomancer',
    ['pyromancer'] = 'Pyromancer',
    ['corruptor'] = 'Corruptor',
    ['beastmaster'] = 'Beastmaster',
    ['launcher'] = 'Launcher',
    ['jester'] = 'Jester',
    ['assassin'] = 'Assassin',
    ['host'] = 'Host',
    ['carver'] = 'Carver',
    ['bane'] = 'Bane',
    ['psykino'] = 'Psykino',
    ['barrager'] = 'Barrager',
    ['highlander'] = 'Highlander',
    ['fairy'] = 'Fairy',
    ['priest'] = 'Priest',
    ['infestor'] = 'Infestor',
    ['flagellant'] = 'Flagellant',
    ['arcanist'] = 'Arcanist',
    ['illusionist'] = 'Illusionist',
    ['witch'] = 'Witch',
    ['silencer'] = 'Silencer',
    ['vulcanist'] = 'Vulcanist',
    ['warden'] = 'Warden',
    ['psychic'] = 'Psychic',
    ['miner'] = 'Miner',
    ['merchant'] = 'Merchant',
    ['usurer'] = 'Usurer',
    ['gambler'] = 'Gambler',
    ['thief'] = 'Thief',
  }

  character_colors = {
    ['vagrant'] = fg[0],
    ['swordsman'] = yellow[0],
    ['wizard'] = blue[0],
    ['magician'] = blue[0],
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
    ['barbarian'] = yellow[0],
    ['juggernaut'] = yellow[0],
    ['lich'] = blue[0],
    ['cryomancer'] = blue[0],
    ['pyromancer'] = red[0],
    ['corruptor'] = orange[0],
    ['beastmaster'] = red[0],
    ['launcher'] = yellow[0],
    ['jester'] = red[0],
    ['assassin'] = purple[0],
    ['host'] = orange[0],
    ['carver'] = green[0],
    ['bane'] = purple[0],
    ['psykino'] = fg[0],
    ['barrager'] = green[0],
    ['highlander'] = yellow[0],
    ['fairy'] = green[0],
    ['priest'] = green[0],
    ['infestor'] = orange[0],
    ['flagellant'] = fg[0],
    ['arcanist'] = blue2[0],
    ['illusionist'] = blue2[0],
    ['witch'] = purple[0],
    ['silencer'] = blue2[0],
    ['vulcanist'] = red[0],
    ['warden'] = yellow[0],
    ['psychic'] = fg[0],
    ['miner'] = yellow2[0],
    ['merchant'] = yellow2[0],
    ['usurer'] = purple[0],
    ['gambler'] = yellow2[0],
    ['thief'] = red[0],
  }

  character_color_strings = {
    ['vagrant'] = 'fg',
    ['swordsman'] = 'yellow',
    ['wizard'] = 'blue',
    ['magician'] = 'blue',
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
    ['barbarian'] = 'yellow',
    ['juggernaut'] = 'yellow',
    ['lich'] = 'blue',
    ['cryomancer'] = 'blue',
    ['pyromancer'] = 'red',
    ['corruptor'] = 'orange',
    ['beastmaster'] = 'red',
    ['launcher'] = 'yellow',
    ['jester'] = 'red',
    ['assassin'] = 'purple',
    ['host'] = 'orange',
    ['carver'] = 'green',
    ['bane'] = 'purple',
    ['psykino'] = 'fg',
    ['barrager'] = 'green',
    ['highlander'] = 'yellow',
    ['fairy'] = 'green',
    ['priest'] = 'green',
    ['infestor'] = 'orange',
    ['flagellant'] = 'fg',
    ['arcanist'] = 'blue2',
    ['illusionist'] = 'blue2',
    ['witch'] = 'purple',
    ['silencer'] = 'blue2',
    ['vulcanist'] = 'red',
    ['warden'] = 'yellow',
    ['psychic'] = 'fg',
    ['miner'] = 'yellow2',
    ['merchant'] = 'yellow2',
    ['usurer'] = 'purple',
    ['gambler'] = 'yellow2',
    ['thief'] = 'red',
  }

  character_classes = {
    ['vagrant'] = {'psyker', 'ranger', 'warrior'},
    ['swordsman'] = {'warrior'},
    ['wizard'] = {'mage', 'nuker'},
    ['magician'] = {'mage'},
    ['archer'] = {'ranger'},
    ['scout'] = {'rogue'},
    ['cleric'] = {'healer'},
    ['outlaw'] = {'warrior', 'rogue'},
    ['blade'] = {'warrior', 'nuker'},
    ['elementor'] = {'mage', 'nuker'},
    ['saboteur'] = {'rogue', 'conjurer', 'nuker'},
    ['stormweaver'] = {'enchanter'},
    ['sage'] = {'nuker', 'forcer'},
    ['squire'] = {'warrior', 'enchanter'},
    ['cannoneer'] = {'ranger', 'nuker'},
    ['dual_gunner'] = {'ranger', 'rogue'},
    ['hunter'] = {'ranger', 'conjurer', 'forcer'},
    ['chronomancer'] = {'mage', 'enchanter'},
    ['spellblade'] = {'mage', 'rogue'},
    ['psykeeper'] = {'healer', 'psyker'},
    ['engineer'] = {'conjurer'},
    ['plague_doctor'] = {'nuker', 'voider'},
    ['barbarian'] = {'curser', 'warrior'},
    ['juggernaut'] = {'forcer', 'warrior'},
    ['lich'] = {'mage'},
    ['cryomancer'] = {'mage', 'voider'},
    ['pyromancer'] = {'mage', 'nuker', 'voider'},
    ['corruptor'] = {'ranger', 'swarmer'},
    ['beastmaster'] = {'rogue', 'swarmer'},
    ['launcher'] = {'curser', 'forcer'},
    ['jester'] = {'curser', 'rogue'},
    ['assassin'] = {'rogue', 'voider'},
    ['host'] = {'swarmer'},
    ['carver'] = {'conjurer', 'healer'},
    ['bane'] = {'curser', 'voider'},
    ['psykino'] = {'mage', 'psyker', 'forcer'},
    ['barrager'] = {'ranger', 'forcer'},
    ['highlander'] = {'warrior'},
    ['fairy'] = {'enchanter', 'healer'},
    ['priest'] = {'healer'},
    ['infestor'] = {'curser', 'swarmer'},
    ['flagellant'] = {'psyker', 'enchanter'},
    ['arcanist'] = {'sorcerer'},
    ['illusionist'] = {'sorcerer', 'conjurer'},
    ['witch'] = {'sorcerer', 'voider'},
    ['silencer'] = {'sorcerer', 'curser'},
    ['vulcanist'] = {'sorcerer', 'nuker'},
    ['warden'] = {'sorcerer', 'forcer'},
    ['psychic'] = {'sorcerer', 'psyker'},
    ['miner'] = {'mercenary'},
    ['merchant'] = {'mercenary'},
    ['usurer'] = {'curser', 'mercenary', 'voider'},
    ['gambler'] = {'mercenary', 'sorcerer'},
    ['thief'] = {'rogue', 'mercenary'},
  }

  character_class_strings = {
    ['vagrant'] = '[fg]Psyker, [green]Ranger, [yellow]Warrior',
    ['swordsman'] = '[yellow]Warrior',
    ['wizard'] = '[blue]Mage, [red]Nuker',
    ['magician'] = '[blue]Mage',
    ['archer'] = '[green]Ranger',
    ['scout'] = '[red]Rogue',
    ['cleric'] = '[green]Healer',
    ['outlaw'] = '[yellow]Warrior, [red]Rogue',
    ['blade'] = '[yellow]Warrior, [red]Nuker',
    ['elementor'] = '[blue]Mage, [red]Nuker',
    ['saboteur'] = '[red]Rogue, [orange]Conjurer, [red]Nuker',
    ['stormweaver'] = '[blue]Enchanter',
    ['sage'] = '[red]Nuker, [yellow]Forcer',
    ['squire'] = '[yellow]Warrior, [blue]Enchanter',
    ['cannoneer'] = '[green]Ranger, [red]Nuker',
    ['dual_gunner'] = '[green]Ranger, [red]Rogue',
    ['hunter'] = '[green]Ranger, [orange]Conjurer, [yellow]Forcer',
    ['chronomancer'] = '[blue]Mage, Enchanter',
    ['spellblade'] = '[blue]Mage, [red]Rogue',
    ['psykeeper'] = '[green]Healer, [fg]Psyker',
    ['engineer'] = '[orange]Conjurer',
    ['plague_doctor'] = '[red]Nuker, [purple]Voider',
    ['barbarian'] = '[purple]Curser, [yellow]Warrior',
    ['juggernaut'] = '[yellow]Forcer, Warrior',
    ['lich'] = '[blue]Mage',
    ['cryomancer'] = '[blue]Mage, [purple]Voider',
    ['pyromancer'] = '[blue]Mage, [red]Nuker, [purple]Voider',
    ['corruptor'] = '[green]Ranger, [orange]Swarmer',
    ['beastmaster'] = '[red]Rogue, [orange]Swarmer',
    ['launcher'] = '[yellow]Forcer, [purple]Curser',
    ['jester'] = '[purple]Curser, [red]Rogue',
    ['assassin'] = '[red]Rogue, [purple]Voider',
    ['host'] = '[orange]Swarmer',
    ['carver'] = '[orange]Conjurer, [green]Healer',
    ['bane'] = '[purple]Curser, Voider',
    ['psykino'] = '[blue]Mage, [fg]Psyker, [yellow]Forcer',
    ['barrager'] = '[green]Ranger, [yellow]Forcer',
    ['highlander'] = '[yellow]Warrior',
    ['fairy'] = '[blue]Enchanter, [green]Healer',
    ['priest'] = '[green]Healer',
    ['infestor'] = '[purple]Curser, [orange]Swarmer',
    ['flagellant'] = '[fg]Psyker, [blue]Enchanter',
    ['arcanist'] = '[blue2]Sorcerer',
    ['illusionist'] = '[blue2]Sorcerer, [orange]Conjurer',
    ['witch'] = '[blue2]Sorcerer, [purple]Voider',
    ['silencer'] = '[blue2]Sorcerer, [purple]Curser',
    ['vulcanist'] = '[blue2]Sorcerer, [red]Nuker',
    ['warden'] = '[blue2]Sorcerer, [yellow]Forcer',
    ['psychic'] = '[blue2]Sorcerer, [fg]Psyker',
    ['miner'] = '[yellow2]Mercenary',
    ['merchant'] = '[yellow2]Mercenary',
    ['usurer'] = '[purple]Curser, [yellow2]Mercenary, [purple]Curser',
    ['gambler'] = '[yellow2]Mercenary, [blue2]Sorcerer',
    ['thief'] = '[red]Rogue, [yellow2]Mercenary',
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
      math.round(get_character_stat('swordsman', lvl, 'dmg')*0.15, 2) .. '[fg] damage per unit hit' end,
    ['wizard'] = function(lvl) return '[fg]shoots a projectile that deals [yellow]' .. get_character_stat('wizard', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['magician'] = function(lvl) return '[fg]creates a small area that deals [yellow]' .. get_character_stat('magician', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['archer'] = function(lvl) return '[fg]shoots an arrow that deals [yellow]' .. get_character_stat('archer', lvl, 'dmg') .. '[fg] damage and pierces' end,
    ['scout'] = function(lvl) return '[fg]throws a knife that deals [yellow]' .. get_character_stat('scout', lvl, 'dmg') .. '[fg] damage and chains [yellow]3[fg] times' end,
    ['cleric'] = function(lvl) return '[fg]heals a unit for [yellow]20%[fg] of its max hp when it drops below [yellow]50%[fg] max hp' end,
    ['outlaw'] = function(lvl) return '[fg]throws a fan of [yellow]5[fg] knives, each dealing [yellow]' .. get_character_stat('outlaw', lvl, 'dmg') .. '[fg] damage' end,
    ['blade'] = function(lvl) return '[fg]throws multiple blades that deal [yellow]' .. get_character_stat('blade', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['elementor'] = function(lvl) return '[fg]deals [yellow]' .. get_character_stat('elementor', lvl, 'dmg') .. ' AoE[fg] damage in a large area centered on a random target' end,
    ['saboteur'] = function(lvl) return '[fg]calls [yellow]2[fg] saboteurs to seek targets and deal [yellow]' .. get_character_stat('saboteur', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['stormweaver'] = function(lvl) return '[fg]infuses projectiles with chain lightning that deals [yellow]20%[fg] damage to [yellow]2[fg] enemies' end,
    ['sage'] = function(lvl) return '[fg]shoots a slow projectile that draws enemies in' end,
    ['squire'] = function(lvl) return '[yellow]+20%[fg] damage and defense to all allies' end, 
    ['cannoneer'] = function(lvl) return '[fg]shoots a projectile that deals [yellow]' .. 2*get_character_stat('cannoneer', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['dual_gunner'] = function(lvl) return '[fg]shoots two parallel projectiles, each dealing [yellow]' .. get_character_stat('dual_gunner', lvl, 'dmg') .. '[fg] damage' end,
    ['hunter'] = function(lvl) return '[fg]shoots an arrow that deals [yellow]' .. get_character_stat('hunter', lvl, 'dmg') .. '[fg] damage and has a [yellow]20%[fg] chance to summon a pet' end,
    ['chronomancer'] = function(lvl) return '[yellow]+20%[fg] attack speed to all allies' end,
    ['spellblade'] = function(lvl) return '[fg]throws knives that deal [yellow]' .. get_character_stat('spellblade', lvl, 'dmg') .. '[fg] damage, pierce and spiral outwards' end,
    ['psykeeper'] = function(lvl) return '[fg]all damage taken is stored up to [yellow]50%[fg] max HP and distributed as healing to all allies' end,
    ['engineer'] = function(lvl) return '[fg]drops sentries that shoot bursts of projectiles, each dealing [yellow]' .. get_character_stat('engineer', lvl, 'dmg') .. '[fg] damage' end,
    ['plague_doctor'] = function(lvl) return '[fg]creates an area that deals [yellow]' .. get_character_stat('plague_doctor', lvl, 'dmg') .. '[fg] damage per second' end,
    ['barbarian'] = function(lvl) return '[fg]deals [yellow]' .. get_character_stat('barbarian', lvl, 'dmg') .. '[fg] AoE damage and stuns enemies hit for [yellow]4[fg] seconds' end,
    ['juggernaut'] = function(lvl) return '[fg]deals [yellow]' .. get_character_stat('juggernaut', lvl, 'dmg') .. '[fg] AoE damage and pushes enemies away with a strong force' end,
    ['lich'] = function(lvl) return '[fg]launches a slow projectile that jumps [yellow]7[fg] times, dealing [yellow]' ..  2*get_character_stat('lich', lvl, 'dmg') .. '[fg] damage per hit' end,
    ['cryomancer'] = function(lvl) return '[fg]nearby enemies take [yellow]' .. get_character_stat('cryomancer', lvl, 'dmg') .. '[fg] damage per second' end,
    ['pyromancer'] = function(lvl) return '[fg]nearby enemies take [yellow]' .. get_character_stat('pyromancer', lvl, 'dmg') .. '[fg] damage per second' end,
    ['corruptor'] = function(lvl) return '[fg]spawn [yellow]3[fg] small critters if the corruptor kills an enemy' end,
    ['beastmaster'] = function(lvl) return '[fg]spawn [yellow]2[fg] small critters if the beastmaster crits' end,
    ['launcher'] = function(lvl) return '[fg]all nearby enemies are pushed after [yellow]4[fg] seconds, taking [yellow]' .. 2*get_character_stat('launcher', lvl, 'dmg') .. '[fg] damage on wall hit' end,
    ['jester'] = function(lvl) return "[fg]curses [yellow]6[fg] nearby enemies for [yellow]6[fg] seconds, they will explode into [yellow]3[fg] knives on death" end,
    ['assassin'] = function(lvl) return '[fg]throws a piercing knife that deals [yellow]' .. get_character_stat('assassin', lvl, 'dmg') .. '[fg] damage + [yellow]' ..
      get_character_stat('assassin', lvl, 'dmg')/2 .. '[fg] damage per second' end,
    ['host'] = function(lvl) return '[fg]periodically spawn [yellow]1[fg] small critter' end,
    ['carver'] = function(lvl) return '[fg]carves a statue that periodically heals [yellow]1[fg] unit for [yellow]20%[fg] max HP if in range' end,
    ['bane'] = function(lvl) return '[fg]curses [yellow]6[fg] nearby enemies for [yellow]6[fg] seconds, they will create small void rifts on death' end,
    ['psykino'] = function(lvl) return '[fg]pulls enemies together for [yellow]2[fg] seconds' end,
    ['barrager'] = function(lvl) return '[fg]shoots a barrage of [yellow]3[fg] arrows, each dealing [yellow]' .. get_character_stat('barrager', lvl, 'dmg') .. '[fg] damage and pushing enemies' end,
    ['highlander'] = function(lvl) return '[fg]deals [yellow]' .. 5*get_character_stat('highlander', lvl, 'dmg') .. '[fg] AoE damage' end,
    ['fairy'] = function(lvl) return '[fg]periodically heals [yellow]1[fg] unit at random and grants it [yellow]+100%[fg] attack speed for [yellow]6[fg] seconds' end,
    ['priest'] = function(lvl) return '[fg]heals all allies for [yellow]20%[fg] their max HP' end,
    ['infestor'] = function(lvl) return '[fg]curses [yellow]8[fg] nearby enemies for [yellow]6[fg] seconds, they will release [yellow]2[fg] critters on death' end,
    ['flagellant'] = function(lvl) return '[fg]deals [yellow]' .. 2*get_character_stat('flagellant', lvl, 'dmg') .. '[fg] damage to self and grants [yellow]+4%[fg] damage to all allies per cast' end,
    ['arcanist'] = function(lvl) return '[fg]launches a slow moving orb that launches projectiles, each dealing [yellow]' .. get_character_stat('arcanist', lvl, 'dmg') .. '[fg] damage' end,
    ['illusionist'] = function(lvl) return '[fg]launches a projectile that deals [yellow]' .. get_character_stat('illusionist', lvl, 'dmg') .. '[fg] damage and creates copies that do the same' end,
    ['witch'] = function(lvl) return '[fg]creates an area that ricochets around the arena and deals [yellow]' .. get_character_stat('witch', lvl, 'dmg') .. '[fg] damage per second' end,
    ['silencer'] = function(lvl) return '[fg]curses [yellow]5[fg] nearby enemies for [yellow]6[fg] seconds, preventing them from using special attacks' end,
    ['vulcanist'] = function(lvl) return '[fg]creates a volcano that explodes the nearby area [yellow]4[fg] times, dealing [yellow]' .. get_character_stat('vulcanist', lvl, 'dmg') .. ' AoE [fg]damage' end,
    ['warden'] = function(lvl) return '[fg]creates a force field around a random unit that prevents enemies from entering' end,
    ['psychic'] = function(lvl) return '[fg]creates a small area that deals [yellow]' .. get_character_stat('psychic', lvl, 'dmg') .. ' AoE[fg] damage' end,
    ['miner'] = function(lvl) return '[fg]picking up gold releases [yellow]4[fg] homing projectiles that each deal [yellow]' .. get_character_stat('miner', lvl, 'dmg') .. ' [fg]damage' end,
    ['merchant'] = function(lvl) return '[fg]gain [yellow]+1[fg] interest for every [yellow]10[fg] gold' end,
    ['usurer'] = function(lvl) return '[fg]curses [yellow]3[fg] nearby enemies indefinitely with [yellow]debt[fg], dealing [yellow]' .. get_character_stat('usurer', lvl, 'dmg') .. '[fg] damage per second' end,
    ['gambler'] = function(lvl) return '[fg]deal [yellow]2X[fg] damage to a single random enemy where X is how much gold you have' end,
    ['thief'] = function(lvl) return '[fg]throws a knife that deals [yellow]' .. 2*get_character_stat('thief', lvl, 'dmg') .. '[fg] damage and chains [yellow]5[fg] times' end,
  }

  character_effect_names = {
    ['vagrant'] = '[fg]Champion',
    ['swordsman'] = '[yellow]Cleave',
    ['wizard'] = '[blue]Magic Missile',
    ['magician'] = '[blue]Ethereal Form',
    ['archer'] = '[green]Bounce Shot',
    ['scout'] = '[red]Dagger Resonance',
    ['cleric'] = '[green]Mass Heal ',
    ['outlaw'] = '[red]Flying Daggers',
    ['blade'] = '[yellow]Blade Resonance',
    ['elementor'] = '[blue]Windfield',
    ['saboteur'] = '[orange]Demoman',
    ['stormweaver'] = '[blue]Wide Lightning',
    ['sage'] = '[purple]Dimension Compression',
    ['squire'] = '[yellow]Shiny Gear',
    ['cannoneer'] = '[orange]Cannon Barrage',
    ['dual_gunner'] = '[green]Gun Kata',
    ['hunter'] = '[green]Feral Pack',
    ['chronomancer'] = '[blue]Quicken',
    ['spellblade'] = '[blue]Spiralism',
    ['psykeeper'] = '[fg]Crucio',
    ['engineer'] = '[orange]Upgrade!!!',
    ['plague_doctor'] = '[purple]Black Death Steam',
    ['barbarian'] = '[yellow]Seism',
    ['juggernaut'] = '[yellow]Brutal Impact',
    ['lich'] = '[blue]Chain Frost',
    ['cryomancer'] = '[blue]Frostbite',
    ['pyromancer'] = '[red]Ignite',
    ['corruptor'] = '[orange]Corruption',
    ['beastmaster'] = '[red]Call of the Wild',
    ['launcher'] = '[orange]Kineticism',
    ['jester'] = "[red]Pandemonium",
    ['assassin'] = '[purple]Toxic Delivery',
    ['host'] = '[orange]Invasion',
    ['carver'] = '[green]World Tree',
    ['bane'] = '[purple]Nightmare',
    ['psykino'] = '[fg]Magnetic Force',
    ['barrager'] = '[green]Barrage',
    ['highlander'] = '[yellow]Moulinet',
    ['fairy'] = '[green]Whimsy',
    ['priest'] = '[green]Divine Intervention',
    ['infestor'] = '[orange]Infestation',
    ['flagellant'] = '[red]Zealotry',
    ['arcanist'] = '[blue2]Arcane Orb',
    ['illusionist'] = '[blue2]Mirror Image',
    ['witch'] = '[purple]Death Pool',
    ['silencer'] = '[blue2]Arcane Curse',
    ['vulcanist'] = '[red]Lava Burst',
    ['warden'] = '[yellow]Magnetic Field',
    ['psychic'] = '[fg]Mental Strike',
    ['miner'] = '[yellow2]Golden Bolts',
    ['merchant'] = '[yellow2]Item Shop',
    ['usurer'] = '[purple]Bankruptcy',
    ['gambler'] = '[yellow2]Multicast',
    ['thief'] = '[red]Ultrakill',
  }

  character_effect_names_gray = {
    ['vagrant'] = '[light_bg]Champion',
    ['swordsman'] = '[light_bg]Cleave',
    ['wizard'] = '[light_bg]Magic Missile',
    ['magician'] = '[light_bg]Ethereal Form',
    ['archer'] = '[light_bg]Bounce Shot',
    ['scout'] = '[light_bg]Dagger Resonance',
    ['cleric'] = '[light_bg]Mass Heal ',
    ['outlaw'] = '[light_bg]Flying Daggers',
    ['blade'] = '[light_bg]Blade Resonance',
    ['elementor'] = '[light_bg]Windfield',
    ['saboteur'] = '[light_bg]Demoman',
    ['stormweaver'] = '[light_bg]Wide Lightning',
    ['sage'] = '[light_bg]Dimension Compression',
    ['squire'] = '[light_bg]Shiny Gear',
    ['cannoneer'] = '[light_bg]Cannon Barrage',
    ['dual_gunner'] = '[light_bg]Gun Kata',
    ['hunter'] = '[light_bg]Feral Pack',
    ['chronomancer'] = '[light_bg]Quicken',
    ['spellblade'] = '[light_bg]Spiralism',
    ['psykeeper'] = '[light_bg]Crucio',
    ['engineer'] = '[light_bg]Upgrade!!!',
    ['plague_doctor'] = '[light_bg]Black Death Steam',
    ['barbarian'] = '[light_bg]Seism',
    ['juggernaut'] = '[light_bg]Brutal Impact',
    ['lich'] = '[light_bg]Chain Frost',
    ['cryomancer'] = '[light_bg]Frostbite',
    ['pyromancer'] = '[light_bg]Ignite',
    ['corruptor'] = '[light_bg]Corruption',
    ['beastmaster'] = '[light_bg]Call of the Wild',
    ['launcher'] = '[light_bg]Kineticism',
    ['jester'] = "[light_bg]Pandemonium",
    ['assassin'] = '[light_bg]Toxic Delivery',
    ['host'] = '[light_bg]Invasion',
    ['carver'] = '[light_bg]World Tree',
    ['bane'] = '[light_bg]Nightmare',
    ['psykino'] = '[light_bg]Magnetic Force',
    ['barrager'] = '[light_bg]Barrage',
    ['highlander'] = '[light_bg]Moulinet',
    ['fairy'] = '[light_bg]Whimsy',
    ['priest'] = '[light_bg]Divine Intervention',
    ['infestor'] = '[light_bg]Infestation',
    ['flagellant'] = '[light_bg]Zealotry',
    ['arcanist'] = '[light_bg]Arcane Orb',
    ['illusionist'] = '[light_bg]Mirror Image',
    ['witch'] = '[light_bg]Death Pool',
    ['silencer'] = '[light_bg]Arcane Curse',
    ['vulcanist'] = '[light_bg]Lava Burst',
    ['warden'] = '[light_bg]Magnetic Field',
    ['psychic'] = '[light_bg]Mental Strike',
    ['miner'] = '[light_bg]Golden Bolts',
    ['merchant'] = '[light_bg]Item Shop',
    ['usurer'] = '[light_bg]Bankruptcy',
    ['gambler'] = '[light_bg]Multicast',
    ['thief'] = '[light_bg]Ultrakill',
  }

  character_effect_descriptions = {
    ['vagrant'] = function() return '[yellow]+10%[fg] damage and [yellow]+10%[fg] attack speed per active set' end,
    ['swordsman'] = function() return "[fg]the swordsman's damage is [yellow]doubled" end,
    ['wizard'] = function() return '[fg]the projectile chains [yellow]2[fg] times' end,
    ['magician'] = function() return '[fg]the magician becomes invulnerable for [yellow]6[fg] seconds but also cannot attack' end,
    ['archer'] = function() return '[fg]the arrow ricochets off walls [yellow]3[fg] times' end,
    ['scout'] = function() return '[yellow]+25%[fg] damage per chain and [yellow]+3[fg] chains' end,
    ['cleric'] = function() return '[fg]heals all units' end,
    ['outlaw'] = function() return "[yellow]+50%[fg] outlaw attack speed and his knives seek enemies" end,
    ['blade'] = function() return '[fg]deal additional [yellow]' .. math.round(get_character_stat('blade', 3, 'dmg')/3, 2) .. '[fg] damage per enemy hit' end,
    ['elementor'] = function() return '[fg]slows enemies by [yellow]60%[fg] for [yellow]6[fg] seconds on hit' end,
    ['saboteur'] = function() return '[fg]the explosion has [yellow]50%[fg] chance to crit, increasing in size and dealing [yellow]2x[fg] damage' end,
    ['stormweaver'] = function() return "[fg]chain lightning's trigger area of effect and number of units hit is [yellow]doubled" end,
    ['sage'] = function() return '[fg]when the projectile expires deal [yellow]' .. 3*get_character_stat('sage', 3, 'dmg') .. '[fg] damage to all enemies under its influence' end,
    ['squire'] = function() return '[yellow]+30%[fg] damage, attack speed, movement speed and defense to all allies' end,
    ['cannoneer'] = function() return '[fg]showers the hit area in [yellow]7[fg] additional cannon shots that deal [yellow]' .. get_character_stat('cannoneer', 3, 'dmg')/2 .. '[fg] AoE damage' end,
    ['dual_gunner'] = function() return '[fg]every 5th attack shoot in rapid succession for [yellow]2[fg] seconds' end,
    ['hunter'] = function() return '[fg]summons [yellow]3[fg] pets and the pets ricochet off walls once' end,
    ['chronomancer'] = function() return '[fg]enemies take damave over time [yellow]50%[fg] faster' end,
    ['spellblade'] = function() return '[fg]faster projectile speed and tighter turns' end,
    ['psykeeper'] = function() return '[fg]also redistributes damage taken as damage to all enemies at [yellow]double[fg] value' end,
    ['engineer'] = function() return '[fg]drops [yellow]2[fg] additional turrets and grants all turrets [yellow]+50%[fg] damage and attack speed' end,
    ['plague_doctor'] = function() return '[fg]nearby enemies take an additional [yellow]' .. get_character_stat('plague_doctor', 3, 'dmg') .. '[fg] damage per second' end,
    ['barbarian'] = function() return '[fg]stunned enemies also take [yellow]100%[fg] increased damage' end,
    ['juggernaut'] = function() return '[fg]enemies pushed by the juggernaut take [yellow]' .. 4*get_character_stat('juggernaut', 3, 'dmg') .. '[fg] damage if they hit a wall' end,
    ['lich'] = function() return '[fg]chain frost slows enemies hit by [yellow]80%[fg] for [yellow]2[fg] seconds and chains [yellow]+7[fg] times' end,
    ['cryomancer'] = function() return '[fg]enemies are also slowed by [yellow]60%[fg] while in the area' end,
    ['pyromancer'] = function() return '[fg]enemies killed by the pyromancer explode, dealing [yellow]' .. get_character_stat('pyromancer', 3, 'dmg') .. '[fg] AoE damage' end,
    ['corruptor'] = function() return '[fg]spawn [yellow]3[fg] small critters if the corruptor hits an enemy' end,
    ['beastmaster'] = function() return '[fg]spawn [yellow]2[fg] small critters if the beastmaster gets hit' end,
    ['launcher'] = function() return '[fg]enemies launched take [yellow]300%[fg] more damage when they hit walls' end,
    ['jester'] = function() return '[fg]all knives seek enemies and pierce [yellow]2[fg] times' end,
    ['assassin'] = function() return '[fg]poison inflicted from crits deals [yellow]8x[fg] damage' end,
    ['host'] = function() return '[fg][yellow]+100%[fg] critter spawn rate and spawn [yellow]2[fg] critters instead' end,
    ['carver'] = function() return '[fg]carves a tree that heals [yellow]twice[fg] as fast, in a bigger area, and heals [yellow]2[fg] units instead' end,
    ['bane'] = function() return "[yellow]100%[fg] increased area for bane's void rifts" end,
    ['psykino'] = function() return '[fg]enemies take [yellow]' .. 4*get_character_stat('psykino', 3, 'dmg') .. '[fg] damage and are pushed away when the area expires' end,
    ['barrager'] = function() return '[fg]every 3rd attack the barrage shoots [yellow]15[fg] projectiles and they push harder' end,
    ['highlander'] = function() return '[fg]quickly repeats the attack [yellow]3[fg] times' end,
    ['fairy'] = function() return '[fg]heals [yellow]2[fg] units instead and grants them an additional [yellow]100%[fg] attack speed' end,
    ['priest'] = function() return '[fg]picks [yellow]3[fg] units at random and grants them a buff that prevents death once' end,
    ['infestor'] = function() return '[fg][yellow]triples[fg] the number of critters released' end,
    ['flagellant'] = function() return '[fg]deals [yellow]' .. 2*get_character_stat('flagellant', 3, 'dmg') .. '[fg] damage to all allies and grants [yellow]+12%[fg] damage to all allies per cast' end,
    ['arcanist'] = function() return '[yellow]+50%[fg] attack speed for the orb and [yellow]2[fg] projectiles are released per cast' end,
    ['illusionist'] = function() return '[yellow]doubles[fg] the number of copies created and they release [yellow]12[fg] projectiles on death' end,
    ['witch'] = function() return '[fg]the area periodically releases projectiles, each dealing [yellow]' .. get_character_stat('witch', 3, 'dmg') .. '[fg] damage and chaining once' end,
    ['silencer'] = function() return '[fg]the curse also deals [yellow]' .. get_character_stat('silencer', 3, 'dmg') .. '[fg] damage per second' end,
    ['vulcanist'] = function() return '[fg]the number and speed of explosions is [yellow]doubled[fg]' end,
    ['warden'] = function() return '[fg]creates the force field around [yellow]2[fg] units' end,
    ['psychic'] = function() return '[fg]the attack can happen from any distance and repeats once' end,
    ['miner'] = function() return '[fg]release [yellow]8[fg] homing projectiles instead and they pierce twice' end,
    ['merchant'] = function() return '[fg]your first item reroll is always free' end,
    ['usurer'] = function() return '[fg]if the same enemy is cursed [yellow]3[fg] times it takes [yellow]' .. 10*get_character_stat('usurer', 3, 'dmg') .. '[fg] damage' end,
    ['gambler'] = function() return '[yellow]60/40/20%[fg] chance to cast the attack [yellow]2/3/4[fg] times' end,
    ['thief'] = function() return '[fg]if the knife crits it deals [yellow]' .. 10*get_character_stat('thief', 3, 'dmg') .. '[fg] damage, chains [yellow]10[fg] times and grants [yellow]1[fg] gold' end,
  }

  character_effect_descriptions_gray = {
    ['vagrant'] = function() return '[light_bg]+10% damage and +10% attack speed per active set' end,
    ['swordsman'] = function() return "[light_bg]the swordsman's damage is doubled" end,
    ['wizard'] = function() return '[light_bg]the projectile chains 3 times' end,
    ['magician'] = function() return '[light_bg]the magician becomes invulnerable for 6 seconds but also cannot attack' end,
    ['archer'] = function() return '[light_bg]the arrow ricochets off walls 3 times' end,
    ['scout'] = function() return '[light_bg]+25% damage per chain and +3 chains' end,
    ['cleric'] = function() return '[light_bg]heals all units' end,
    ['outlaw'] = function() return "[light_bg]+50% outlaw attack speed and his knives seek enemies" end,
    ['blade'] = function() return '[light_bg]deal additional ' .. math.round(get_character_stat('blade', 3, 'dmg')/2, 2) .. ' damage per enemy hit' end,
    ['elementor'] = function() return '[light_bg]slows enemies by 60% for 6 seconds on hit' end,
    ['saboteur'] = function() return '[light_bg]the explosion has 50% chance to crit, increasing in size and dealing 2x damage' end,
    ['stormweaver'] = function() return "[light_bg]chain lightning's trigger area of effect and number of units hit is doubled" end,
    ['sage'] = function() return '[light_bg]when the projectile expires deal ' .. 3*get_character_stat('sage', 3, 'dmg') .. ' damage to all enemies under its influence' end,
    ['squire'] = function() return '[light_bg]+30% damage, attack speed, movement speed and defense to all allies' end,
    ['cannoneer'] = function() return '[light_bg]showers the hit area in 7 additional cannon shots that deal ' .. get_character_stat('cannoneer', 3, 'dmg')/2 .. ' AoE damage' end,
    ['dual_gunner'] = function() return '[light_bg]every 5th attack shoot in rapid succession for 2 seconds' end,
    ['hunter'] = function() return '[light_bg]summons 3 pets and the pets ricochet off walls once' end,
    ['chronomancer'] = function() return '[light_bg]enemies take damave over time 50% faster' end,
    ['spellblade'] = function() return '[light_bg]faster projectile speed and tighter turns' end,
    ['psykeeper'] = function() return '[light_bg]also redistributes damage taken as damage to all enemies at double value' end,
    ['engineer'] = function() return '[light_bg]drops 2 additional turrets and grants all turrets +50% damage and attack speed' end,
    ['plague_doctor'] = function() return '[light_bg]nearby enemies take an additional ' .. get_character_stat('plague_doctor', 3, 'dmg') .. ' damage per second' end,
    ['barbarian'] = function() return '[light_bg]stunned enemies also take 100% increased damage' end,
    ['juggernaut'] = function() return '[light_bg]enemies pushed by the juggernaut take ' .. 4*get_character_stat('juggernaut', 3, 'dmg') .. ' damage if they hit a wall' end,
    ['lich'] = function() return '[light_bg]chain frost slows enemies hit by 80% for 2 seconds and chains +7 times' end,
    ['cryomancer'] = function() return '[light_bg]enemies are also slowed by 60% while in the area' end,
    ['pyromancer'] = function() return '[light_bg]enemies killed by the pyromancer explode, dealing ' .. get_character_stat('pyromancer', 3, 'dmg') .. ' AoE damage' end,
    ['corruptor'] = function() return '[light_bg]spawn 3 small critters if the corruptor hits an enemy' end,
    ['beastmaster'] = function() return '[light_bg]spawn 2 small critters if the beastmaster gets hit' end,
    ['launcher'] = function() return '[light_bg]enemies launched take 300% more damage when they hit walls' end,
    ['jester'] = function() return '[light_bg]curses 6 enemies and all knives seek enemies and pierce 2 times' end,
    ['assassin'] = function() return '[light_bg]poison inflicted from crits deals 8x damage' end,
    ['host'] = function() return '[light_bg]+100% critter spawn rate and spawn 2 critters instead' end,
    ['carver'] = function() return '[light_bg]carves a tree that heals twice as fast, in a bigger area, and heals 2 units instead' end,
    ['bane'] = function() return "[light_bg]100% increased area for bane's void rifts" end,
    ['psykino'] = function() return '[light_bg]enemies take ' .. 4*get_character_stat('psykino', 3, 'dmg') .. ' damage and are pushed away when the area expires' end,
    ['barrager'] = function() return '[light_bg]every 3rd attack the barrage shoots 15 projectiles and they push harder' end,
    ['highlander'] = function() return '[light_bg]quickly repeats the attack 3 times' end,
    ['fairy'] = function() return '[light_bg]heals 2 units instead and grants them an additional 100% attack speed' end,
    ['priest'] = function() return '[light_bg]picks 3 units at random and grants them a buff that prevents death once' end,
    ['infestor'] = function() return '[light_bg]triples the number of critters released' end,
    ['flagellant'] = function() return '[light_bg]deals ' .. 2*get_character_stat('flagellant', 3, 'dmg') .. ' damage to all allies and grants +12% damage to all allies per cast' end,
    ['arcanist'] = function() return '[light_bg]+50% attack speed for the orb and 2 projectiles are released per cast' end,
    ['illusionist'] = function() return '[light_bg]doubles the number of copies created and they release 12 projectiles on death' end,
    ['witch'] = function() return '[light_bg]the area periodically releases projectiles, each dealing ' .. get_character_stat('witch', 3, 'dmg') .. ' damage and chaining once' end,
    ['silencer'] = function() return '[light_bg]the curse also deals ' .. get_character_stat('silencer', 3, 'dmg') .. ' damage per second' end,
    ['vulcanist'] = function() return '[light_bg]the number and speed of explosions is doubled' end,
    ['warden'] = function() return '[light_bg]creates the force field around 2 units' end,
    ['psychic'] = function() return '[light_bg]the attack can happen from any distance and repeats once' end,
    ['miner'] = function() return '[light_bg]release 8 homing projectiles instead and they pierce twice' end,
    ['merchant'] = function() return '[light_bg]your first item reroll is always free' end,
    ['usurer'] = function() return '[light_bg]if the same enemy is cursed 3 times it takes ' .. 10*get_character_stat('usurer', 3, 'dmg') .. ' damage' end,
    ['gambler'] = function() return '[light_bg]60/40/20% chance to cast the attack 2/3/4 times' end,
    ['thief'] = function() return '[light_bg]if the coin crits it deals ' .. 10*get_character_stat('thief', 3, 'dmg') .. ' damage, chains 10 times and grants 1 gold' end,
  }

  character_stats = {
    ['vagrant'] = function(lvl) return get_character_stat_string('vagrant', lvl) end,
    ['swordsman'] = function(lvl) return get_character_stat_string('swordsman', lvl) end, 
    ['wizard'] = function(lvl) return get_character_stat_string('wizard', lvl) end, 
    ['magician'] = function(lvl) return get_character_stat_string('magician', lvl) end, 
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
    ['barbarian'] = function(lvl) return get_character_stat_string('barbarian', lvl) end,
    ['juggernaut'] = function(lvl) return get_character_stat_string('juggernaut', lvl) end,
    ['lich'] = function(lvl) return get_character_stat_string('lich', lvl) end,
    ['cryomancer'] = function(lvl) return get_character_stat_string('cryomancer', lvl) end,
    ['pyromancer'] = function(lvl) return get_character_stat_string('pyromancer', lvl) end,
    ['corruptor'] = function(lvl) return get_character_stat_string('corruptor', lvl) end,
    ['beastmaster'] = function(lvl) return get_character_stat_string('beastmaster', lvl) end,
    ['launcher'] = function(lvl) return get_character_stat_string('launcher', lvl) end,
    ['jester'] = function(lvl) return get_character_stat_string('jester', lvl) end,
    ['assassin'] = function(lvl) return get_character_stat_string('assassin', lvl) end,
    ['host'] = function(lvl) return get_character_stat_string('host', lvl) end,
    ['carver'] = function(lvl) return get_character_stat_string('carver', lvl) end,
    ['bane'] = function(lvl) return get_character_stat_string('bane', lvl) end,
    ['psykino'] = function(lvl) return get_character_stat_string('psykino', lvl) end,
    ['barrager'] = function(lvl) return get_character_stat_string('barrager', lvl) end,
    ['highlander'] = function(lvl) return get_character_stat_string('highlander', lvl) end,
    ['fairy'] = function(lvl) return get_character_stat_string('fairy', lvl) end,
    ['priest'] = function(lvl) return get_character_stat_string('priest', lvl) end,
    ['infestor'] = function(lvl) return get_character_stat_string('infestor', lvl) end,
    ['flagellant'] = function(lvl) return get_character_stat_string('flagellant', lvl) end,
    ['arcanist'] = function(lvl) return get_character_stat_string('arcanist', lvl) end,
    ['illusionist'] = function(lvl) return get_character_stat_string('illusionist', lvl) end,
    ['witch'] = function(lvl) return get_character_stat_string('witch', lvl) end,
    ['silencer'] = function(lvl) return get_character_stat_string('silencer', lvl) end,
    ['vulcanist'] = function(lvl) return get_character_stat_string('vulcanist', lvl) end,
    ['warden'] = function(lvl) return get_character_stat_string('warden', lvl) end,
    ['psychic'] = function(lvl) return get_character_stat_string('psychic', lvl) end,
    ['miner'] = function(lvl) return get_character_stat_string('miner', lvl) end,
    ['merchant'] = function(lvl) return get_character_stat_string('merchant', lvl) end,
    ['usurer'] = function(lvl) return get_character_stat_string('usurer', lvl) end,
    ['gambler'] = function(lvl) return get_character_stat_string('gambler', lvl) end,
    ['thief'] = function(lvl) return get_character_stat_string('thief', lvl) end,
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
    ['curser'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 0.75, mvspd = 1},
    ['forcer'] = {hp = 1.25, dmg = 1.1, aspd = 0.9, area_dmg = 0.75, area_size = 0.75, def = 1.2, mvspd = 1},
    ['swarmer'] = {hp = 1.2, dmg = 1, aspd = 1.25, area_dmg = 1, area_size = 1, def = 0.75, mvspd = 0.75},
    ['voider'] = {hp = 0.75, dmg = 1.3, aspd = 1, area_dmg = 0.8, area_size = 0.75, def = 0.6, mvspd = 0.8},
    ['sorcerer'] = {hp = 0.8, dmg = 1.3, aspd = 1, area_dmg = 1.2, area_size = 1, def = 0.8, mvspd = 1},
    ['mercenary'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 1},
    ['seeker'] = {hp = 0.5, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 0.3},
    ['mini_boss'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 0.3},
    ['enemy_critter'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 0.5},
    ['saboteur'] = {hp = 1, dmg = 1, aspd = 1, area_dmg = 1, area_size = 1, def = 1, mvspd = 1.4},
  }

  local ylb1 = function(lvl)
    if lvl == 3 then return 'fg'
    elseif lvl == 2 then return 'fg'
    elseif lvl == 1 then return 'yellow'
    else return 'light_bg' end
  end
  local ylb2 = function(lvl)
    if lvl == 3 then return 'fg'
    elseif lvl == 2 then return 'yellow'
    else return 'light_bg' end
  end
  local ylb3 = function(lvl)
    if lvl == 3 then return 'yellow'
    else return 'light_bg' end
  end
  class_descriptions = {
    ['ranger'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']8%[' .. ylb2(lvl) .. ']/16% [fg]chance to release a barrage on attack to allied rangers' end,
    ['warrior'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']+25[' .. ylb2(lvl) .. ']/+50 [fg]defense to allied warriors' end,
    ['mage'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']-15[' .. ylb2(lvl) .. ']/-30 [fg]enemy defense' end,
    ['rogue'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']15%[' .. ylb2(lvl) .. ']/30% [fg]chance to crit to allied rogues, dealing [yellow]4x[] damage' end,
    ['healer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+30% [fg]healing effectiveness' end,
    ['enchanter'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+25% [fg]damage to all allies' end,
    ['nuker'] = function(lvl) return '[' .. ylb1(lvl) .. ']3[' .. ylb2(lvl) .. ']/6 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+25% [fg]area damage and size to allied nukers' end,
    ['conjurer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+25%[' .. ylb2(lvl) .. ']/+50% [fg]summon damage and duration' end,
    ['psyker'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+10%[' .. ylb2(lvl) .. ']/+20% [fg]damage and attack speed per active set to allied psykers' end,
    ['curser'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+25%[' .. ylb2(lvl) .. ']/+50% [fg]curse duration' end,
    ['forcer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+25%[' .. ylb2(lvl) .. ']/+50% [fg]knockback force to all allies' end,
    ['swarmer'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+1[' .. ylb2(lvl) .. ']/+3 [fg]hits to critters' end,
    ['voider'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+15%[' .. ylb2(lvl) .. ']/+25% [fg]damage over time to allied voiders' end,
    ['sorcerer'] = function(lvl) 
      return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4[' .. ylb3(lvl) .. ']/6 [fg]- sorcerers repeat their attacks once every [' .. ylb1(lvl) .. ']4/[' .. ylb2(lvl) .. ']3/[' .. ylb3(lvl) .. ']2[fg] attacks'
    end,
    ['mercenary'] = function(lvl) return '[' .. ylb1(lvl) .. ']2[' .. ylb2(lvl) .. ']/4 [fg]- [' .. ylb1(lvl) .. ']+10%[' .. ylb2(lvl) .. ']/+20% [fg]chance for enemies to drop gold on death' end,
  }

  tier_to_characters = {
    [1] = {'vagrant', 'swordsman', 'magician', 'archer', 'scout', 'cleric', 'arcanist', 'miner'},
    [2] = {'wizard', 'saboteur', 'sage', 'squire', 'dual_gunner', 'hunter', 'chronomancer', 'barbarian', 'cryomancer', 'beastmaster', 'launcher', 'jester', 'carver', 'psychic', 'witch', 'silencer', 'outlaw', 'merchant'},
    [3] = {'elementor', 'stormweaver', 'spellblade', 'psykeeper', 'engineer', 'juggernaut', 'pyromancer', 'host', 'assassin', 'bane', 'barrager', 'infestor', 'flagellant', 'illusionist', 'usurer', 'gambler'},
    [4] = {'priest', 'highlander', 'psykino', 'fairy', 'blade', 'plague_doctor', 'cannoneer', 'vulcanist', 'warden', 'corruptor', 'thief'},
  }

  non_attacking_characters = {'cleric', 'stormweaver', 'squire', 'chronomancer', 'sage', 'psykeeper', 'bane', 'carver', 'fairy', 'priest', 'flagellant', 'merchant', 'miner'}
  non_cooldown_characters = {'squire', 'chronomancer', 'psykeeper', 'merchant', 'miner'}

  character_tiers = {
    ['vagrant'] = 1,
    ['swordsman'] = 1,
    ['magician'] = 1,
    ['archer'] = 1,
    ['scout'] = 1,
    ['cleric'] = 1,
    ['outlaw'] = 2,
    ['blade'] = 4,
    ['elementor'] = 3,
    ['saboteur'] = 2,
    ['wizard'] = 2,
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
    ['barbarian'] = 2,
    ['juggernaut'] = 3,
    -- ['lich'] = 4,
    ['cryomancer'] = 2,
    ['pyromancer'] = 3,
    ['corruptor'] = 4,
    ['beastmaster'] = 2,
    ['launcher'] = 2,
    ['jester'] = 2,
    ['assassin'] = 3,
    ['host'] = 3,
    ['carver'] = 2,
    ['bane'] = 3,
    ['psykino'] = 4,
    ['barrager'] = 3,
    ['highlander'] = 4,
    ['fairy'] = 4,
    ['priest'] = 4,
    ['infestor'] = 3,
    ['flagellant'] = 3,
    ['arcanist'] = 1,
    ['illusionist'] = 3,
    ['witch'] = 2,
    ['silencer'] = 2,
    ['vulcanist'] = 4,
    ['warden'] = 4,
    ['psychic'] = 2,
    ['miner'] = 1,
    ['merchant'] = 2,
    ['usurer'] = 3,
    ['gambler'] = 3,
    ['thief'] = 4,
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
    local cursers = 0
    local forcers = 0
    local swarmers = 0
    local voiders = 0
    local sorcerers = 0
    local mercenaries = 0
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
        if unit_class == 'curser' then cursers = cursers + 1 end
        if unit_class == 'forcer' then forcers = forcers + 1 end
        if unit_class == 'swarmer' then swarmers = swarmers + 1 end
        if unit_class == 'voider' then voiders = voiders + 1 end
        if unit_class == 'sorcerer' then sorcerers = sorcerers + 1 end
        if unit_class == 'mercenary' then mercenaries = mercenaries + 1 end
      end
    end
    return {ranger = rangers, warrior = warriors, healer = healers, mage = mages, nuker = nukers, conjurer = conjurers, rogue = rogues,
      enchanter = enchanters, psyker = psykers, curser = cursers, forcer = forcers, swarmer = swarmers, voider = voiders, sorcerer = sorcerers, mercenary = mercenaries}
  end

  get_class_levels = function(units)
    local units_per_class = get_number_of_units_per_class(units)
    local units_to_class_level = function(number_of_units, class)
      if class == 'ranger' or class == 'warrior' or class == 'mage' or class == 'nuker' or class == 'rogue' then
        if number_of_units >= 6 then return 2
        elseif number_of_units >= 3 then return 1
        else return 0 end
      elseif class == 'healer' or class == 'conjurer' or class == 'enchanter' or class == 'psyker' or class == 'curser' or class == 'forcer' or class == 'swarmer' or class == 'voider' or class == 'mercenary' then
        if number_of_units >= 4 then return 2
        elseif number_of_units >= 2 then return 1
        else return 0 end
      elseif class == 'sorcerer' then
        if number_of_units >= 6 then return 3
        elseif number_of_units >= 4 then return 2
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
      curser = units_to_class_level(units_per_class.curser, 'curser'),
      forcer = units_to_class_level(units_per_class.forcer, 'forcer'),
      swarmer = units_to_class_level(units_per_class.swarmer, 'swarmer'),
      voider = units_to_class_level(units_per_class.voider, 'voider'),
      sorcerer = units_to_class_level(units_per_class.sorcerer, 'sorcerer'),
      mercenary = units_to_class_level(units_per_class.mercenary, 'mercenary'),
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
    ['ranger'] = function(units) return 3, 6, nil, get_number_of_units_per_class(units).ranger end,
    ['warrior'] = function(units) return 3, 6, nil, get_number_of_units_per_class(units).warrior end,
    ['mage'] = function(units) return 3, 6, nil, get_number_of_units_per_class(units).mage end,
    ['nuker'] = function(units) return 3, 6, nil, get_number_of_units_per_class(units).nuker end,
    ['rogue'] = function(units) return 3, 6, nil, get_number_of_units_per_class(units).rogue end,
    ['healer'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).healer end,
    ['conjurer'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).conjurer end,
    ['enchanter'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).enchanter end,
    ['psyker'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).psyker end,
    ['curser'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).curser end,
    ['forcer'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).forcer end,
    ['swarmer'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).swarmer end,
    ['voider'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).voider end,
    ['sorcerer'] = function(units) return 2, 4, 6, get_number_of_units_per_class(units).sorcerer end,
    ['mercenary'] = function(units) return 2, 4, nil, get_number_of_units_per_class(units).mercenary end,
  }

  passive_names = {
    ['ouroboros_technique_r'] = 'Ouroboros Technique R',
    ['ouroboros_technique_l'] = 'Ouroboros Technique L',
    ['wall_echo'] = 'Wall Echo',
    ['wall_rider'] = 'Wall Rider',
    ['centipede'] = 'Centipede',
    ['intimidation'] = 'Intimidation',
    ['vulnerability'] = 'Vulnerability',
    ['temporal_chains'] = 'Temporal Chains',
    ['amplify'] = 'Amplify',
    ['amplify_x'] = 'Amplify X',
    ['resonance'] = 'Resonance',
    ['ballista'] = 'Ballista',
    ['ballista_x'] = 'Ballista X',
    ['point_blank'] = 'Point Blank',
    ['longshot'] = 'Longshot',
    ['blunt_arrow'] = 'Blunt Arrow',
    ['explosive_arrow'] = 'Explosive Arrow',
    ['divine_machine_arrow'] = 'Divine Machine Arrow',
    ['chronomancy'] = 'Chronomancy',
    ['awakening'] = 'Awakening',
    ['divine_punishment'] = 'Divine Punishment',
    ['berserking'] = 'Berserking',
    ['unwavering_stance'] = 'Unwavering Stance',
    ['ultimatum'] = 'Ultimatum',
    ['flying_daggers'] = 'Flying Daggers',
    ['assassination'] = 'Assassination',
    ['magnify'] = 'Magnify',
    ['echo_barrage'] = 'Echo Barrage',
    ['unleash'] = 'Unleash',
    ['reinforce'] = 'Reinforce',
    ['payback'] = 'Payback',
    ['blessing'] = 'Blessing',
    ['hex_master'] = 'Hex Master',
    ['whispers_of_doom'] = 'Whispers of Doom',
    ['force_push'] = 'Force Push',
    ['heavy_impact'] = 'Heavy Impact',
    ['crucio'] = 'Crucio',
    ['immolation'] = 'Immolation',
    ['call_of_the_void'] = 'Call of the Void',
    ['spawning_pool'] = 'Spawning Pool',
    ['hive'] = 'Hive',
    ['void_rift'] = 'Void Rift',
  }

  passive_descriptions = {
    ['ouroboros_technique_r'] = '[fg]rotating around yourself to the right makes units release projectiles',
    ['ouroboros_technique_l'] = '[fg]rotating around yourself to the left grants [yellow]+25%[fg] defense to all units',
    ['wall_echo'] = '[fg]hitting walls has a [yellow]34%[fg] chance of releasing [yellow]2[fg] projectiles',
    ['wall_rider'] = '[fg]hitting walls grants a [yellow]25%[fg] movement speed buff to your snake for [yellow]1[fg] second',
    ['centipede'] = '[yellow]+20%[fg] movement speed',
    ['intimidation'] = '[fg]enemies spawn with [yellow]-20%[fg] max HP',
    ['vulnerability'] = '[fg]all enemies take [yellow]+20%[fg] damage',
    ['temporal_chains'] = '[fg]all enemies move [yellow]20%[fg] slower',
    ['amplify'] = '[yellow]+25%[fg] AoE damage',
    ['amplify_x'] = '[yellow]+50%[fg] AoE damage',
    ['resonance'] = '[fg]all AoE attacks deal [yellow]+5%[fg] damage per unit hit',
    ['ballista'] = '[yellow]+25%[fg] damage to rangers and rogues ',
    ['ballista_x'] = '[yellow]+50%[fg] damage to rangers and rogues',
    ['point_blank'] = '[fg]projectiles deal up to [yellow]+100%[fg] damage up close and down to [yellow]-50%[fg] damage far away',
    ['longshot'] = '[fg]projectiles deal up to [yellow]+100%[fg] damage far away and down to [yellow]-50%[fg] up close',
    ['blunt_arrow'] = '[fg]all arrows fired by rangers have a [yellow]20%[fg] chance to knockback',
    ['explosive_arrow'] = '[fg]arrows fired by rangers have a [yellow]30%[fg] chance to explode, dealing [yellow]20%[fg] AoE damage',
    ['divine_machine_arrow'] = '[fg]arrows fired by rangers have a [yellow]40%[fg] chance to seek enemies and pierce [yellow]4[fg] times',
    ['chronomancy'] = '[fg]all mages cast their spells [yellow]25%[fg] faster',
    ['awakening'] = '[fg]every round [yellow]1[fg] mage is granted [yellow]+100%[fg] attack speed and damage for that round',
    ['divine_punishment'] = '[fg]periodically deal [yellow]10X[fg] damage to all enemies, where [yellow]X[fg] is how many mages you have',
    ['berserking'] = '[fg]all warriors have up to [yellow]+50%[fg] attack speed based on missing HP',
    ['unwavering_stance'] = '[fg]all warriors gain [yellow]+5%[fg] defense every [yellow]5[fg] seconds',
    ['ultimatum'] = '[fg]projectiles that chain gain [yellow]+25%[fg] damage with each chain',
    ['flying_daggers'] = '[fg]all knives thrown by rogues chain [yellow]+2[fg] times',
    ['assassination'] = '[fg]crits from rogues deal [yellow]8x[fg] damage but normal attacks deal [yellow]half[fg] damage',
    ['magnify'] = '[yellow]+25%[fg] area size',
    ['echo_barrage'] = '[yellow]20%[fg] chance to create [yellow]3[fg] secondary AoEs on AoE hit',
    ['unleash'] = '[yellow]+1%[fg] area size and damage per second',
    ['reinforce'] = '[yellow]+10%[fg] damage, defense and attack speed to all allies with at least one enchanter',
    ['payback'] = '[yellow]+5%[fg] damage to all allies whenever an enchanter is hit',
    ['blessing'] = '[yellow]+20%[fg] healing effectiveness',
    ['hex_master'] = '[yellow]+25%[fg] curse duration',
    ['whispers_of_doom'] = '[fg]curses apply doom, when [yellow]4[fg] doom instances are reached they deal [yellow]200[fg] damage',
    ['force_push'] = '[yellow]+25%[fg] knockback force',
    ['heavy_impact'] = '[fg]when enemies hit walls they take damage according to the knockback force',
    ['crucio'] = '[fg]taking damage also shares that across all enemies at [yellow]25%[fg] its value',
    ['immolation'] = '[yellow]3[fg] units will periodically take damage, all your allies gain [yellow]+8%[fg] damage per tick',
    ['call_of_the_void'] = '[yellow]+25%[fg] damage over time',
    ['spawning_pool'] = '[yellow]+1[fg] critter health',
    ['hive'] = '[yellow]+2[fg] critter health',
    ['void_rift'] = '[fg]attacks by mages, nukers or voiders have a [yellow]20%[fg] chance to create a void rift on hit',
  }

  passive_tiers = {
    ['ouroboros_technique_r'] = 2,
    ['ouroboros_technique_l'] = 2,
    ['wall_echo'] = 1,
    ['wall_rider'] = 1,
    ['centipede'] = 1,
    ['intimidation'] = 2,
    ['vulnerability'] = 2,
    ['temporal_chains'] = 1,
    ['amplify'] = 1,
    ['amplify_x'] = 2,
    ['resonance'] = 3,
    ['ballista'] = 1,
    ['ballista_x'] = 2,
    ['point_blank'] = 2,
    ['longshot'] = 2,
    ['blunt_arrow'] = 1,
    ['explosive_arrow'] = 2,
    ['divine_machine_arrow'] = 3,
    ['chronomancy'] = 2,
    ['awakening'] = 2,
    ['divine_punishment'] = 3,
    ['berserking'] = 1,
    ['unwavering_stance'] = 1,
    ['ultimatum'] = 2,
    ['flying_daggers'] = 3,
    ['assassination'] = 1,
    ['magnify'] = 1,
    ['echo_barrage'] = 2,
    ['unleash'] = 1,
    ['reinforce'] = 2,
    ['payback'] = 2,
    ['blessing'] = 1,
    ['hex_master'] = 1,
    ['whispers_of_doom'] = 2,
    ['force_push'] = 1,
    ['heavy_impact'] = 2,
    ['crucio'] = 3,
    ['immolation'] = 2,
    ['call_of_the_void'] = 2,
    ['spawning_pool'] = 1,
    ['hive'] = 3,
    ['void_rift'] = 3,
  }

  tier_to_passives = {
    [1] = {'wall_echo', 'wall_rider', 'centipede', 'temporal_chains', 'amplify', 'amplify_x', 'ballista', 'ballista_x', 'blunt_arrow', 'berserking', 'unwavering_stance', 'assassination', 'unleash', 'blessing',
      'hex_master', 'force_push', 'spawning_pool'},
    [2] = {'ouroboros_technique_r', 'ouroboros_technique_l', 'intimidation', 'vulnerability', 'resonance', 'point_blank', 'longshot', 'explosive_arrow', 'chronomancy', 'awakening', 'ultimatum', 'echo_barrage',
      'reinforce', 'payback', 'whispers_of_doom', 'heavy_impact', 'immolation', 'call_of_the_void'},
    [3] = {'divine_machine_arrow', 'divine_punishment', 'flying_daggers', 'crucio', 'hive', 'void_rift'},
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
    [12] = {40, 30, 20, 10},
    [13] = {35, 30, 25, 10},
    [14] = {30, 30, 25, 15},
    [15] = {25, 30, 30, 15},
    [16] = {25, 25, 30, 20},
    [17] = {20, 25, 35, 20},
    [18] = {15, 25, 35, 25},
    [19] = {10, 25, 40, 25},
    [20] = {5, 25, 40, 30},
    [21] = {0, 25, 40, 35},
    [22] = {0, 20, 40, 40},
    [23] = {0, 20, 35, 45},
    [24] = {0, 10, 30, 60},
    [25] = {0, 0, 0, 100},
  }

  level_to_gold_gained = {
    [1] = {2, 2},
    [2] = {2, 2},
    [3] = {4, 6},
    [4] = {3, 5},
    [5] = {4, 7},
    [6] = {6, 10},
    [7] = {10, 14}, 
    [8] = {12, 16},
    [9] = {14, 18},
    [10] = {10, 14},
    [11] = {12, 16},
    [12] = {20, 24},
    [13] = {12, 16},
    [14] = {14, 18},
    [15] = {16, 20},
    [16] = {12, 12},
    [17] = {12, 12},
    [18] = {20, 24}, 
    [19] = {8, 12},
    [20] = {10, 14}, 
    [21] = {20, 28},
    [22] = {32, 32},
    [23] = {36, 36},
    [24] = {48, 48},
    [25] = {100, 100},
  }

  level_to_passive_tier_weights = {
    [3] = {70, 20, 10},
    [6] = {60, 25, 15},
    [9] = {50, 30, 20},
    [12] = {40, 40, 20},
    [15] = {30, 45, 25},
    [18] = {20, 50, 30},
    [21] = {20, 40, 40},
    [24] = {20, 30, 50},
  }

  level_to_elite_spawn_weights = {
    [1] = {0},
    [2] = {4, 2},
    [3] = {10},
    [4] = {4, 4},
    [5] = {4, 3, 2},
    [6] = {12},
    [7] = {5, 3, 2},
    [8] = {6, 3, 3, 3},
    [9] = {14},
    [10] = {8, 4},
    [11] = {8, 6, 2},
    [12] = {16},
    [13] = {8, 8},
    [14] = {12, 6},
    [15] = {18},
    [16] = {10, 6, 4},
    [17] = {6, 5, 4, 3},
    [18] = {18},
    [19] = {10, 6},
    [20] = {10, 6, 2},
    [21] = {28},
    [22] = {10, 10, 5},
    [23] = {20, 5, 5},
    [24] = {35},
    [25] = {5, 5, 5, 5, 5, 5},
  }

  level_to_boss = {
    [6] = 'speed_booster',
    [12] = 'exploder',
    [18] = 'swarmer',
    [24] = 'forcer',
    [25] = 'randomizer',
  }

  level_to_elite_spawn_types = {
    [1] = {'speed_booster'},
    [2] = {'speed_booster', 'shooter'},
    [3] = {'speed_booster'},
    [4] = {'speed_booster', 'exploder'},
    [5] = {'speed_booster', 'exploder', 'shooter'},
    [6] = {'speed_booster'},
    [7] = {'speed_booster', 'exploder', 'headbutter'},
    [8] = {'speed_booster', 'exploder', 'headbutter', 'shooter'},
    [9] = {'shooter'},
    [10] = {'exploder', 'headbutter'},
    [11] = {'exploder', 'headbutter', 'tank'},
    [12] = {'exploder'},
    [13] = {'speed_booster', 'shooter'},
    [14] = {'speed_booster', 'spawner'},
    [15] = {'shooter'},
    [16] = {'speed_booster', 'exploder', 'spawner'},
    [17] = {'speed_booster', 'exploder', 'spawner', 'shooter'},
    [18] = {'spawner'},
    [19] = {'headbutter', 'tank'},
    [20] = {'speed_booster', 'tank', 'spawner'},
    [21] = {'headbutter'},
    [22] = {'speed_booster', 'headbutter', 'tank'},
    [23] = {'headbutter', 'tank', 'shooter'},
    [24] = {'tank'},
    [25] = {'speed_booster', 'exploder', 'headbutter', 'tank', 'shooter', 'spawner'},
  }

  get_shop_odds_by_level = function(lvl)
    if lvl == 1 then
      return {70, 20, 10, 0}
    elseif lvl == 2 then
      return {50, 30, 15, 5}
    elseif lvl == 3 then
      return {30, 40, 20, 10}
    elseif lvl == 4 then
      return {20, 25, 35, 20}
    end
  end

  get_shop_odds = function(lvl, tier)
    if lvl == 1 then
      if tier == 1 then
        return 70
      elseif tier == 2 then
        return 20
      elseif tier == 3 then
        return 10
      elseif tier == 4 then
        return 0
      end
    elseif lvl == 2 then
      if tier == 1 then
        return 50
      elseif tier == 2 then
        return 30
      elseif tier == 3 then
        return 15
      elseif tier == 4 then
        return 5
      end
    elseif lvl == 3 then
      if tier == 1 then
        return 30
      elseif tier == 2 then
        return 40
      elseif tier == 3 then
        return 20
      elseif tier == 4 then
        return 10
      end
    elseif lvl == 4 then
      if tier == 1 then
        return 20
      elseif tier == 2 then
        return 25
      elseif tier == 3 then
        return 35
      elseif tier == 4 then
        return 20
      end
    elseif lvl == 5 then
      if tier == 1 then
        return 10
      elseif tier == 2 then
        return 20
      elseif tier == 3 then
        return 25
      elseif tier == 4 then
        return 40
      end
    end
  end

  local run = system.load_run()
  run_passive_pool_by_tiers = run.run_passive_pool_by_tiers or {
    [1] = { 'wall_echo', 'wall_rider', 'centipede', 'temporal_chains', 'amplify', 'amplify_x', 'ballista', 'ballista_x', 'blunt_arrow', 'berserking', 'unwavering_stance', 'assassination', 'unleash', 'blessing',
      'hex_master', 'force_push', 'spawning_pool'}, 
    [2] = {'ouroboros_technique_r', 'ouroboros_technique_l', 'intimidation', 'vulnerability', 'resonance', 'point_blank', 'longshot', 'explosive_arrow', 'chronomancy', 'awakening', 'ultimatum', 'echo_barrage', 
      'reinforce', 'payback', 'whispers_of_doom', 'heavy_impact', 'immolation', 'call_of_the_void'},
    [3] = {'divine_machine_arrow', 'divine_punishment', 'flying_daggers', 'crucio', 'hive', 'void_rift'},
  }
  gold = run.gold or 2
  passives = run.passives or {}
  locked_state = run.locked_state
  steam.userStats.requestCurrentStats()
  new_game_plus = state.new_game_plus or 0
  if not state.new_game_plus then state.new_game_plus = new_game_plus end
  current_new_game_plus = state.current_new_game_plus or new_game_plus
  if not state.current_new_game_plus then state.current_new_game_plus = current_new_game_plus end
  max_units = 7 + current_new_game_plus

  main = Main()

  if run.level and run.level > 0 then
    main_song_instance = _G[random:table{'song1', 'song2', 'song3', 'song4', 'song5'}]:play{volume = 0.5}
  end
  -- main_song_instance = _G[random:table{'song1', 'song2', 'song3', 'song4', 'song5'}]:play{volume = 0.5}

  main:add(BuyScreen'buy_screen')
  main:go_to('buy_screen', run.level or 0, run.units or {}, passives, run.shop_level or 1, run.shop_xp or 0)
  -- main:go_to('buy_screen', 7, run.units or {}, {'unleash'})
  
  --[[
  main:add(Arena'arena')
  main:go_to('arena', 13, {
    {character = 'thief', level = 3},
    {character = 'scout', level = 1},
    {character = 'beastmaster', level = 1},
  }, passives)
  ]]--

  --[[
  main:add(Media'media')
  main:go_to('media')
  ]]--

  trigger:every(2, function()
    if debugging_memory then
      for k, v in pairs(system.type_count()) do
        print(k, v)
      end
      print("-- " .. math.round(tonumber(collectgarbage("count"))/1024, 3) .. "MB --")
      print()
    end
  end)

  --[[
  print(table.tostring(love.graphics.getSupported()))
  print(love.graphics.getRendererInfo())
  local formats = love.graphics.getImageFormats()
  for f, s in pairs(formats) do print(f, tostring(s)) end
  local canvasformats = love.graphics.getCanvasFormats()
  for f, s in pairs(canvasformats) do print(f, tostring(s)) end
  print(table.tostring(love.graphics.getSystemLimits()))
  print(table.tostring(love.graphics.getStats()))
  ]]--
end


function update(dt)
  main:update(dt)

  --[[
  if input.b.pressed then
    -- debugging_memory = not debugging_memory
    for k, v in pairs(system.type_count()) do
      print(k, v)
    end
    print("-- " .. math.round(tonumber(collectgarbage("count"))/1024, 3) .. "MB --")
    print()
  end
  ]]--

  if input.n.pressed then
    if main.current.sfx_button then
      main.current.sfx_button:action()
      main.current.sfx_button.selected = false
    else
      if sfx.volume == 0.5 then
        sfx.volume = 0
        state.volume_muted = true
      elseif sfx.volume == 0 then
        sfx.volume = 0.5
        state.volume_muted = false
      end
    end
  end

  if input.m.pressed then
    if main.current.music_button then
      main.current.music_button:action()
      main.current.music_button.selected = false
    else
      if music.volume == 0.5 then
        state.music_muted = true
        music.volume = 0
      elseif music.volume == 0 then
        music.volume = 0.5
        state.music_muted = false
      end
    end
  end

  if input.k.pressed then
    if sx > 1 and sy > 1 then
      sx, sy = sx - 1, sy - 1
      love.window.setMode(480*sx, 270*sy)
      state.sx, state.sy = sx, sy
      state.fullscreen = false
    end
  end

  if input.l.pressed then
    sx, sy = sx + 1, sy + 1
    love.window.setMode(480*sx, 270*sy)
    state.sx, state.sy = sx, sy
    state.fullscreen = false
  end

  --[[
  if input.f12.pressed then
    steam.userStats.resetAllStats(true)
    steam.userStats.storeStats()
  end
  ]]--
end


function draw()
  shared_draw(function()
    main:draw()
  end)
end


function love.run()
  return engine_run({
    game_name = 'SNKRX',
    window_width = 480*4,
    window_height = 270*4,
  })
end
