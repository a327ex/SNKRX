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
| Vagrant | shoots a projectile | medium |  |
| Scout | throws a knife that chains 3 times | small |  |
| Cleric | heals every unit when any one drops below 50% HP |  |  |
| Swordsman | deals physical damage in an area around the unit | small | medium |
| Archer | shoots an arrow that pierces | very long |  |
| Wizard | shoots a projectile that deals AoE damage | long | very small |
| Outlaw | throws a fan of 5 knives | medium |  |
| Blade | shoots multiple blades that deal AoE damage on contact | small | small |
| Elementor | deals massive AoE damage to a random target | long | medium |
| Ninja | creates clones that roam and shoot shurikens |  | very small |
| Linker | links nearby enemies together making them share damage taken | medium | small |
| Sage | shoots a slow projectile that draws enemies in | medium | medium |
| Squire | improves damage and defense for adjacent units as well as healing them periodically |  |  |
| Cannoneer | shoots a projectile that deals massive AoE damage | long | medium |
| Dual Gunner | shoots two parallel projectiles | medium |  |
| Hunter | shoots an arrow with a chance to summon a pet | long | small |
| Chronomancer | dramatically improves attack speed for adjacent units |  |  |
| Spellblade | knives orbit you and hoam towards nearby enemies | small | small |
| Psykeeper | all damage taken is stored and distributed as healing |  |  |
| Gambler | drops a sentry that uses random attacks |  | medium |

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

# Day 7 - 23/02/21

Not a lot done today... My sleep schedule is fucked up and I've been unable to focus properly. I managed to get 2 characters done though and also changed their definitions a bit:

* Ninja -> Saboteur: calls on other saboteurs to seek targets and explode on contact, AoE has small range
* Ninja -> Saboteur: rogue, conjurer, nuker
* Linker -> Stormweaver: infuses all projetile attacks with chain lightning, medium range
* Linker -> Stormweaver: enchanter, ~~nuker~~

# Day 8-9 - 24-25/02/21

Finished all characters finally. My sleep is so fucked these two days blended together seamlessly. It's so fucking hot and I'm so tired. God damn I fucking hate the summer so fucking much. I hope I can sleep properly today.
Definition changes for one character: Spellblade - knives slowly spiral outwards.

Tomorrow I'll probably do some UI work so the player can buy new characters as he goes from arena to arena, or work on the game's progression in terms of enemy HP and DMG. These are fundamentally the only two things missing
and I have a essentially 1 week to do them, which should be more than enough.

Note: remember to attribute https://freesound.org/people/Hybrid_V/sounds/321215/ for turret_deploy sound in credits.

# Day 10 - 26/02/21

Another day with almost no sleep and just general low energy because of it... I managed to get things done though. I got all the class set bonuses working. Here's what they do:

| Class | Set Numbers | Set Effect |
| --- | --- | --- |
| Ranger | 2/4 | 10/20% chance to release a barrage |
| Warrior | 2/4 | +25/+50 defense |
| Healer | 3 | +25% healing effectiveness |
| Mage | 2/4 | -15/-30 enemy defense |
| Nuker | 2/4 | +15/25% area damage and size |
| Conjurer | 2 | +25% construct damage and duration |
| Rogue | 2/4 | 10/20% chance to crit dealing 4x damage |
| Enchanter | 3 | +25% damage to all allies |

Tomorrow I should get started on going from arena to arena, buying characters and figuring out enemy scaling.

# Day 11 - 27/02/21

Took a break today. Although I went through the game's stats because I noticed some of them were diverging from my internal docs as well as the tables posted to the devlog a few days ago. Here are current tables
based on what's actually in the code:

### Classes

