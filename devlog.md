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

# Day 12-15 - 28/02/21-03/03/21

I didn't work on anything.

# Day 16 - 04/03/21

UI work on the game's first screen. These days that I ended up not doing nothing happened because of a mix of me not knowing what to do next, fixing my sleep schedule (failed, so I give up on this already), and trying
to think up how exactly I want the game's UI to be like. I ended up thinking too much and paralyzed myself into not doing anything.

Right now I'm just doing the most basic thing I can that still looks reasonably OK and conveys all the info needed.

# Day 17 - 05/03/21

More UI stuff. Fairly slow moving but I'm slowly getting a clearer picture in my head of what the game's UI should be like which should make it easier to get it done.

Also found this cool article today: https://halt.software/dead-simple-layouts/. This reminds me of one of my attempts from a few years ago at creating a clean UI abstraction but with a slightly different focus that seems promising.
I wonder if I should try implementing this now or leave it for the next game.

# Day 18 - 06/03/21

Transition from first screen to first level works. Polish it up tomorrow with more sounds, tutorial markers (left/right arrows) and more consistency and anticipation when a level ends, and then start work on the main buy
screen.

# Day 19 - 07/03/21

First screen, transition from it to arena, arena and transition from arena to next screen are 99% complete and polished. There's one small bug left that I can't replicate where it will end the level right away, but I can't tell
with which win condition it's happening... I'll fix it in time. Tomorrow I can get started on the main buy screen for real.

# Day 20-21 - 08-09/03/21

Initial work done on the main buy screen. Fairly slow moving still. There's a sort of conceptual fuzziness that happens when writing UI code where there's a few different ways of doing it and this freedom seems fairly paralyzing.
I've been thinking really hard about what to do about that but it's still up in the air. The "dead simple layouts" thing is a good idea but layouting is not necessarily the main problem I have, it's more like relationships between
different objects and a UI coordination issue that seems to stop me.

# Day 22 - 10/03/21

More UI progress on buy screen.

# Day 23 - 11/03/21

Finished all visual progress on the main buy screen. Now all I have to do is make it all work logically, which is actually a lot easier than making it all work visually. This fact tells me that most of my problems with UI programming
have to do with visuals and not much else. I would wager that most of it has to do with not knowing how the overall UI should look, and the rest is just building each UI component visually in a quick and easy way.

The first problem can be fixed by just trying to draw the UI beforehand, which I never do but maybe I should start doing. The second problem is more involved and essentially it involves writing UI components that are generic enough
like buttons, labels, image buttons, lists, etc, but also allow for enough specialization that I can make them really juicy, as this generally requires a lot of detail fiddling the inner works of the object. I think the Node refactor
I'm planning will probably help with this, especially the idea of everything simply being a Node and classes being able to be defined inline by just defining update/draw/on_enter/etc functions.

# Day 24-25 - 12-13/03/21

Finished buy screen. Now the only two things left is are redoing the first screen to take advantage of all the UI built for the buy screen, balance/progression and then fixing smaller details and finishing everything up.
I can probably finish it all before day 30 which would be great.

# Day 26 - 14/03/21

The game is finally playable from start to finish. It is pretty fun as it is but it's clear that a few things need to be added so it can be even better. I'll add these after I release the demo with the game in the current
state since these additions will take some time and I don't want to delay the demo's release any more than necessary.

#### Enemy Modifiers

Enemies right now feel pretty samey, and a few small modifiers would help a lot:

* Grant nearby enemies a speed boost on death
* Grant nearby enemies a damage boost on death
* Explode into projectiles on death
* Charge up and headbutt towards the player at increased speed and damage
* Immune to knockback

#### Mini Boss

Every 3rd level there should be a difficult increase in the multiplier for enemy stats as well as a mini boss. This mini boss has significantly increased HP and damage and can spawn enemies of his own on top of the ones
spawned by the level. He can also grant modifiers to enemies. Upon completing such a level, the player will be granted the chance to choose 1 out of 3 passive items.

#### Other Ideas

* Show a unit DPS list like Underlord's to the right side of the screen
* About 20-30 passive items that can be collected every 3 levels
* Lv.3 effects for every character
* New classes and characters (I'm not in idea guy mode ATM so I can't think of much, but it will come to me eventually):
  * Trapper: releases +1 trap
    * Plague Doctor [trapper, nuker]: releases an area that deals 6 AoE DoT
    * Fisherman [trapper, warrior]: throws a net that entangles enemies and prevents them from moving

# Day 27 - 15/03/21

Mostly done with balance tuning. Now all that's left are some final details:

* Pausing
* Muting sound/music
* Music + pitch
* Win screen
* W to wishlist
* R to restart
* Allied unit death sound

# Day 28 - 16/03/21

The demo is finally 100% complete. Now tomorrow I'll spend some time recording gameplay and hopefully finishing the trailer. After that I can start working on the steam page.
If I have it done by tomorrow and Valve takes 5 business days to approve the store page I should have everything ready by the 25th. And then I can release the game 14 days after that, which would be the 8th of April.
I definitely want to release it around that time, before the 15th because then I will have completed the game in less than 60 days which is my limit, although I should probably aim for 40 days going forward.

# Week 5 - 17/03/21 to 24/03/21

This latest week I did everything necessary to get the game into a playable state as well as all the work needed for a Steam page. Most of it was spent making the trailer, but I feel like the more trailers I make
the faster I get at making them. This time it took like 3-4 days out of laziness, but I can easily see it being a 1 day job in the future.

I also tested the demo out with a few people and the results were underwhelming. No one seemed to play it for too much time, which I suspected would happen given that the longer term loop of the game isn't in yet.
More interestingly though, all of the feedback I was given about things that needed to be changed were things that I knew needed to be changed/added for the game's release, which means that I have a pretty good idea of where
the game is from other people's perspective.

The web build has a few bugs that I can't fix like sound effects not playing randomly, and since my strategy was doing a web demo coupled with the page's release, I've decided to change it. Both because of these bugs and the
underwhelming response I feel like releasing a demo at this point will damage the game more than help it. I have ~3 weeks until release date (13th of April) from now, and that should be enough to add enough things into the game
to make it significantly better.

Going forward I think the Steam page reveal demo strategy probably isn't a good idea for these 1 month games. They're small enough already as they are and releasing them in an ever more crude state is probably a waste of time.
The only thing I need to schedule better for next releases is my trailer making timing. If I want to release a game in 1 month I need to have a trailer by day 15 at the latest, which means I need to work on the game for 2 weeks
and then take 1 day to make a trailer.

