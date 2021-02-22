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
