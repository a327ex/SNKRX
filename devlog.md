# Day 1 - 17/02/21

Ideaguyed the basics of the game's classes and mechanics, and implemented basic movement and setting of all the stats it will have. Here are the initial characters, synergies and stats I want to have:

### Characters

* Vagrant: shoots a projectile at any nearby enemy, medium range
* Scout: throws a knife at any nearby enemy that chains, small range
* Cleric: heals every unit when any one drops below 50% HP
* Swordsman: deals damage in an area around the unit, small range
* Archer: shoots an arrow at any nearby enemy in front of the unit, long range
* Wizard: shoots a projectile at any nearby enemy and deals AoE damage on contact, small range

### Synergies

* Ranger: yellow, buff attack speed
* Warrior: orange, buff attack damage
* Healer: green, buff healing effectiveness
* Mage: blue, debuff enemy defense
* Cycler: purple, buff cycle speed

### Stats

* HP
* Damage
* Attack speed: stacks additively, starts at 1 and capped at minimum 0.125s or +300%
* Defense: if defense >= 0 then dmg_m = 100/(100+defense) else dmg_m = 2-100/(100-defense)
* Cycle speed: stacks additively, starts at 2 and capped at minimum 0.5s or +300%

Perhaps I'm overengineering it already with the stats but I wanna see where this goes. From SHOOTRX it seems like figuring out stats earlier is better than later, and these seem like they have enough flexibility.

# Day 2 - 18/02/21

Went through like 3 small refactors of how I was laying out Unit, Player and Enemy classes and how I wanted enemies to behave.
Settled on just copying enemy behavior 100% from SHOOTRX, which is likely the more correct decision since it saves a lot of time.

Right now basic player and enemy movement works, as well as melee collisions between player and enemy. To do for tomorrow:

* HP bar should be drawn on top of all player units
* Projectiles 
* Areas
* Stats: attack speed, damage, cycle
* One or a few of the characters
* Port over enemy spawn logic from SHOOTRX
* Sounds

# Day 3 - 19/02/21