As for feedback given from the demo:

* Enemy spawn points should have some markers before enemy spawns, or should avoid spawning near the player at all
* UI is generally hard to figure out at first, not a problem since it's meant to be played many times :)
  * Confusion between what's being purchased, is it the class or the character or something else
  * GO button is grayed out and thus doesn't say it's meant to be clicked on
  * 28/20 enemies or 4/3 wave confuses players and makes them think the level goals are bugged
  * Hovering over a party member should show which set they belong to and vice-versa
* Music for first 9-15 levels should be calm rather than upbeat
* Prevent spawning of units that don't attack on first level
* Prevent spawning of units that cost 3 on first level
* Not enough variety in units nor enemies so your snake doesn't matter
* Re-ordering of units
* Crash:
  * Error: engine/game/hitfx.lua:46: attempt to index field 'parent'
    * engine/game/hitfx.lua:46: in function 'use' love.js:9:40605
    * enemies.lua:56: in function 'on_collision_enter' love.js:9:40605

# Week 6 - 24/03/21 to 31/03/21

Spent most of this week relaxing and ideaguying the next things I need to do. The reaction to the demo was already underwhelming but the reaction to the game reveal itself from the Internet at large was also fairly underwhelming.
For BYTEPATH it was also like this and the 2 weeks of building wishlists were basically dead and I was only able to gain traction on release day, but for this game it seems even worse. Hopefully by the time release day comes people
will respond better, otherwise this is a big GG and this game will just be played by like 100 people at most.

This also further solidifies my previous thoughts that the 2 weeks delay from steam up to release is best thought of as non-existent. For this game I tried a 2 step process, work on a demo and release that with the game's reveal
and steam page, and then finish the rest of the game after that. But the amount of work needed to do a proper reveal with trailers and playable demo was pretty large, and it didn't really amount to anything. The demo was too unfinished
(and I knew it was) for any feedback to matter, and people just didn't respond at all to the game's reveal.

So a better plan for future games might be to just make a game in 1-2 months, and then spend 1 week or so doing everything needed to put the page up, do it, and then move on to the next game while waiting the 2 weeks before
release is possible. This also works better because it's very hard to switch from marketing mode back to development mode on the same project, whereas switching to a new project while waiting for those 2 weeks is probably
more feasible.

Whatever way it goes, here's my plan for what to do until release:

1. Enemy spawn points should have some markers before enemy spawns, or should avoid spawning near the player at all
2. Prevent spawning of units that cost 3 on first level
3. Prevent spawning of units that don't attack on first level
4. Rework position based units so that position in the snake doesn't matter
  * Chronomancer: +10%/20%/30% attack speed to all allies
  * Psykeeper: stores damage taken by all allies up to 20% max HP and redistributes it as healing
  * Squire: +5%/10%/15% damage and defense to all allies
5. Stat details to each unit when hovering over it in the party section
6. Mini boss every 3rd level
  * This is just a special enemy with more HP and ability to buff nearby enemies with modifiers, no additional AI or attack patterns
  * ... aiming for ~5 different modifier combos that the boss uses
7. Enemy modifiers
  * Grant nearby enemies a speed boost on death
  * Grant nearby enemies a damage boost on death
  * Explode into projectiles on death
  * Charge up and headbutt towards the player at increased speed and damage
  * Resistance to knockback
  * ... aiming for about 8-10 of these
