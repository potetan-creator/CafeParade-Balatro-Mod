return function(cp)
    function cp.food_decay(card, context, odds, seed, message)
        if not (context.end_of_round and context.main_eval and cp.original(context))
            or context.individual or context.repetition or context.game_over or card.debuff
            or card.removed or card.destroyed or card.getting_sliced or card.ability.eternal then return end
        -- Old Roll Cake saves have no ability.extra. Keep the round guard saved
        -- on each physical card, so copies/re-evaluation cannot roll twice.
        if type(card.ability.extra) ~= 'table' then card.ability.extra = {} end
        if cp.used(card, 'food_round', cp.blind_id()) then return end
        if SMODS.pseudorandom_probability(card, seed, 1, odds, seed) then
            local destroyed = SMODS.destroy_cards({card}, {pinch_anim = true})
            if destroyed and #destroyed > 0 then
                return {message = localize(message or 'k_eaten_ex'), colour = G.C.FILTER}
            end
        end
    end

    function cp.makio_food_weight()
        for _, card in ipairs(G and G.jokers and G.jokers.cards or {}) do
            local key = card.config.center.key
            if (key == 'j_cp_plain_cakeroll' or key == 'j_cp_cake_set') and not card.debuff
                and not card.removed and not card.destroyed and not card.getting_sliced then
                return cp.config.food.makio_weight
            end
        end
        return 1
    end

    -- Legacy SMODS draws Joker keys uniformly. Mix in a separate seeded roll
    -- to give only Makio weight b, without changing rarity odds or pool entries.
    -- For n entries (m Makios), q=(b-1)m/(n+(b-1)m) gives the exact weighting.
    -- Modern object_weights uses Makio's get_weight instead of this selector.
    local select_element = pseudorandom_element
    function pseudorandom_element(pool, seed, args)
        local value, index = select_element(pool, seed, args)
        local boost = cp.makio_food_weight()
        if boost <= 1 or not value or value == 'j_cp_makio' or (args and args.in_pool)
            or type(pool) ~= 'table' or #pool == 0
            or (G.GAME.banned_keys and G.GAME.banned_keys.j_cp_makio) then return value, index end
        local target, copies, entries = nil, 0, 0
        for key, entry in pairs(pool) do
            entries = entries + 1
            if type(key) ~= 'number' or key < 1 or key > #pool or key % 1 ~= 0 then return value, index end
            local center = type(entry) == 'string' and G.P_CENTERS[entry]
            if entry ~= 'UNAVAILABLE' and (not center or center.set ~= 'Joker') then return value, index end
            if entry == 'j_cp_makio' then target, copies = key, copies + 1 end
        end
        if not target or entries ~= #pool then return value, index end
        local extra = (boost - 1) * copies
        if pseudorandom('cp_food_makio') < extra / (#pool + extra) then
            return 'j_cp_makio', target
        end
        return value, index
    end
end
