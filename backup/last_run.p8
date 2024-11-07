pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	dbug = false
	version = "v0.2"
	set_init()
	show_start_screen()
end

function set_init()
	chosen = 1
	sum = -1
	win = false
	move_count = 0
	start_time = time()
	win_time = nil
end

function _draw()
	_drw()
end

function _update()
	_upd()
end

function restart_game()
	_upd = update_game
	_drw = draw_game
	set_init()
	shuffle()
end

function draw_game()
	cls()

	for i = 1, #hand do
		x = (i - 1) * 10
		y = 60

		local card = hand[i]

		if chosen == i and not card.summed then
			y += 2 * sin(t())
		end

		if card.play then
			y -= 10
		end

		if card.rank == sum then
			y -= 15
		end

		draw_card(card, i, x, y)
	end
end

function update_game()
	if btnp(⬅️) then
		choose_card("desc")
	end
	if btnp(➡️) then
		choose_card("asc")
	end

	if btnp(⬆️) then
		toggle_to_swap(chosen)
	end

	if btnp(❎) then
		swap(chosen)
	end

	set_highlight()

	if win then
		show_win_screen()
	end
end
-->8
-- screens

-- start screen
function show_start_screen()
	_drw = draw_start_screen
	_upd = update_start_screen
end

function draw_start_screen()
	cls()

	print("\^igoo!", 54, 32, t() * 4 % 16)

	print("")
	print("controls:", 0, 70, 10)
	print("⬅️➡️ choose card", 5)
	print("⬆️ toggle card to play", 5)
	print("❎ swap cards", 5)

	print("press ❎ to play", 30, 120, 5 + t() * 10 % 2)
	print(version, 110, 120, 5)
end

function update_start_screen()
	cls()
	if btnp(❎) then
		restart_game()
	end
end

-- win screen
function show_win_screen()
	_drw = draw_win_screen
	_upd = update_win_screen
end

function draw_win_screen()
	cls()
	print("\^iwinner!", 45, 32, t() * 4 % 16)
	print("moves: " .. move_count, 5)
	local tot_time = win_time - start_time
	print("time: " .. tot_time, 5)
	print("")
	print("press ❎ to restart", 30, 120, 5 + t() * 10 % 2)
end

function update_win_screen()
	cls()
	if btnp(❎) then
		restart_game()
	end
end
-->8
-- cards
function draw_card(card, idx, x, y)
	clip(x, y, 32, 48)

	palt(0, false)

	palt(4, true)
	-- make background transparent
	if card.rank == idx then
		pal(7, 1)
	end

	if card.highlight then
		pal(11, 10 + t() * 4 % 2)
	end

	-- base background
	spr(1, x, y, 4, 6)
	pal()
	-- rank
	print(card.rank, x + 5, y + 5, 11)

	pal()
end

function shuffle()
	hand = {}
	deck = {}

	for i = 1, 9 do
		local card = {}
		card.play = false
		card.rank = i
		add(deck, card)
	end

	for i = 1, #deck do
		local card = rnd(deck)
		card.position = i
		add(hand, card)
		del(deck, card)
	end
end

function toggle_to_swap(idx)
	local card = hand[idx]

	if card.rank == sum then
		return
	end

	if card.play then
		card.play = false
		return
	end

	if sum > 0 then
		for c in all(hand) do
			if not c.summed then
				c.play = false
			end
		end
	else
		local cnt_play_cards = 0

		for c in all(hand) do
			if c.play then
				cnt_play_cards += 1
			end
		end

		-- cant have more than 2 cards
		-- ready to swap
		if cnt_play_cards >= 2 then
			return
		end
	end

	card.play = true
	sfx(1)
end