8. Additional characters and classes
9. Lv.3 effects for every character
  * Classes
    * Ranger: chance to release a barrage on attack
    * Warrior: increased defense
    * Mage: decreased enemy defense
    * Nuker: increased area damage and size
    * Rogue: chance to crit
    * Healer: increased healing effectiveness
    * Enchanter: increased damage
    * Conjurer: increased summon damage and duration
    * Psyker: increased damage and health based on number of active sets
    * Trapper: release extra traps
    * Forcer: increased knockback force
    * Swarmer: increased critter health
    * Voider: increased damage over time
  * Characters
    * Vagrant [psyker, ranger, warrior]: shoots a projectile - Lv.3: Champion - gains increased damage and attack speed based on number of active sets
    * Swordsman [warrior]: deals AoE damage, deals extra damage for each unit hit - Lv.3: Cleave - damage is doubled
    * Wizard [mage]: shoots a projectile that deals AoE damage - Lv.3: Magic Missile - the projectile chains 5 times, each dealing AoE damage on impact
    * Archer [ranger]: shoots an arrow that pierces - Lv.3: Bounce Shot - the arrow ricochets on walls 3 times
    * Scout [rogue]: throws a knife that chains 3 times - Lv.3: Replica - each chain grants +15% damage and the last chain splits
    * Cleric [healer]: heals a unit when its health drops below half HP - Lv.3: Mass Heal - heals all units instead of one
    * Outlaw [warrior, rogue]: throws a fan of 5 knives - Lv.3: Fatal Roulette - every 3rd attack throw a nova of 15 knives instead
    * Blade [warrior, nuker]: throws multiple blades that deal AoE damage - Lv.3: Blade Resonance - deal additional damage based on number of enemies hit
    * Elementor [mage, nuker]: deals AoE damage to a random target in a large area - Lv.3: Windfield - slows enemies hit
    * Saboteur [rogue, conjurer, nuker]: calls saboteurs to seek targets and deal AoE damage - Lv.3: Chain Reaction - should an enemy die from a saboteur explosion, it also explodes
    * Stormweaver [enchanter]: infuses all allied projectiles with chain lightning that deals extra damage - Lv.3: Lightning Spire - cast a spire of lightning periodically
    * Sage [nuker]: shoots a slow moving projectile that pulls enemies in - Lv.3: Dimension Compression - when the projectile expires deal massive damage to all enemies under its influence
    * Squire [warrior, enchanter]: increased damage and defense to all allies - Lv.3: Repair - you can reroll your item choice once every 3 levels, these opportunities stack if unused
    * Cannoneer [ranger, nuker]: shoots a projectile that deals AoE damage - Lv.3: Cannon Barrage - showers the hit area in additional cannon shots that deal AoE damage
    * Dual Gunner [ranger, rogue]: shoots two parallel projectiles - Lv.3: Gun Kata - every 5th attack shoots projectiles in a rapid succession for a duration, targetting all nearby enemies
    * Hunter [ranger, conjurer]: shoots an arrow that summons a pet - Lv.3: Feral Pack - summons 3 pets
    * Chronomancer [mage, enchanter]: increased attack speed to all allies - Lv.3: Quicken - enemies take DoT faster
    * Spellblade [mage, rogue]: throws knives that spiral outwards and pierce - Lv.3: Spiralism - faster projectile speed and tighter turns
    * Psykeeper [healer, psyker]: stores damage taken by all allies and redistributes it as healing - Lv.3: Crucio - also redistributes it as damage to all enemies
    * Engineer [conjurer]: drops sentries that shoot bursts of projectils - Lv.3: Upgrade - every 3rd sentry dropped, upgrade all sentries temporarily, giving increased damage and attack speed
    * Plague Doctor [nuker, voider]: creates an area that deals DoT - Lv.3: Pandemic - inflicts enemies with a contagion that deals additional DoT, if they die from it it passes to a nearby enemy
    * Fisherman [trapper, warrior]: throws a net that entangles enemies and prevents them from moving - Lv.3: Electric Net - enemies caught take DoT
    * Juggernaut [forcer, warrior]: creates a small area that deals AoE damage and pushes enemies away - Lv.3: Brutal Impact - enemies pushed away are instantly killed if they hit a wall
    * Lich [mage]: launches a chain frost that chains 7 times, dealing damage and slowing enemies it hits - Lv.3: Piercing Frost - chain frost ignores enemy defenses
    * Cryomancer [mage, voider]: nearby enemies take damage over time and have decreased movement speed - Lv.3: Frostbite - enemies killed by the cryomancer freeze nearby enemies, frozen enemies can't move and take increased damage
    * Pyromancer [mage, nuker, voider]: nearby enemies take damage over time and deal decreased damage - Lv.3: Ignite - enemies killed by the pyromancer explode, dealing AoE damage
    * Corruptor [ranger, swarmer]: spawn 3 small critters if the corruptor kills an enemy - Lv.3: Infestation - spawn 3 small critters if the corruptor hits an enemy
    * Beastmaster [rogue, swarmer]: spawn 2 small critters if the beastmaster crits - Lv.3: Call of the Wild - spawn 2 small critters if the beastmaster gets hit
    * Launcher [trapper, forcer]: creates a trap that launches enemies that trigger it - Lv.3: Kineticism - enemies launched that hit other enemies transfer their kinetic energy
    * Spiker [trapper, rogue]: creates a trap that crits when triggered - Lv.3: Caltrops - slows enemies hit and deals DoT
    * Assassin [rogue, voider]: throws a piercing knife that inflicts poison - Lv.3: Toxic Delivery - poison inflicted from crits deals more damage
    * Host [conjurer, swarmer]: creates overlords that periodically spawn small critters - Lv.3: Invasion - increased critter spawn rate
    * Carver [conjurer, healer]: carves a statue that periodically heals in an area - Lv.3: World Tree - carves a tree that heals in a bigger area and removes all buffs from enemies
    * Bane [swarmer, voider]: spawn a small critter periodically that explodes and deals DoT - Lv.3: Baneling Swarm - spawn 4 banelings instead
    * Psykino [mage, psyker, forcer]: quickly pulls enemies together and then releases them with a force - Lv.3: Magnetic Force - enemies pulled together are forced to collide with each other before being released
    * Arbalester [ranger, forcer]: launches a massive arrow that pushes enemies back, ignoring knockback resistances - Lv.3: Ballista Sinistra - enemies hit by the arrow have massively decreased defense
    * Pirate [warrior, forcer]: launches a hook that captures nearby enemies and pulls them towards you - Lv.3: Jolly Roger - place a flag that grants gold based on number of enemies killed under its effect
    * Sapper [trapper, enchanter, healer]: creates a trap that steals health from enemies that trigger it and grants increased movement speed - Lv.3: when a sapper trap is triggered other nearby traps are triggered
    * Priest [healer]: heals all units periodically - Lv.3: Divine Intervention - at the start of the round pick 3 units at random and grants them a buff that prevents them from dying once
    * Burrower [trapper, swarmer]: creates a trap that contains 6 small critters which are released when triggered - Lv.3: Zergling Rush - triples the number of critters released
    * Flagellant [psyker, enchanter]: periodically deals damage to self and grants a damage buff to all allies - Lv.3: Zealotry - deals damage to all allies instead and also grants a massive damage buff
  * Sets
    * Ranger = 8/8
    * Warrior = 8/8
    * Mage = 8/8
    * Rogue = 8/8
    * Nuker = 7/7
    * Conjurer = 5/5
    * Forcer = 5/5
    * Voider = 5/5
    * Psyker = 4/4
    * Healer = 5/5
    * Enchanter = 5/5
    * Trapper = 5/5
    * Swarmer = 5/5
10. Items
  * Ouroboros Technique R: rotating around yourself to the right makes every unit periodically release projectiles
  * Ouroboros Technique L: rotating around yourself to the left grants +25% defense to all units
  * Resonance: hitting walls has a chance of releasing projectiles
  * Wall Rider: hitting walls grants a speed buff for a small duration
  * Force Push: +25% knockback force
  * Heavy Impact: if knockbacked enemies hit walls they take damage according to the knockback force
  * Centipede: +20% movement speed
  * Intimidation: enemies spawn with -20% max HP
  * Crucio: taking damage shares 2x the amount of HP you lost across all enemies
  * Amplify: all units that deal AoE damage gain +25% AoE damage
  * Amplify X: +25% AoE damage if all your units only deal AoE damage (excluding supports)
  * Ballista: all units that release projectiles and don't deal AoE damage gain +25% damage
  * Ballista X: +25% damage if all your units only release projectiles and don't deal AoE damage (excluding supports)
  * Point Blank: projectiles deal increased damage based on distance not travelled, +100% at 0 distance and -50% at max distance
  * Longshot: projectiles deal increased damage based on distance travelled, -50% at 0 distance and +100% at max distance
  * Chain Reaction: projectiles that chain gain 25% damage with each chain
  * Call of the Void: +25% DoT damage
  * ... more ideas will come later I'm sure, aiming for 30 total items
