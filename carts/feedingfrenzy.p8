pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[
ideas:
- choose to upgrade or go faster?
- hunger countdown
]]
p_speed = 1
max_fish_speed = 1
max_sprite = 5
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
	sp = 1
	if (test_hitbox) add_new_fish(4, flr(rnd(16)), 10, 10)
	add(fishes, player)
end

-->8
-- fishad
function create_player(s)
	if s == nil then
		s = 1
	end
	local d = get_fish_details(s)
	return {
		s = 1,
		x = 4,
		y = 1,
		dx = 0,
		dy = 0,
		xp_goal = d.xp_to_evolve,
		xp = 0,
		flip = false,
		draw = function(self)
			local w = 1
			local h = 1
			if self.s >= 5 then
				w = 2
			end
			spr(get_sprite_to_draw(self.s), self.x, self.y, w, h, self.flip)
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
			local d = get_fish_details(self.s)
			self.hitbox = d.hitbox
		end,
		hitbox = d.hitbox
	}
end

function add_new_fish(_s, _c, _x, _y)
	if _c == 1 or _c == 12 then
		_c = 3
	end

	if not test_hitbox then
		speed = rnd(max_fish_speed - 0.5)
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
		-- _dx = 0.1
	end

	local d = get_fish_details(_s)

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
				local w = 1
				local h = 1
				if self.s >= 5 then
					w = 2
				end
				spr(get_sprite_to_draw(self.s), self.x, self.y, w, h, self.dx < 0)
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
			hitbox = d.hitbox
		}
	)
end

function get_sprite_to_draw(s)
	if sp >= 2 then
		return s + 16
	end

	return s
end

function get_fish_details(s, log)
	if log != nil and log then
		debug("get_fish_details: " .. s)
	end
	if s == 1 then
		return {
			xp_to_evolve = 2,
			hitbox = {
				off_x = 2,
				off_y = 2,
				w = 1,
				h = 1
			}
		}
	end

	if s == 2 then
		return {
			xp_to_evolve = 4,
			hitbox = {
				off_x = 2,
				off_y = 2,
				w = 2,
				h = 3
			}
		}
	end

	if s == 3 then
		return {
			xp_to_evolve = 5,
			hitbox = {
				off_x = 0,
				off_y = 1,
				w = 4,
				h = 3
			}
		}
	end

	if s == 4 then
		return {
			xp_to_evolve = 7,
			hitbox = {
				off_x = 0,
				off_y = 0,
				w = 8,
				h = 8
			}
		}
	end

	if s == 5 then
		return {
			xp_to_evolve = 10,
			hitbox = {
				off_x = 0,
				off_y = 0,
				w = 16,
				h = 8
			}
		}
	end

	return {
		hitbox = {
			off_x = 0,
			off_y = 0,
			w = 0,
			h = 0
		}
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
			-- player.xp_to_evolve -= 1
			if player.xp < player.xp_goal then
				player.xp += 1
			end
			-- if player.s < max_sprite then
			-- 	player.s += 1
			-- else
			-- 	show_win_screen()
			-- end

			if player.s == max_sprite then
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
	map(0, 9, 0, 0)
	-- circ(5, 1, 1, 8)
	for f in all(fishes) do
		f:draw()
	end
	print("score: " .. score, 90, 5, 5)
	-- print("xp: " .. player.xp_to_evolve, 90, 10, 5)
	pal(0, 3)
	draw_xp()
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

	if btnp(❎) then
		if player.xp >= player.xp_goal then
			player.s += 1
			local d = get_fish_details(player.s, true)
			player.xp_goal = d.xp_to_evolve
			player.xp = 0
		end
		-- restart_game()
	end
	if btnp(🅾️) then
		if player.xp >= player.xp_goal then
			p_speed += 0.5
			local d = get_fish_details(player.s, true)
			player.xp = 0
			xp_to_goal = 0
		end
	end
	if sp < 2.9 then
		sp += 0.1
	else
		sp = 1
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
		print("XP to Evolve: " .. score, 5)
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

-->8
-- xp
function draw_xp()
	spr(64, 5, 5, 3, 1)

	local pct = player.xp / player.xp_goal
	local lines = 22 * pct
	if lines > 0 then
		debug("lines: " .. lines)
	end
	-- 22 lines
	for i = 1, lines do
		local li = i
		if i > 2 and i < 21 then
			li = 3
		elseif i == 21 then
			li = 4
		elseif i == 22 then
			li = 5
		end
		local l = xp_bar[li]
		local x = l.x

		if i > 2 and i < 21 then
			x += i
		end
		line(x, l.y1, x, l.y2, 9)
	end
end

xp_bar = {
	{
		x = 6,
		y1 = 8,
		y2 = 9
	},
	{
		x = 7,
		y1 = 7,
		y2 = 10
	},
	{
		x = 5,
		y1 = 6,
		y2 = 11
	},
	{
		x = 26,
		y1 = 7,
		y2 = 10
	},
	{
		x = 27,
		y1 = 8,
		y2 = 9
	}
}

__gfx__
00000000000000000000000000000000000990000000000999999990000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000999000999009999999999000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000090000009090000909000900009909999909999000000000000000000000000000000000000000000000000000000000000000000000000
00077000000900000009000000999000090909090000999999999900000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000090000009090000090909090000099999999000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000909000900000999999999999000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000999000009909999999999000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000990000999000999999990000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000000000000990000000000999999990000000000000000000000000000000000000000000000000000000000000000000000000
70707070000000000000000000000000000999000000009999999990000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000090000009000900000009999909999000000000000000000000000000000000000000000000000000000000000000000000000
70707070000f00000099000009999000990909090999999999999999000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000090000990909000099999999999999000000000000000000000000000000000000000000000000000000000000000000000000
70707070000000000000000000000000009000900999999999999999000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000000000000999000000009999999999000000000000000000000000000000000000000000000000000000000000000000000000
70707070000000000000000000000000000990000000000999999990000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc1ccc1ccc1ccc1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccc1c1c1ccc1c1c1c100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc1ccc1c1c1c1c1c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccc1c1c1ccc1ccc1cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111cc1ccc1c1c1c1c1c11111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111c1c1c1c1c1c1ccc113111311111113110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111111c1c1c1c1c1c1c1c13311331111133110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111c111c111c111c111313311311331110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111131133133311310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111311331113313310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111333311111333110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111133111111131110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600000000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600000000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212221222122212221222122212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132313231323132313231323132313200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3033303034303033303030333430303300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
