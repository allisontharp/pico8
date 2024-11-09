pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
p_speed = 1
max_sprite = 3
max_enemies = 10
max_screen = 128
dbug = true
test_hitbox = false

function _init()
	show_start_screen()
end

function _draw()
	_drw()
end

function _update()
	_upd()
end

function init()
	fishes = {}
	player = create_player()
	score = 0
	if (test_hitbox) add_new_fish(1, flr(rnd(16)), 10, 10)
	add(fishes, player)
end

-->8
-- fishad
function create_player()
	return {
		s = 1,
		x = 4,
		y = 1,
		dx = 0,
		dy = 0,
		flip = false,
		draw = function(self)
			spr(self.s, self.x, self.y, 1, 1, self.flip)
		end,
		update = function(self)
			self.x += self.dx
			self.y += self.dy
			if self.x <= 0 then
				self.x = max_screen - 5
			elseif self.x >= max_screen then
				self.x = 0 + 5
			end
			if self.y <= 0 then
				self.y = max_screen - 5
			elseif self.y >= max_screen then
				self.y = 0 + 5
			end
		end,
		hitbox = get_hitbox(1)
	}
end

function add_new_fish(_s, _c, _x, _y)
	if _c == 0 then
		_c = 3
	end

	if not test_hitbox then
		speed = rnd(p_speed - 0.5)
		if speed <= 0.1 then speed = 0.1 end
		_dx = speed
		if _x == max_screen then
			_dx *= -1
		end

		_s = flr(rnd(player.s + 2)) + 1
		if _s > max_sprite then
			_s = max_sprite
		end
	else
		_dx = 0
		_s = 1
		-- _dx = 0.1
	end

	add(
		fishes, {
			s = _s,
			c = _c,
			x = _x,
			y = _y,
			dx = _dx,
			dy = 0,
			draw = function(self)
				pal(9, self.c)
				spr(self.s, self.x, self.y, 1, 1, self.dx < 0)
				pal()
			end,
			update = function(self)
				self.x += self.dx
				self.y += self.dy
				if self.x <= 0 or self.y <= 0
						or self.x >= max_screen or self.y >= max_screen then
					del(fishes, self)
				end
				check_col(self)
			end,
			hitbox = get_hitbox(_s)
		}
	)
end

function get_hitbox(s)
	if s == 1 then
		return {
			off_x = 2,
			off_y = 2,
			w = 1,
			h = 1
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

	if s == 3 then
		return {
			off_x = 0,
			off_y = 1,
			w = 4,
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

	if f_right >= p_left and f_left <= p_right
			and f_bottom >= p_top and f_top <= p_bottom then
		debug("collisision")
		debug("fish")
		debug("\tright: " .. f_right .. " left: " .. f_left .. " top: " .. f_top .. " bottom: " .. f_bottom)
		debug("player" .. player.s)
		debug("\tright: " .. p_right .. " left: " .. p_left .. " top: " .. p_top .. " bottom: " .. p_bottom)
		debug("\tx: " .. player.x .. " hitbox off_x: " .. player.hitbox.off_x)
		debug("\ty: " .. player.y .. " hitbox off_y: " .. player.hitbox.off_y .. " h: " .. player.hitbox.h)
		if f.s <= player.s then
			score += 1
			if player.s < max_sprite then
				player.s += 1
			else
				show_win_screen()
			end
			del(fishes, f)
		else
			show_lose_screen()
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

-->8
-- screens
function show_start_screen()
	_drw = function()
		cls()

		print("\^imini minnows", 45, 32, t() * 4 % 16)

		print("")
		print("controls:", 0, 70, 10)
		print("⬅️➡️ move left/right", 5)
		print("⬆️⬇️ move up/down", 5)

		print("press ❎ to play", 30, 120, 5 + t() * 10 % 2)
	end

	_upd = function()
		cls()
		if btnp(❎) then
			restart_game()
		end
	end
end

function restart_game()
	_upd = update_game
	_drw = draw_game
	init()
end

function draw_game()
	cls()
	-- map(0, 0)
	circ(5, 1, 1, 8)
	for f in all(fishes) do
		f:draw()
	end
end

function update_game()
	player.dx = 0
	player.dy = 0
	if btnp(⬅️) then
		player.dx = -1 * p_speed
		player.flip = true
	end
	if btnp(➡️) then
		player.dx = 1 * p_speed
		player.flip = false
	end
	if (btnp(⬆️)) player.dy = -1
	if (btnp(⬇️)) player.dy = 1
	if flr(rnd(100)) > 95 and #fishes < max_enemies and not test_hitbox then
		x = 0
		if flr(rnd(1) * 100) % 2 == 0 then
			x = max_screen
		end
		add_new_fish(1, flr(rnd(16)), x, flr(rnd(max_screen)))
	end
	for f in all(fishes) do
		f:update()
	end
end

function update_restart_screen()
	cls()
	if btnp(❎) then
		restart_game()
	end
end
function show_lose_screen()
	_drw = function()
		cls()

		print("Loser!")
		print("Score: " .. score, 5)
		print("press ❎ to play", 30, 120, 5 + t() * 10 % 2)
	end
	_upd = update_restart_screen
end

function show_win_screen()
	_drw = function()
		cls()

		print("Winner!")
		print("Score: " .. score, 5)
		print("press ❎ to play", 30, 120, 5 + t() * 10 % 2)
	end
	_upd = update_restart_screen
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000090000009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000900000009000000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000090000009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