function swap(idx)
	debug("new swap start")
	debug("sum: " .. sum)
	local card = hand[idx]

	debug("card 1:")
	debug("\trank: " .. card.rank)
	debug("\tindex: " .. idx)

	local sum_card = {}
	local sum_index = 0

	for i = 1, #hand do
		local c = hand[i]

		if sum > 0 then
			if c.rank == sum then
				sum_card = c
				sum_index = i
				break
			end
		elseif c.play
				and c.rank != card.rank then
			sum_card = c
			sum_index = i
			break
		end
	end

	if sum_index == 0 then
		-- we dont have two cards
		debug("only 1 card")
		return
	end

	debug("card 2:")
	debug("\trank: " .. sum_card.rank)
	debug("\tindex: " .. sum_index)

	hand[idx] = sum_card
	hand[sum_index] = card

	if sum == -1 then
		sum = sum_card.rank
	end

	debug("will add " .. card.rank)
	sum += card.rank

	debug("sum before subtract" .. sum)

	if sum > 9 then
		sum -= 9
		debug("subtracted 9 from sum")
	end

	card.play = false
	sum_card.play = false

	move_count += 1

	debug("about to check win")
	check_win()
end

function set_highlight()
	if sum < 0
			or chosen > #hand
			or chosen < 0 then
		return
	end

	local card = hand[chosen]
	local highlight_amount = sum + card.rank

	if highlight_amount > 9 then
		highlight_amount -= 9
	end

	for c in all(hand) do
		c.highlight = false
		if c.rank == highlight_amount then
			c.highlight = true
		end
	end
end

function choose_card(dir)
	if dir == "desc" then
		chosen -= 1
	elseif dir == "asc" then
		chosen += 1
	end

	check_end_of_hand()

	local c = hand[chosen]

	if c.rank == sum then
		c.summed = true
		if dir == "desc" then
			chosen -= 1
		elseif dir == "asc" then
			chosen += 1
		end
	else
		c.summed = false
	end

	check_end_of_hand()

	sfx(0)
end

function check_end_of_hand()
	if chosen > #hand then
		chosen = 1
	end
	if chosen <= 0 then
		chosen = #hand
	end
end
-->8
-- logic

function check_win()
	debug("check win")
	print("check win", 5, 5, 10)
	win = false
	for i = 1, #hand do
		local c = hand[i]
		if c.rank != i then
			debug("no win, rank: " .. c.rank)
			debug("no win, i: " .. i)
			return
		end
	end

	debug("setting win to true!!")
	win = true
	win_time = time()
end

function debug(txt)
	if dbug then
		printh(txt, "log")
	end
end