Managed to get the first 4 items of the previous todo list done. Removed the cycle stat because the way projectiles work (they're autoshot) already feels like a cycle so having that in would feel redundant.
I changed it for area damage + area size stats which feel more fundamental. So currently the synergies are:

* Ranger: yellow, buff attack speed
* Warrior: orange, buff attack damage
* Healer: green, buff healing effectiveness
* Mage: blue, debuff enemy defense
* Void: purple, buff area damage and size

And the stats are:

* HP
* Damage
* Area damage
* Area of effect
* Attack speed
* Defense -> if defense >= 0 then dmg_m = 100/(100+defense) else dmg_m = 2-100/(100-defense)

HP, damage and defense are flat stats, whereas area damage, area of effect and attack speed are multipliers. This is because each character/attack has its own attack speed/area and trying to generalize that
too much wouldn't work well. For tomorrow I'll just try to finish the rest of the todo, which is add more characters, port enemy spawning logic from SHOOTRX and add sounds.

# Day 4 - 20/02/21

Ported over enemy spawning logic and added all characters. The characters currently are:

* Vagrant: shoots an ethereal projectile at any nearby enemy that deals physical and magical damage, medium range
* Scout: throws a knife that chains 3 times at any nearby enemy, small range
* Cleric: heals every unit when any one drops below 50% HP
* Swordsman: deals physical damage in an area around the unit, small range
* Archer: shoots an arrow that pierces at any nearby enemy, very long range
* Wizard: shoots a projectile at any nearby enemy and deals AoE magical damage on contact, small range, AoE has very small range

The classes are:

* Ranger: yellow, buff attack speed
* Warrior: orange, buff attack damage
* Healer: green, buff healing effectiveness
* Mage: blue, debuff enemy defense
* Void: purple, buff area damage and size
* Builder: orange, buffs construct damage, attack speed and duration
* Rogue: red, chance to crit dealing 4x damage

I'm not sure what I should focus on next. I know that there's sounds left to add, but after that I should probably start doing the actual game progression, but for that I think need a bunch more characters.
I should probably try to think of a cast of maybe 15-20 characters (however that number should be as low as possible) that fills up the current classes to their multiple levels. Levels possible are: 1, 2, 3, 2/4, 2/4/6 and 3/6.

# Day 5 - 21/02/21

Sounds done for everything. Surprising to me how much sounds added to the game and helped me sell all the different attacks way better than with just graphics.
I should probably make it a habit to add sounds earlier rather than later from now on.

Tomorrow I should probably ideaguy the full set of characters and classes that I'll need so that the game is playable and start on implementing those additional characters as well as some class bonuses.

# Day 6 - 22/02/21

Ideaguyed the entire roster for the demo and implemented a few of them.

### Classes

| Class | Color | Set Effect |
| --- | --- | --- |
| Ranger | yellow | chance to release a barrage |
| Warrior | orange | increased defense |
| Healer | green | increased healing effectiveness |
| Mage | blue | decreased enemy defense |
| Nuker | purple | increased area damage and size |
| Conjurer | orange | increased construct damage and duration |
| Rogue | red | chance to crit dealing 4x damage |
| Enchanter | pink | increased damage to all allies |
| Psy | white | returns damage taken based on number of active psy units |

### Characters

| Character | Description | Trigger Range | Effect Range |
| --- | --- | --- | --- |
| Vagrant | shoots a projectile | medium | nil |
| Scout | throws a knife that chains 3 times | small | nil |
| Cleric | heals every unit when any one drops below 50% HP | nil | nil |
| Swordsman | deals physical damage in an area around the unit | small | medium |
| Archer | shoots an arrow that pierces | very long | nil |
| Wizard | shoots a projectile that deals AoE damage | long | very small |
| Outlaw | throws a fan of 5 knives | medium | nil |
| Blade | shoots multiple blades that deal AoE damage on contact | small | small |
| Elementor | deals massive AoE damage to a random target | long | medium |
| Ninja | creates clones that roam and shoot shurikens | nil | very small |
| Linker | links nearby enemies together making them share damage taken | medium | small |
| Sage | shoots a slow projectile that draws enemies in | medium | medium |
| Squire | improves damage and defense for adjacent units as well as healing them periodically | nil | nil |
| Cannoneer | shoots a projectile that deals massive AoE damage | long | medium |
| Dual Gunner | shoots two parallel projectiles | medium | nil |
| Hunter | shoots an arrow with a chance to summon a pet | long | small |
| Chronomancer | dramatically improves attack speed for adjacent units | nil | nil |
| Spellblade | knives orbit you and hoam towards nearby enemies | small | small |
| Psykeeper | all damage taken is stored and distributed as healing | nil | nil |
| Gambler | drops a sentry that uses random attacks | nil | medium |

### Character Classes

| Character | Classes |
| --- | --- |
| Vagrant | warrior, ranger, psy |
| Scout | rogue |
| Cleric | healer |
| Swordsman | warrior |
| Archer | ranger |
| Wizard | mage |
| Outlaw | rogue, warrior |
| Blade | warrior, nuker |
| Elementor | mage, nuker |
| Ninja | rogue, conjurer |
| Linker | enchanter, nuker |
| Sage | mage, nuker |
| Squire | warrior, healer, enchanter |
| Cannoneer | ranger, nuker |
| Dual | unner [ranger, rogue |
| Hunter | ranger, conjurer |
| Chronomancer | mage, enchanter |
| Spellblade | mage, rogue |
| Psykeeper | healer, psy |
| Gambler | conjurer |

### Class Numbers

| Class | Set Levels | Total Units |
| --- | --- | --- |
| Ranger | 2, 4 | 5 |
| Warrior | 2, 4 | 5 |
| Healer | 3 | 3 |
| Mage | 2, 4 | 5 |
| Nuker | 2, 4 | 5 |
| Conjurer | 2 | 3 |
| Rogue | 2, 4 | 5 |
| Enchanter | 3 | 3 |
| Psy | n | 2 |

### Class Stat Multipliers

| Class | HP | DMG | ASPD | Area DMG | Area Size | DEF | MVSPD |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Warrior | 1.4 | 1.1 | 0.9 | 1.0 | 1.0 | 1.25 | 0.9 |
| Ranger | 1.0 | 1.2 | 1.5 | 1.0 | 1.0 | 0.9 | 1.2 |
| Healer | 1.2 | 1.0 | 0.5 | 1.0 | 1.0 | 1.2 | 1.0 |
| Mage | 0.6 | 1.4 | 1.0 | 1.25 | 1.25 | 0.75 | 1.0 |
| Rogue | 0.8 | 1.3 | 1.1 | 0.6 | 0.6 | 0.8 | 1.4 |
| Nuker | 0.9 | 1.4 | 0.75 | 1.5 | 1.3 | 1.0 | 1.0 |
| Conjurer | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 |
| Enchanter | 1.2 | 1.0 | 1.0 | 1.0 | 1.0 | 1.2 | 1.2 |
| Psy | 1.5 | 1.0 | 1.0 | 1.0 | 1.0 | 0.5 | 1.0 |

I've implemented up to Elementor today and ATM in the process of doing Ninja, but today seems like a particularly low energy day so I'm just going to play some games instead.