11. Steam integration: achievements, etc
12. Hovering over a party member should show which set they belong to and vice-versa
13. Show a unit DPS list like Underlord's to the right side of the screen
14. Warriors that deal AoE damage should deal extra damage based on number of enemies hit
15. GO button is grayed out and thus doesn't say it's meant to be clicked on
16. 28/20 enemies or 4/3 wave confuses players and makes them think the level goals are bugged
17. Music for first 9-15 levels should be calm rather than upbeat
18. Crash: Error: engine/game/hitfx.lua:46: attempt to index field 'parent', engine/game/hitfx.lua:46: in function 'use' love.js:9:40605, enemies.lua:56: in function 'on_collision_enter' love.js:9:40605
19. Sage's pull force doesn't increase with unit level
20. Cleric's healing amount doesn't increase with unit level
21. Squire and Chronomancer's buffs don't increase with unit level

## Formatted Class/Character Data

### Character Classes and Descriptions

| Character | Classes | Description | 
| --- | --- | --- |
| Vagrant | psyker, ranger, warrior | shoots a projectile |
| Swordsman | warrior | deals AoE damage and deals extra damage for each unit hit |
| Wizard | mage | shoots a projectile that deals AoE damage |
| Archer | ranger | shoots an arrow that pierces |
| Scout | rogue | throws a knife that chains 3 times |
| Cleric | healer | heals a unit when its health drops below half HP |
| Outlaw | warrior, rogue | throws a fan of 5 knives |
| Blade | warrior, nuker | throws multiple blades that deal AoE damage |
| Elementor | mage, nuker | deals AoE damage in a large area centered on a random target |
| Saboteur | rogue, conjurer, nuker | calls saboteurs to seek targets and deal AoE damage |
| Stormweaver | enchanter | infuses all allied projectiles with chain lightning that deals extra damage |
| Sage | nuker | shoots a slow moving projectile that pulls enemies in |
| Squire | warrior, enchanter | increased damage and defense to all allies |
| Cannoneer | ranger, nuker | shoots a projectile that deals AoE damage |
| Dual Gunner | ranger, rogue | shoots two parallel projectiles |
| Hunter | ranger, conjurer | shoots an arrow that has a chance to summon a pet |
| Chronomancer | mage, enchanter | increased attack speed to all allies |
| Spellblade | mage, rogue | throws knives that spiral outwards and pierce |
| Psykeeper | healer, psyker | stores damage taken by all allies and redistributes it as healing |
| Engineer | conjurer | drops sentries that shoot bursts of projectiles |
| Plague Doctor | nuker, voider | creates an area that deals DoT |
| Fisherman | trapper, warrior | throws a net that entangles enemies and prevents them from moving |
| Juggernaut | forcer, warrior | creates a small area that deals AoE damage and pushes enemies away |
| Lich | mage | launches a chain frost that chains 7 times, dealing damage and slowing enemies it hits |
| Cryomancer | mage, voider | nearby enemies take DoT and have decreased movement speed |
| Pyromancer | mage, nuker, voider | nearby enemies take DoT and deal decreased damage |
| Corruptor | ranger, swarmer | spawn 3 small critters if the corruptor kills an enemy |
| Beastmaster | rogue, swarmer | spawn 2 small critters if the beastmaster crits |
| Launcher | trapper, forcer | creates a trap that launches enemies that trigger it |
| Spiker | trapper, rogue | creates a trap that crits when triggered |
| Assassin | rogue, voider | throws a piercing knife that inflicts poison |
| Host | conjurer, swarmer | creates overlords that periodically spawn small critters |
| Carver | conjurer, healer | carves a statue that periodically heals in an area |
| Bane | swarmer, voider | periodically spawn a small critter that explodes and deals DoT |
| Psykino | mage, psyker, forcer | quickly pulls enemies together and then release them with a force |
| Arbalester | ranger, forcer | launches a massive arrow that pushes enemies back, ignoring knockback resistances |
| Pirate | warrior, forcer | launches a hook that captures nearby enemies and pulls them towards you |
| Sapper | trapper, enchanter, healer | creates a trap that steals health from enemies and grants you increased movement speed |
| Priest | healer | heals all units periodically |
| Burrower | trapper, swarmer | creates a trap that contains 6 small critters |
| Flagellant | psyker, enchanter | periodically deals damage to self and grants a damage buff to all allies |

### Character Lv.3 Effects

| Character | Lv.3 Effect Name | Lv.3 Effect Description |
| --- | --- | --- |
| Vagrant | Champion | gains increased damage and attack speed based on number of active sets |
| Swordsman | Cleave | damage is doubled |
| Wizard | Magic Missile | the projectile chains 5 times, each dealing AoE damge on impact |
| Archer | Bounce Shot | the arrow ricochets off walls 3 times |
| Scout | Replica | each chain grants increased damage and the last chain splits |
| Cleric | Mass Heal | heals all units instead |
| Outlaw | Fatal Roulette | every 3rd attack throws a nova of 15 knives instead |
| Blade | Blade Resonance | deal additional damage based on number of enemies hit |
| Elementor | Windfield | slows enemies hit |
| Saboteur | Chain Reaction | if an enemy dies from a saboteur explosion it also explodes | 
| Stormweaver | Lightning Spire | cast a spire of lightning periodically |
| Sage | Dimension Compression | when the projectile expires deal damage to all enemies under its influence |
| Squire | Repair | you can reroll your item choices once, these opportunities stack if unused |
| Cannoneer | Cannon Barrage | showers the area in additional cannon shots that deal AoE damage |
| Dual Gunner | Gun Kata | every 5th attack shoots projectiles in a rapid succession for a duration targetting all nearby enemies |
| Hunter | Feral Pack | summons 3 pets |
| Chronomancer | Quicken | enemies take DoT faster |
| Spellblade | Spiralism | faster projectile speed and tighter turns |
| Psykeeper | Crucio | also redistributes damage taken as damage to all enemies |
| Engineer | Upgrade | every 3rd sentry dropped, upgrade all sentries, giving increased damage and attack speed |
| Plague Doctor | Pandemic | inflicts enemies with a contagion that deals additional DoT, if they die from it it passes to a nearby enemy |
| Fisherman | Electric Net | enemies caught take DoT |
| Juggernaut | Brutal Impact | enemies pushed away are instantly killed if they hit a wall |
| Lich | Piercing Frost | chain frost ignores enemy defenses |
| Cryomancer | Frostbite | enemies killed by the cryomancer freeze nearby enemies, frozen enemies can't move and take increased damage |
| Pyromancer | Ignite | enemies killed by the pyromancer explode, dealing AoE damage |
| Corruptor | Infestation | spawn 3 small critters if the corruptor hits an enemy |
| Beastmaster | Call of the Wild | spawn 2 small critters if the beastmaster gets hit |
| Launcher | Kineticism | enemies launched that hit other enemies transfer their kinetic energy |
| Spiker | Caltrops | slows enemies hit and deals DoT |
| Assassin | Toxic Delivery | poison inflicted from crits deals more damage |
| Host | Invasion | increased critter spawn rate |
| Carver | World Tree | carves a tree that heals in a bigger are and removes all buffs from enemies |
| Bane | Baneling Swarm | spawn 4 banelings |
| Psykino | Magnetic Force | enemies pulled together are forced to collide with each other multiple times |
| Arbalester | Ballista Sinistra | enemies hit by the arrow have massively decreased defense |
| Pirate | Jolly Roger | place a flag that grants gold based on number of enemies killed under its effect |
| Sapper | Chain Reaction | when a sapper trap is triggered other nearby traps are also triggered |
| Priest | Divine Intervention | at the start of the round pick 3 units at random and grants them a buff that prevents them from dying once |
| Burrower | Zergling Rush | triples the number of critters released |
| Flagellant | Zealotry | deals damage to all allies instead for a massively increased damage buff |

