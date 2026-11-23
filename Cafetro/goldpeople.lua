-- Filter only cards generated into the four original Buffoon Packs.
-- Do not change global rarity weights: shops and other mods' packs share them.
return function()
    local native_packs = {
        p_buffoon_normal_1 = true, p_buffoon_normal_2 = true,
        p_buffoon_jumbo_1 = true, p_buffoon_mega_1 = true,
    }
    local native_rarities = {Common = 1, Uncommon = 2, Rare = 3, Legendary = 4}
    local function rarity_id(key) return native_rarities[key] or key end
    local function active()
        for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
            if not card.debuff and card.config.center.key == 'j_cp_goldpeople' then
                return true
            end
        end
        return false
    end

    local function poll_joker(append)
        local options, total = {}, 0
        -- Match SMODS.poll_rarity, renormalizing the remaining positive weights.
        -- Use the engine's pools to retain bans, unlocks, duplicates and in_pool.
        for _, rarity in ipairs(SMODS.ObjectTypes.Joker.rarities) do
            if rarity_id(rarity.key) ~= 1 then
                local definition = SMODS.Rarities[rarity.key]
                local weight = definition and type(definition.get_weight) == 'function'
                    and definition:get_weight(rarity.weight, SMODS.ObjectTypes.Joker) or rarity.weight
                weight = weight * (G.GAME[tostring(rarity.key):lower() .. '_mod'] or 1)
                if weight > 0 then
                    local pool, pool_key = get_current_pool('Joker', rarity.key, nil, append)
                    local eligible = {}
                    for _, key in ipairs(pool) do
                        local center = G.P_CENTERS[key]
                        if center and rarity_id(center.rarity) == rarity_id(rarity.key) then
                            eligible[#eligible + 1] = key
                        end
                    end
                    -- Copy each pool: get_current_pool reuses G.ARGS.TEMP_POOL.
                    if #eligible > 0 then
                        total = total + weight
                        options[#options + 1] = {pool = eligible, key = pool_key, weight = weight}
                    end
                end
            end
        end
        if #options == 0 then
            -- Like the engine's j_joker fallback when every pool is exhausted,
            -- allow a fixed default; use an Uncommon to keep Commons excluded.
            return 'j_stencil', true
        end
        local roll = pseudorandom(pseudoseed('cp_goldpeople_rarity'
            .. G.GAME.round_resets.ante .. (append or ''))) * total
        local chosen = options[#options]
        for _, option in ipairs(options) do
            roll = roll - option.weight
            if roll < 0 then chosen = option; break end
        end
        if SMODS.optional_features and SMODS.optional_features.object_weights then
            local pool = {}
            for _, key in ipairs(chosen.pool) do pool[#pool + 1] = {key = key, type = 'Joker'} end
            return SMODS.poll_object({type = 'Joker', pool = pool, guaranteed = true,
                seed = 'cp_goldpeople', append = append}), false
        end
        return pseudorandom_element(chosen.pool, pseudoseed(chosen.key)), false
    end

    local create_card = SMODS.create_card
    SMODS.create_card = function(args)
        local booster = SMODS.OPENED_BOOSTER
        local center = booster and booster.config and booster.config.center
        if args and args.set == 'Joker' and G and G.pack_cards and args.area == G.pack_cards
            and center and native_packs[center.key] and active() then
            local forced = args.key and G.P_CENTERS[args.key]
            if not forced or rarity_id(forced.rarity) == 1 or G.GAME.banned_keys[args.key] then
                local filtered = {}
                for key, value in pairs(args) do filtered[key] = value end
                local fallback
                filtered.key, fallback = poll_joker(args.key_append)
                if fallback and G.GAME.banned_keys[filtered.key] then
                    -- Native empty-pool defaults also bypass bans. The forced-key
                    -- path checks them again, so permit only this fixed fallback
                    -- for the synchronous creation, restoring it even on error.
                    local bans, key = G.GAME.banned_keys, filtered.key
                    local banned = bans[key]
                    bans[key] = nil
                    local ok, card, extra = pcall(create_card, filtered)
                    bans[key] = banned
                    if not ok then error(card, 0) end
                    return card, extra
                end
                return create_card(filtered)
            end
        end
        return create_card(args)
    end
end