__gfx__
00000000444444444444444444444444444444444444444444444444444444444444444477777700007777777777777777777777777777777777777700000000
0000000044bbbbbbbbbbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbbbbbbbbbbbbbbbbbbb447777703bbb0777777777777777777777777777777777777700000000
007007004bb77777777777777777777777777bb44bb77777777777777777777777777bb4777703bb77b077777777777777777777777777777777777700000000
000770004b7777777777777777777777777777b44b7777777777777777777777777777b477700bbbb7b077777777777777777777777777777777777700000000
000770004b7777777777777777777777777777b44b7777777777777777777777777777b4700bbbbbb7b077777777777777777777777777777777777700000000
007007004b7777777777777777777777777777b44b7777777777777777777777777777b403bbbbbbb7b077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b7777777777777777777777777777b4033bbbbbb7b077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b7777777777777777777777777777b40c3bbbbbb7b077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b7777777777770000777777777777b470c303bbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b7777777777703bbb077777777777b4770003b7bbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bb77b07777777777b4777703bbb7b077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777777700bbbb7b07777777777b4777703bbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777700bbbbbb7b07777777777b4777703bbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777703bbbbbbb7b07777777777b4777703bbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777033bbbbbb7b07777777777b4777703bbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b7777770c3bbbbbb7b07777777777b4777703bbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777770c303bbbbb07777777777b4777703bbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777770003b7bbb07777777777b477770cbb77b077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bbb7b07777777777b477770cbbb7b077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bbbbb07777777777b477770cbbb7b077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bbbbb07777777777b477770cbbbbb077777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bbbbb07777777777b4770003bbbbb000777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bbbbb07777777777b470333bbbbbbbb3077777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bbbbb07777777777b40cbbbbbbbbbb7b077777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777777703bbbbb07777777777b40cbbbbbbbbbbbb077777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777777770cbb77b07777777777b40cc3bbbbbbbbb3077777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777777770cbbb7b07777777777b470cc00bbbb00b0777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777777770cbbb7b07777777777b4770070bb307707777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777777770cbbbbb07777777777b47777770b307777777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b777777770003bbbbb00077777777b47777770bb07777777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b77777770333bbbbbbbb307777777b477777703307777777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b7777770cbbbbbbbbbb7b07777777b477777770077777777777777777777777777777777777777700000000
000000004b7777777777777777777777777777b44b7777770cbbbbbbbbbbbb07777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b7777770cc3bbbbbbbbb307777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b77777770cc00bbbb00b077777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b777777770070bb30770777777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777770b30777777777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777770bb0777777777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777770330777777777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777777007777777777777b400000000000000000000000000000000000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777777777777777777777b44b7777777777777777777777777777b4000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777777777777777777777b44b7777777777777777777777777777b4000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777777777777777777777b44b7777777777777777777777777777b4000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777777777777777777777b44b7777777777777777777777777777b4000000000000000000000000
000000004b7777777777777777777777777777b44b7777777777777777777777777777b44b7777777777777777777777777777b4000000000000000000000000
000000004bb77777777777777777777777777bb44bb77777777777777777777777777bb44bb77777777777777777777777777bb4000000000000000000000000
0000000044bbbbbbbbbbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbbbbbbbbbbbbbbbbbbb44000000000000000000000000
00000000444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000bb77777777777777777777777777bb00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b777bbb7777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b777b7b7777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b777bbb7777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b777b7b7777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b777bbb7777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000b7777777777777777777777777777b00000000000000000
00000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbb7777777777777777777777777777b00000000000000000
00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111111111bbbbbbbbbb7777777777777777777777777777b00000000000000000
0bb77777777bb77777777bb11111111bb11111111bb77777777bb11111111b111111111bb77777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111bbb111b777777777b7777777777777777777777777777b00000000000000000
0b777bbb777b777bbb777b111bbb111b111b1b111b777bb7777b111b11111b11111b111b777bbb777b7777777777777777777777777777b00000000000000000
0b777b7b777b777b77777b11111b111b111b1b111b7777b7777b111b11111b11111b111b77777b777b7777777777777777777777777777b00000000000000000
0b777bbb777b777bbb777b1111bb111b111bbb111b7777b7777b111bbb111b11111b111b777bbb777b7777777777777777777777777777b00000000000000000
0b77777b777b77777b777b11111b111b11111b111b7777b7777b111b1b111b11111b111b777b77777b7777777777777777777777777777b00000000000000000
0b77777b777b777bbb777b111bbb111b11111b111b777bbb777b111bbb111b111111111b777bbb777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777b7777777777777777777777777777b00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b777777777bb77777777777777777777777777bb00000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111b111111111b7777777777777777777777777777b000000000000000000000000000
0b777777777b777777777b111111111b111111111b777777777b111111111bb11111111b7777777777777777777777777777b000000000000000000000000000
0bb77777777bb77777777bb11111111bb11111111bb77777777bb111111111bbbbbbbbbbb77777777777777777777777777bb000000000000000000000000000
00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
0001000000000000000000000000000002a0502d050300502f0502b0502a050000000000000000000000000001000070000000000000000000000000000000000000000000000000000000000000000000000000
000200000000000000000000000000000000001405018050000001f05022050260502d05036050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000100010000100001000011000120002700029000290002800026000220001b00017000160001600016000180001a0001b00000000000000000000000000000000000000000000000000000