### Classes

| Class | Set Color | Set Numbers | Total Units | Set Effect |
| --- | --- | --- | --- | --- |
| Ranger | green | 3/6 | 8 | +10/20% chance to release a barrage to allied rangers |
| Warrior | yellow | 3/6 | 8 | +25/50 defense to allied warriors |
| Mage | blue | 3/6 | 8 | -15/30 enemy defense |
| Rogue | red | 3/6 | 8 | +10/20% chance to crit to allied rogues, dealing 4x damage |
| Healer | green | 2/4 | 5 | +15/30% healing effectiveness |
| Enchanter | blue/red | 2/4 | 5 | +15/25% damage to all allies |
| Nuker | blue/purple | 3/6 | 7 | +15/25% area damage and size to allied nukers |
| Conjurer | orange | 2/4 | 5 | +25/50% summon damage and duration |
| Psyker | white | 2/4 | 4 | +5/10% damage and health per active set to allied psykers |
| Trapper | orange | 2/4 | 5 | +1/2 extra traps released |
| Forcer | yellow | 2/4 | 5 | +25/50% knockback force to all allies |
| Swarmer | green/purple/orange | 2/4 | 5 | +1/3 health to critters |
| Voider | purple | 2/4 | 5 | +15/25% DoT to allied voiders |

### Class Stat Multipliers

| Class     | HP   | DMG  | ASPD | Area DMG | Area Size | DoT DMG | DEF  | MVSPD |
| ---       | ---  | ---  | ---  | ---      | ---       | ---     | ---  | ---   |
| Ranger    | 1    | 1.2  | 1.5  | 1        | 1         | 1.1     | 0.9  | 1.2   |
| Warrior   | 1.4  | 1.1  | 0.9  | 1        | 1         | 1       | 1.25 | 0.9   |
| Mage      | 0.6  | 1.4  | 1    | 1.25     | 1.2       | 1.25    | 0.75 | 1     |
| Rogue     | 0.8  | 1.3  | 1.1  | 0.6      | 0.6       | 1.4     | 0.8  | 1.4   |
| Healer    | 1.2  | 1    | 0.5  | 1        | 1         | 1       | 1.20 | 1     |
| Enchanter | 1.2  | 1    | 1    | 1        | 1         | 1       | 1.2  | 1.2   |
| Nuker     | 0.9  | 1    | 0.75 | 1.5      | 1.3       | 0.75    | 1    | 1     |
| Conjurer  | 1    | 1    | 1    | 1        | 1         | 1       | 1    | 1     |
| Psyker    | 1.5  | 1    | 1    | 1        | 1         | 1       | 0.5  | 1     |
| Trapper   | 1    | 1    | 1    | 1        | 1         | 1.1     | 0.75 | 1     |
| Forcer    | 1.25 | 1.1  | 0.9  | 0.75     | 0.75      | 1       | 1.2  | 1     |
| Swarmer   | 1.2  | 1    | 1.25 | 1        | 1         | 1       | 0.75 | 0.5   |
| Voider    | 0.75 | 1.3  | 1    | 0.8      | 0.75      | 2       | 0.6  | 0.8   |

# Node Refactor

As I work on this project the inevitable conclusion that I came to in regards to the codebase is that everything can be conceptually simplified if every entity becomes a Node. Before I switch to execution mode for the next month to
finish this game I should take this moment to expand on the refactor that I'll work on right after this project is done.

A node is an object that has a parent and children. Nodes can be added to other nodes and it will form a tree, or a graph, since nodes can also link back to one another arbitrarily. Every object in the game is going to be turned
into a node, which means that everything will start from a root node and be initialize/updated/drawn from there.

```lua
root = Node()
root:append(Node():tag'player')
```

Here a root node is created and a child tagged with the unique identifier `player` attached to it. This means that in the node's `children` list, the first node will be this `player` node.
Each tag should be unique so that we can refer to nodes in the graph by their names, and in this case we would refer to the child node by saying `root.player`.
Similarly, `root.player.parent` automatically is set to refer back to `root`.

This simple setup eliminates the need for different types of container objects, which right now in Anchor are `Group`, `State` and `GameObject`. All of those objects have disparate/repeated ways
of handling updates/draws, when in reality they're all doing the same thing and that similarity should be conceptually reflected at the engine level.

```lua
root:append(Node(Timer, State):tag'arena':init(arena_init):update(arena_update):on_enter(arena_on_enter))
```

The above code shows the main way of adding functionality to a node. Instead of defining new classes for different behaviors I prefer doing everything locally, which means defining the entire class exactly
where the instance is created. In this case, it means passing the expected behaviors as functions. In this case we have `init`, `update` and `on_enter` who expect functions to be defined and passed in, and
for brevity's sake I just passed in the variables `arena_init`, `arena_update` and `arena_on_enter`. In a real use case these would be functions defined here directly instead of variables holding a function.

A Node object expects `init` and `update` by default, but not `on_enter`. This is where the variables being passed in to the `Node()` call come in. The primary way of altering what functions a node expects
to be passed to it will happen through mixins, which are what are being passed to the node at first.

