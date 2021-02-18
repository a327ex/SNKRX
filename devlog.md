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