| Class | Set Color | Set Numbers | Total Units | Set Effect |
| --- | --- | --- | --- | --- |
| Ranger | green | 2/4 | 5 | 10/20% chance to release a barrage |
| Warrior | yellow | 2/4 | 5 |+25/+50 ally defense |
| Healer | green | 3 | 3 | +25% healing effectiveness |
| Mage | blue | 2/4 | 5 | -15/-30 enemy defense |
| Nuker | blue | 2/4 | 5 | +15/25% area damage and size |
| Conjurer | yellow | 2 | 3 | +25% construct damage and duration |
| Rogue | red | 2/4 | 5 | 10/20% chance to crit dealing 4x damage |
| Enchanter | red | 3 | 3 | +25% damage to all allies |

### Characters

| Character | Description | Trigger Range | Effect Range |
| --- | --- | --- | --- |
| Vagrant | shoots a projectile | medium |  |
| Swordsman | deals damage in an area around the unit | small | medium |
| Wizard | shoots a projectile that deals AoE damage | big | very small |
| Archer | shoots an arrow that pierces | very big |  |
| Scout | throws a knife that chains 3 times | small |  |
| Cleric | heals every unit when any one drops below 50% HP |  |  |
| Outlaw | throws a fan of 5 knives | medium |  |
| Blade | shoots multiple blades that deal AoE damage on contact | small | small |
| Elementor | deals massive AoE damage to a random target | big | big |
| Saboteur | calls 4 other saboteurs to seek targets and deal AoE damage |  | very small |
| Stormweaver | infuses all allied projectiles with chain lightning | medium | small |
| Sage | shoots a slow projectile that draws enemies in | medium | small |
| Squire | improves damage and defense for adjacent units as well as healing them periodically |  |  |
| Cannoneer | shoots a projectile that deals massive AoE damage | long | medium |
| Dual Gunner | shoots two parallel projectiles | medium |  |
| Hunter | shoots an arrow with a chance to summon a pet | very long | |
| Chronomancer | improves attack speed for adjacent units |  |  |
| Spellblade | knives that pierce spiral outwards | | |
| Psykeeper | all damage taken is stored and distributed as healing to all allies |  |  |
| Engineer | drops sentries that attacks with a burst of projectiles |  | medium |

### Character Classes

| Character | Classes |
| --- | --- |
| Vagrant | warrior, ranger, psy |
| Swordsman | warrior |
| Wizard | mage |
| Archer | ranger |
| Cleric | healer |
| Scout | rogue |
| Outlaw | rogue, warrior |
| Blade | warrior, nuker |
| Elementor | mage, nuker |
| Saboteur | rogue, conjurer, nuker |
| Stormweaver | enchanter |
| Sage | mage, nuker |
| Squire | warrior, healer, enchanter |
| Cannoneer | ranger, nuker |
| Dual Gunner | ranger, rogue |
| Hunter | ranger, conjurer |
| Chronomancer | mage, enchanter |
| Spellblade | mage, rogue |
| Psykeeper | healer, psy |
| Engineer | conjurer |

### Class Stat Multipliers

| Class | HP | DMG | ASPD | Area DMG | Area Size | DEF | MVSPD |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Warrior   | 1.4  | 1.1  | 0.9  | 1    | 1    | 1.25 | 0.9  |
| Ranger    | 1    | 1.2  | 1.5  | 1    | 1    | 0.9  | 1.2  |
| Healer    | 1.2  | 1    | 0.5  | 1    | 1    | 1.20 | 1    |
| Mage      | 0.6  | 1.4  | 1    | 1.25 | 1.2  | 0.75 | 1    |
| Rogue     | 0.8  | 1.3  | 1.1  | 0.6  | 0.6  | 0.8  | 1.4  |
| Nuker     | 0.9  | 1    | 0.75 | 1.5  | 1.3  | 1    | 1    |
| Conjurer  | 1    | 1    | 1    | 1    | 1    | 1    | 1    |
| Enchanter | 1.2  | 1    | 1    | 1    | 1    | 1.2  | 1.2  |
| Psy       | 1.5  | 1    | 1    | 1    | 1    | 0.5  | 1    |