In this case, the `State` mixin changes the node such that it expects an `on_enter` function, which is called whenever the node's `active` variable becomes true (this variable is also controlled by the State mixin).
This is useful for both high level state changes, such as changing between levels, but also for low level ones, such as changing between animation states.
In this example we can see a real use case of how this node system ties everything conceptually together, as we get the same mixin code being used seamlessly for two completely different tasks.

Mixins always will derive from Object and be created according to how classic says they should be. I'll only change it so that name collisions are detected and the program exits. This will be the main way to build
objects and the last thing I need is random bugs because a function or variable from one mixin overwrote the other.

# Day 42 - 30/03/21

Added a spawn marker so that it's easier for the player to tell where enemies are spawning and to give a chance to avoid unfair deaths. Slowly getting back into it now...

# Day 43-44 - 31/03/21-01/04/21

* Added a spawn marker before enemies spawn to help with avoiding enemies spawning on top of the player
* Prevent spawning of units that cost 3 or more gold on the first level
* Prevent spawning of only units that don't attack on the first level
* Reworked position based units so that position in the snake doesn't matter anymore
  * Chronomancer now gives +10/20/30% attack speed to all allies
  * Psykeeper now stores damage taken by all allies up to 10/20/30% its max HP and redistributes it as healing
  * Squire now gives +5/10/15% damage and defense to all allies
* Added enemy modifiers
  * green - Grant nearby enemies a speed boost on death
  * blue - Explode into projectiles on death
  * orange - Charge up and headbutt towards the player at increased speed and damage

# Day 45 - 02/04/21

* Added more enemy modifiers
  * yellow - Resistance to knockback and increased HP
  * white - Remain static and shoot projectiles
  * purple - Explodes into critters on death

# Day 46 - 03/04/21

* Adding mini bosses
  * Speed Booster - grants speed boost to nearby enemies
  * Swarmer - explodes enemies into a swarm of critters
  * Exploder - explodes enemies into projectiles
  * Forcer - pulls enemies together into a point and pushes them out
  * Randomizer - randomly does the 4 ones above

# Day 47-48 - 04-05/04/21

Nothing.

# Day 49 - 06/04/21

Updated all tables with text descriptions as well as stats and overall gameplay numbers for all classes and characters.
Tomorrow I start implementing the remaining 4 classes and 20 characters as well as revising the existing ones.

# Day 50-51 - 07-08/04/21

Nothing... Finding the energy to work on this has been getting harder. I'm sure I'll get to it eventually but for now I've been spending time with some more fun projects.

# Day 52 - 09/04/21

Lots of improvements and fixes to lots of different things that needed improving and fixing. I also started on the implementation of characters and Lv.3 effects. Today I got 10 out of 40 characters done completely:

| Character | Classes | Description | 
| --- | --- | --- |
| Vagrant | psyker, ranger, warrior | shoots a projectile that deals X damage |
| Swordsman | warrior | deals X AoE damage in an area, deals extra X/3 damage per unit hit |
| Wizard | mage | shoots a projectile that deals X AoE damage |
| Archer | ranger | shoots an arrow that deals X damage and pierces |
| Scout | rogue | throws a knife that deals X damage and chains 3 times |
| Cleric | healer | heals a unit for 20% of its max HP when it drops below 50% max HP |
| Outlaw | warrior, rogue | throws a fan of 5 knives, each dealing X damage |
| Blade | warrior, nuker | throws multiple blades that deal X AoE damage |
| Elementor | mage, nuker | deals X AoE damage in a large area centered on a random target |
| Saboteur | rogue, conjurer, nuker | calls 2 saboteurs to seek targets and deal X AoE damage |

| Character | Lv.3 Effect Name | Lv.3 Effect Description |
| --- | --- | --- |
| Vagrant | Champion | +10% damage and +5% attack speed per active set |
| Swordsman | Cleave | the swordsman's damage is doubled |
| Wizard | Magic Missile | the projectile chains 5 times |
| Archer | Bounce Shot | the arrow ricochets off walls 3 times |
| Scout | Dagger Resonance | +25% damage per chain and +3 chains |
| Cleric | Mass Heal | heals all units |
| Outlaw | Flying Daggers | +50% outlaw attack speed and his knives seek enemies |
| Blade | Blade Resonance | deal additional X/2 damage per enemy hit |
| Elementor | Windfield | slows enemies by 60% for 6 seconds on hit |
| Saboteur | Demoman | the explosion has 50% chance to crit, increasing in size and dealing 2X damage |

# Day 53 - 10/04/21

Implemented 11 characters today and was going to do more but spent a lot of time trying to make traps work and I couldn't figure it out. Have to idea guy a mechanic other than traps to fill their spot now...
Either way, 21 out of 40 characters 100% done is still good.

| Character | Classes | Description | 
| --- | --- | --- |
| Stormweaver | enchanter | infuses projectiles with chain lightning that deals 20% damage to 2 enemies |
| Sage | nuker | shoots a slow projectile that pulls enemies in |
| Squire | warrior, enchanter | +15% damage and defense to all allies |
| Cannoneer | ranger, nuker | shoots a projectile that deals 2X AoE damage |
| Dual Gunner | ranger, rogue | shoots two parallel projectiles, each dealing X damage |
| Hunter | ranger, conjurer | shoots an arrow that deals X damage and has a 20% chance to summon a pet |
| Chronomancer | mage, enchanter | +20% attack speed to all allies |
| Spellblade | mage, rogue | throws knives that deal X damage, pierce and spiral outwards |
| Psykeeper | healer, psyker | all damage taken is stored up to 50% max HP and distributed as healing to all allies |
| Engineer | conjurer | drops sentries that shoot bursts of projectiles, each dealing X damage |
| Plague Doctor | nuker, voider | creates an area that deals X damage per second |

| Character | Lv.3 Effect Name | Lv.3 Effect Description |
| --- | --- | --- |
| Stormweaver | Wide Lightning | chain lightning's trigger area of effect and number of units hit is doubled |
| Sage | Dimension Compression | when the projectile expires deal 3X damage to all enemies under its influence |
| Squire | Repair | you can reroll your item choices once, these opportunities stack if unused |
| Cannoneer | Cannon Barrage | showers the area in 5 additional cannon shots that deal X/2 AoE damage |
| Dual Gunner | Gun Kata | every 5th attack shoots in rapid succession for 2 seconds |
| Hunter | Feral Pack | summons 3 pets and the pets ricochet off walls once |
| Chronomancer | Quicken | enemies take damage over time 50% faster |
| Spellblade | Spiralism | faster projectile speed and tighter turns |
| Psykeeper | Crucio | also redistributes damage taken as damage to all enemies at double value |
| Engineer | Upgrade | every 3rd sentry dropped upgrade all sentries with +100% damage and attack speed |
| Plague Doctor | Black Death Steam | nearby enemies take an additional X damage per second |

