pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	dbug = true
	fishes = {}
	player = create_player()
	add_new_fish(1, flr(rnd(16)), 0, 5)
	add(fishes, player)
end

function _draw()
	cls()
	-- map(0, 0, 0, 0, 16, 16)
	for f in all(fishes) do
		f:draw()
	end
end

function _update()
	player.dx = 0
	player.dy = 0
	if btnp(⬅️) then
		player.dx = -1
		player.flip = true
	end
	if btnp(➡️) then
		player.dx = 1
		player.flip = false
	end
	if (btnp(⬆️)) player.dy = -1
	if (btnp(⬇️)) player.dy = 1
	for f in all(fishes) do
		f:update()
	end
end

-->8
-- fish
function create_player()
	return {
		s = 1,
		x = 4,
		y = 1,
		dx = 0,
		dy = 0,
		flip = false,
		draw = function(self)
			debug("")
			debug("player sprint: " .. self.s)
			debug("")
			spr(self.s, self.x, self.y, 1, 1, self.flip)
		end,
		update = function(self)
			self.x += self.dx
			self.y += self.dy
		end,
		hitbox = get_hitbox(2)
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
			dx = 0,
			dy = 0,
			draw = function(self)
				pal(9, 3)
				spr(self.s, self.x, self.y)
				pal()
			end,
			update = function(self)
				self.x += self.dx
				self.y += self.dy
				check_col(self)
			end,
			hitbox = get_hitbox(_s)
		}
	)
end

function get_hitbox(s)
	if s == 1 then
		return {
			off_x = 3,
			off_y = 3,
			w = 0,
			h = 0
		}
	end

	if s == 2 then
		return {
			off_x = 2,
			off_y = 2,
			w = 2,
			h = 3
		}
	end

	return {
		off_x = 0,
		off_y = 0,
		w = 0,
		h = 0
	}
end

-->8
-- collision
function check_col(f)
	f_right = f.x + f.hitbox.off_x + f.hitbox.w
	f_left = f.x + f.hitbox.off_x
	f_top = f.y + f.hitbox.off_y
	f_bottom = f.y + f.hitbox.off_y + f.hitbox.h

	p_right = player.x + player.hitbox.off_x + player.hitbox.w
	p_left = player.x + player.hitbox.off_x
	p_top = player.y + player.hitbox.off_y
	p_bottom = player.y + player.hitbox.off_y + player.hitbox.h

	if f_right >= p_left and (f_bottom < p_top or f_top < p_bottom)
			and f_left <= p_right then
		if f.s <= player.s then
			player.s += 1
			del(fishes, f)
			debug("set player.s to: " .. player.s)
		else
			cls()
			print("LOSER!")
			debug("loser")
		end
	end
end

-->8
-- helpers
function debug(text)
	if dbug then
		printh(text, "fflog")
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000900000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000