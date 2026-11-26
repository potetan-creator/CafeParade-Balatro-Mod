return function(cp)
    local c = cp.config.hazama

    local function rank_value(card)
        local id = card:get_id()
        if id == 14 then return 1 end
        if type(id) == 'number' and id >= 2 and id <= 13 then return id end

        -- Custom rank IDs are allocated by Steamodded, independently of rank value.
        local rank = card.base and SMODS.Ranks and SMODS.Ranks[card.base.value]
        if rank and rank.id == id then
            return tonumber(rank.original_key) or tonumber(rank.shorthand)
        end
    end

    return {
        loc_vars = function() return {vars = {c.xmult, c.rank_total}} end,
        calculate = function(self, card, context)
            local hand = context.full_hand
            if not context.joker_main or not hand or #hand < 1 or #hand > 5 then return end
            local total = 0
            for _, played in ipairs(hand) do
                if not SMODS.has_no_rank(played) then
                    local value = rank_value(played)
                    if value == nil then return end
                    total = total + value
                end
            end
            if total == c.rank_total then return {xmult = c.xmult} end
        end,
    }
end