# Day 54 - 11/04/21

Implemented more 7 units fully. Today was slower because these were all new units that also were the first units for the new 4 classes, so I had to do some more work to get it going. The rest should go faster tomorrow.

| Character | Classes | Description | 
| --- | --- | --- |
| Barbarian | curser, warrior | deals X AoE damage and stuns enemies hit for 4 seconds |
| Juggernaut | forcer, warrior | deals X AoE damage and pushes enemies away with a strong force |
| Lich | mage | launches a slow projectilt that jumps 7 times, dealing 2X damage per hit |
| Cryomancer | mage, voider | nearby enemies take X damage per second |
| Pyromancer | mage, nuker, voider | nearby enemies take X damage per second |
| Corruptor | ranger, swarmer | spawn 3 small critters if the corruptor kills an enemy |
| Beastmaster | rogue, swarmer | spawn 2 small critters if the beastmaster crits |

| Character | Lv.3 Effect Name | Lv.3 Effect Description |
| --- | --- | --- |
| Barbarian | Seism | stunned enemies also take +100% damage |
| Juggernaut | Brutal Impact | enemies pushed by the juggernaut take 4X damage if they hit a wall |
| Lich | Chain Frost | chain frost slows enemies hit by 80% for 2 seconds and chains +7 times |
| Cryomancer | Frostbite | enemies are also slowed by 60% while in the area |
| Pyromancer | Ignite | enemies killed by the pyromancer explode, dealing X AoE damage |
| Corruptor | Corruption | spawn 3 small critters if the corruptor hits an enemy |
| Beastmaster | Call of the Wild | spawn 2 small critters if the beastmaster gets hit |

# Day 55 - 12/04/21

Even slower day today, but I managed to get something done. I'm hoping I can finish the other 9 characters tomorrow but it might go slow too...

| Character | Classes | Description | 
| --- | --- | --- |
| Launcher | forcer, warrior | nearby enemies are pushed after 4 seconds, taking 2X damage on wall hit |
| Bard | curser, rogue | throws a knife that deals X damage and inflicts enemies hit with the bard's curse |
| Assassin | voider, rogue | throws a piercing knife that deals X damage and inflicts poison that deals X/2 damage per second for 3 seconds |
| Host | swarmer | periodically spawn 1 small critter |

| Character | Lv.3 Effect Name | Lv.3 Effect Description |
| --- | --- | --- |
| Launcher | Kineticism | enemies launched take 300% more damage when they hit walls |
| Bard | The Bard's Song | every 8th attack consume the curse to deal 4X damage to affected enemies |
| Assassin | Toxic Delivery | poison inflicted from crits deals 8X damage |
| Host | Invasion | +100% critter spawn rate and spawn 2 critters instead |

# Day 56 - 13/04/21

Still slow... But I got something done :)

| Character | Classes | Description | 
| --- | --- | --- |
| Carver | conjurer, healer | carves a statue that periodically heals 1 unit for 20% max HP if in range |
| Bane | voider, curser | creates a large area that curses enemies to take +50% damage |
| Psykino | mage, psyker, forcer | pulls enemies together for 2 seconds |
| Barrager | ranger, forcer | shoots a barrage of 5 arrows, each dealing X damage and pushing enemies |

| Character | Lv.3 Effect Name | Lv.3 Effect Description |
| --- | --- | --- |
| Carver | World Tree | carves a tree that heals twice as fast, in a bigger area, and heals 2 units instead |
| Bane | Nightmare | the area also deals X damage per second and slows enemies by 50% |
| Psykino | Magnetic Force | enemies take 4X damage and are pushed away when the area expires |
| Barrager | Barrage | every 3rd attack the barrage shoots 15 projectiles and they push harder |

# Day 57 - 14/04/21

Finished remaining 5 characters and revised all class bonuses. So 40/40 characters and 13/13 classes done. Now the only thing left are items and then all content will be done.

| Character | Classes | Description | 
| --- | --- | --- |
| Highlander | warrior | deals 5X AoE damage |
| Fairy | enchanter, healer | periodically heals 1 unit at random and grants it +100% attack speed for 6 seconds |
| Priest | healer | heals all allies for 20% their max HP |
| Infestor | curser, swarmer | curses nearby enemies for 6 seconds, they will release 2 critters on death |
| Flagellant | enchanter, psyker | deals 2X damage to self and grants +4% damage to all allies per cast |

| Character | Lv.3 Effect Name | Lv.3 Effect Description |
| --- | --- | --- |
| Highlander | Moulinet | quickly repeats the attack 3 times |
| Fairy | Whimsy | heals 2 units instead and grants them an additional 100% attack speed |
| Priest | Divine Intervention | at the start of the round pick 3 units at random and grants them a buff that prevents death once |
| Infestor | Infestation | triples the number of critters released |
| Flagellant | Zealotry | deals 2X damage to all allies and grants +12% damage to all allies per cast |

| Class | Set Color | Set Numbers | Total Units | Set Effect |
| --- | --- | --- | --- | --- |
| Ranger | green | 3/6 | 7 | +10/20% chance to release a barrage to allied rangers |
| Warrior | yellow | 3/6 | 8 | +25/50 defense to allied warriors |
| Mage | blue | 3/6 | 8 | -15/30 enemy defense |
| Rogue | red | 3/6 | 8 | +10/20% chance to crit to allied rogues, dealing 4x damage |
| Healer | green | 2/4 | 5 | +15/30% healing effectiveness |
| Enchanter | blue/red | 2/4 | 5 | +15/25% damage to all allies |
| Nuker | blue/purple | 3/6 | 7 | +15/25% area damage and size to allied nukers |
| Conjurer | orange | 2/4 | 4 | +25/50% summon damage and duration |
| Psyker | white | 2/4 | 4 | +5/10% damage and attack speed per active set to allied psykers |
| Curser | purple | 2/4 | 5 | +25/50% curse dueration |
| Forcer | yellow | 2/4 | 5 | +25/50% knockback force to all allies |
| Swarmer | orange | 2/4 | 4 | +1/3 health to critters |
| Voider | purple | 2/4 | 5 | +15/25% DoT to allied voiders |

# Day 58-59 - 15-16/04/21

