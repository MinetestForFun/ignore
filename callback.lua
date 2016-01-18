-- Part of the ignore mod
-- Last Modification : 01/18/16 @ 9:01PM UTC+1
-- This file contains the ignore callback
--

function ignore.callback(sender, message)

	-- 1) The engine's job
	-- Invalid command handler (which should be in the builtin btw)
	if message == "/" then
		minetest.chat_send_player(sender, "-!- Empty command")
		return true
	end
	local cmd, _ = message:match("^/([^ ]+) *(.*)")
	if cmd and not core.chatcommands[cmd] then
		minetest.chat_send_player(sender, "-!- Invalid command: " .. cmd)
		return true
	elseif not minetest.check_player_privs(sender, {shout = true}) then
		minetest.chat_send_player(sender, "-!- You don't have permission to shout.")
		return true
	end

	-- Normal log handler
	minetest.log("action", ("CHAT: <%s> %s"):format(sender, message))

	-- Execute other callbacks (remember we don't want to block them)
	-- First, identify our range in the callback table
	local index = 0
	for i, func in pairs(core.registered_on_chat_messages) do
		if func == ignore.callback then
			index = i
			break
		end
	end

	for i = index+1, table.getn(core.registered_on_chat_messages) do
		local ret = core.registered_on_chat_messages[i](sender, message)
		if ret then
			-- If other mods decide to block callbacks that's their choice
			break
		end
	end


	-- Finally, send and sort according to ignores
	for k, ref in pairs(minetest.get_connected_players()) do
		local receiver = ref:get_player_name()
		if receiver ~= sender and not ignore.get_ignore(sender, receiver) then
			minetest.chat_send_player(receiver, ("<%s> %s"):format(sender, message))
		end
	end	

	return true -- Tell the engine we did its job
end

minetest.register_on_chat_message(ignore.callback)
