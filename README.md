in-progress prototype/template for a movement-focused bullet hell 2d platformer.

TODO:
- [x] basic player movement
- [x] basic player-environment collisions
- [x] player primary fire
- [ ] player dashing (w/ wavedash(??))
- [ ] one-way platforms / dropping through platforms
- [x] tracking player projectiles to enemy
- [ ] focus mode (no homing, does more damage)
- [x] boss health
- [ ] player death
- [ ] enemy attack patterns
- [ ] level/arena layouts

LAYERS:
- vis 0: player bullets
- vis 1: player sprite
- col 1: player terrain hitbox
- col 2: player hurtbox
- z 0: bullets
- z 1: player, enemy