Had to ideaguy all 40 passives. Managed to do it and also get the passive selection screen working partly. Tomorrow I should finish it and start working through the 40 passives, which should go significantly faster
than the characters since I made sure to pick types of passives that were already implemented one way or another in the game.

# Day 60-61 - 17-18/04/21

Finished literally everything needed to make passives work, now I only need to actually make them. The more I work on this the clearer the parts that slow me down because they're annoying to work with
become. Generally it's higher level "glue" type of code, rather than the code that actually makes the thing work as a unit. So the node refactor for instance is addressing a lot of this glue code by making it conceptually the same
thing, which should make it easier to work with. The rect cutting UI idea does something similar the high level part of UI, which tends to be mostly layouting. And so on.

# Day 62 - 19/04/21

20 out of 40 passives done today.

| Name | Description |
| --- | --- |
| Ouroboros Technique R | rotating around yourself to the right makes units release projectiles |
| Ouroboros Technique L | rotating around yourself to the left grants +25% defense to all units |
| Wall Echo | hitting walls has a 34% chance of releasing 2 projectiles |
| Wall Rider | hitting walls grants a 25% movement speed buff for 1 second |
| Centipede | +20% movement speed |
| Intimidation | enemies spawn with -20% max HP |
| Vulnerability | enemies take +20% damage |
| Temporal Chains | all enemies move 20% slower |
| Amplify | +25% AoE damage |
| Amplify X | +50% AoE damage |
| Resonance | all AoE attacks deal +5% damage per enemy hit |
| Ballista | +25% damage to rangers and rogues |
| Ballista X | +50% damage to rangers and rogues |
| Point Blank | projectiles deal up to +100% damage up close and down to -50% damage far away |
| Longshot | projectiles deal up to +100% damage far away and down to -50% damage up close |
| Blunt Arrow | all arrows fired by rangers have a 20% chance to knockback |
| Explosive Arrow | all arrows fired by rangers have a 30% chance to explode, dealing 20% AoE damage |
| Divine Machine Arrow | all arrows fired by rangers have a 40% chance to seek enemies and pierce 5 times |
| Chronomancy | all mages cast their spells 25% faster |
| Awakening | every round 1 mage is granted +100% cast speed and damage for that round |

# Day 63 - 20/04/21

| Name | Description |
| --- | --- |
| Divine Punishment | periodically deal 10X damage to all enemies, where X is how many mages you have |
| Berserking | all warriors have up to +50% attack speed based on missing HP |
| Unwavering Stance | all warriors gain +5% defense every 5 seconds |
| Ultimatum | projectiles that chain gain +25% damage with each chain |
| Flying Daggers | all knives thrown by rogues chain +2 times |
| Magnify | +25% area size |
| Concentrated Fire | -50% area size and +50% area damage |
| Unleash | +2% area size and damage per second |
| Reinforce | +10% damage, defense and attack speed to all allies if you have at least one enchanter |
| Payback | +5% damage to all allies whenever an enchanter is hit |
| Blessing | +20% healing effectiveness |
| Hex Master | +25% curse duration |
| Whispers of Doom | curses apply doom, when 4 doom instances are reached they deal 200 damage |
| Force Push | +25% knockback force |
| Heavy Impact | when enemies hit walls they take damage according to the knockback force |
| Crucio | taking damage also shares that amount to each enemy |
| Immolation | 3 allies will periodically take damage, all allies gain +8% damage per tick |
| Call of the Void | +25% damage over time |
| Spawning Pool | +1 critter health |
| Hive | +2 critter health |
| Void Rift | attacks by mages, nukers or voiders have a 20% chance to create a void rift on hit |

# Day 64-66 - 21-23/04/21

Lots of small fixes here and there and also made an attempt at getting the build accepted on Steam. It failed and now I'm waiting again until next week most likely since the guy didn't get to it by the end of Friday.
I also made some small graphical improvements to the game that I think will help. Now what I have left to do, in order of importance:

* General balance
  * Enemies should have a chance to be spawned with a modifier as levels increase
  * Every 3rd level should be wave only
  * Remove "enemies killed" mode
  * Balance playthroughs (record all balance playthroughs as they can be used for trailers)
* UI improvements
  * Hover class highlight
  * DPS list (right)
  * HP list (bottom)
  * Item list (left)
* Graphical improvements
  * Further graphical improvements if there's time
* Trailers
  * 3-4 pure gameplay playthroughs showcasing different builds
* Misc
  * Better pause screen
  * End screen
  * Ascension mode (difficulty ramps up faster and goes higher than normal at the end)
  * Music for bosses and shop
* Achievements
  * Come up with a few new ones as I play the game more and balance the numbers
  * Implement all the ones I already uploaded to Steam

# Day 67 - 24/04/21

Added an end game screen and started work on making elites spawn throughout the levels.

# Day 68 - 25/04/21

Elites now spawn at appropriate rates. Testing out the game a little with this and it seems a lot better than before, but I need to balance a few of the elite units more (headbutter and spawner seem weak).
Also went through a bunch of smaller bug fixes and changes as I play the game more and missing details start popping up. I should leave proper balancing for later and start work on final UI improvements tomorrow.

# Day 69-72 - 26-29/04/21

Everything is done except these:

* General balance
* Trailers
  * 3-4 pure gameplay playthroughs showcasing different builds
  * 1 normal 30-40s trailer
* Misc
  * NG+1-10 (difficulty ramps up faster and goes higher than normal at the end, the player also gains more gold per round, and on NG+1 and NG+5 the maximum number of units is increased by 1 (10->11->12)
  * NG+10 end screen
  * New music
  * Credits

Tomorrow I'll start balancing the game out, which should lead to a bunch of bug fixes and small changes, and after that's done I'll get NG+1-10 working.
Once that's done I'll do credits screen, NG+10 (game complete) screen, and find new music for the game. I want something more ambient generally and less upbeat.

# Day 73-75 - 30/04/21 - 02/05/21

Spending a lot of time balancing the game. The end game is pretty hectic and I need to make sure that it's reachable at NG+~7+.
Basically just playing the game a lot, changing things that are too strong weak, then playing more and seeing if it's better.

# Week 12-13 - 03-17/05/21

These 2 last weeks have been a lot of playtesting and just taking care of details. But now it's finally over.
I finally finished this game and I'm fairly happy with how it turned out. I'll write more about it in a separate blog post, I don't really have the energy to write much now.
