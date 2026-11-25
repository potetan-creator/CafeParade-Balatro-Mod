return function(cp, mod)
    local seal_key = cp.chun_chun_seal
    local c = cp.config.sora

    local function round_state()
        local round = cp.blind_id()
        local state = G.GAME.cp_chun_chun
        if not state or state.round ~= round then
            state = {round = round, played = {}, stamped = {}, count = 0}
            G.GAME.cp_chun_chun = state
        end
        return state
    end

    local function mark_played(state, hand)
        for _, card in ipairs(hand) do
            if card.playing_card then
                state.played[tostring(card.playing_card)] = true
            end
        end
    end

    function cp.chun_chun_remaining()
        local state = G and G.GAME and G.GAME.cp_chun_chun
        if not state or state.finished or state.round ~= cp.blind_id() then return c.round_limit end
        return c.round_limit - state.count
    end

    local function rank_and_suit(card)
        if card.base and card.base.suit and not SMODS.has_no_rank(card) and not SMODS.has_no_suit(card) then
            return card:get_id(), card.base.suit
        end
    end

    function cp.prepare_chun_chun(hand, sora)
        if not hand or not hand[1] then return end
        local state = round_state()
        if state.finished then return end
        mark_played(state, hand)

        -- All Soras and their copies resolve this hand against the same ledger.
        local hand_number = G.GAME.hands_played
        if state.last_hand == hand_number or state.count >= c.round_limit then return end
        state.last_hand = hand_number
        local rank, suit = rank_and_suit(hand[1])
        if not rank then return end

        local rank_key = tostring(rank)
        local stamped = state.stamped[rank_key] or {}
        state.stamped[rank_key] = stamped
        local targets, selected = {}, {}
        cp.each_playing_card(function(card)
            if state.count + #targets >= c.round_limit then return true end
            if not cp.card_present(card) or not card.playing_card or card.seal
                or state.played[tostring(card.playing_card)] then return end
            local other_rank, other_suit = rank_and_suit(card)
            if rank == other_rank and suit ~= other_suit and not stamped[other_suit] and not selected[other_suit] then
                selected[other_suit] = true
                targets[#targets + 1] = {card = card, suit = other_suit}
            end
        end)
        if #targets == 0 then return end

        local game = G.GAME
        local queued = false
        return {func = function()
            if queued then return end
            queued = true
            G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
                if G.GAME ~= game or state.finished or cp.blind_id() ~= state.round then return true end
                local added = false
                for _, target in ipairs(targets) do
                    if state.count >= c.round_limit then break end
                    local card = target.card
                    if cp.card_present(card) and not card.seal and not stamped[target.suit]
                        and not state.played[tostring(card.playing_card)] then
                        -- The native setter reveals the seal, shakes the card and plays its sound now.
                        card:set_seal(seal_key, false, true)
                        if card.seal == seal_key then
                            stamped[target.suit] = true
                            state.count = state.count + 1
                            added = true
                        end
                    end
                end
                if added and cp.card_present(sora) then
                    -- Blueprint rewrites effect.card, but the source here is the real Sora.
                    card_eval_status_text(sora, 'extra', nil, nil, nil, {
                        message = localize('k_cp_chun_chun'), instant = true,
                    })
                end
                return true
            end}))
        end}
    end

    -- The mod receives these contexts even when Sora is absent or debuffed.
    function mod:calculate(context)
        if context.end_of_round and context.main_eval and not context.individual and not context.repetition then
            local state = round_state()
            if not state.finished then
                state.finished = true
                cp.each_playing_card(function(card)
                    if card.seal == seal_key then card:set_seal(nil, true, true) end
                end)
            end
        elseif (context.before or context.debuffed_hand) and context.full_hand then
            mark_played(round_state(), context.full_hand)
        end
    end

    -- DNA, Death, Cryptid and SMODS.copy_card share this primitive. Preserve
    -- the original card and every non-Chun-Chun seal on the native path.
    local original_copy = copy_card
    function copy_card(source, ...)
        local temporary = source.seal == seal_key
        local result = original_copy(source, ...)
        if temporary and result and result ~= source and result.seal == seal_key then
            result:set_seal(nil, true, true)
        end
        return result
    end

    SMODS.Seal {
        key = 'chun_chun',
        atlas = 'chun_chun',
        pos = {x = 0, y = 0},
        discovered = true,
        badge_colour = HEX('AC4870'),
        in_pool = function() return false end,
        weight = 0,
        loc_vars = function() return {vars = {c.seal_mult}} end,
        calculate = function(self, card, context)
            if context.main_scoring and context.cardarea == G.play and not card.debuff then
                return {mult = c.seal_mult}
            end
        end,
    }
end
