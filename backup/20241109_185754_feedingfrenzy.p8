pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	dbug = false
	fishes = {}
	player = create_player(s)
	add_new_fish(1, flr(rnd(16)), 32, 32)
	add(fishes, player)
end

function _draw()
	cls()
	for f in all(fishes) do
		f:draw()
	end
end

function _update()
	player.dx = 0
	player.dy = 0
	if (btnp(⬅️)) player.dx = -1
	if (btnp(➡️)) player.dx = 1
	if (btnp(⬆️)) player.dx = -1
	if (btnp(⬇️)) player.dx = 1
	for f in all(fishes) do
		f:update()
	end
end

-->8
-- fish
function create_player()
	return {
		s = 1,
		x = 32,
		y = 1,
		dx = 0,
		dy = 0,
		draw = function(self)
			spr(self.s, self.x, self.y)
		end,
		update = function(self)
			self.x += self.dx
			self.y += self.dy
		end
	}
end

function add_new_fish(_s, _c, _x, _y)
	if _c == 0 then
		_c = 3
	end
	add(
		fishes, {
			s = _s,
			x = _x,
			y = _y,
			dx = 2,
			dy = 2,
			draw = function(self)
				pset(self.x, self.y, _c)
			end,
			update = function(self)
				self.x += self.dx
				self.y += self.dy
			end
		}
	)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
