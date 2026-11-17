return function(cp)
    local c = cp.config.chocolate_spacial
    return {
        config = {extra = {hand = '', used = {}}},
        loc_vars = function() return {vars = {c.cards}} end,
        calculate = function(self, card, context)
            if not context.after or context.retrigger_joker
                or context.scoring_name ~= 'Flush House' then return end

            local e, hand = card.ability.extra, cp.hand_id()
            if e.hand ~= hand then e.hand, e.used = hand, {} end
            local copy = context.blueprint and context.blueprint_card
            local key = copy and ('copy_' .. tostring(copy.sort_id)) or 'original'
            if e.used[key] then return end
            e.used[key] = true

            -- Reserve only free slots so other generators and Blueprint copies
            -- cannot overfill the consumable area before these events run.
            local buffer = G.GAME.consumeable_buffer or 0
            local free = G.consumeables.config.card_limit - #G.consumeables.cards - buffer
            local amount = math.min(c.cards, math.max(0, math.floor(free)))
            if amount == 0 then return end
            G.GAME.consumeable_buffer = buffer + amount
            G.E_MANAGER:add_event(Event({func = function()
                for _ = 1, amount do
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        SMODS.add_card({set = 'Spectral', area = G.consumeables,
                            key_append = 'cp_chocolate_spacial'})
                    end
                end
                G.GAME.consumeable_buffer = math.max(0,
                    (G.GAME.consumeable_buffer or 0) - amount)
                return true
            end}))
            return {message = localize('k_plus_spectral'),
                colour = G.C.SECONDARY_SET.Spectral, card = copy or card}
        end,
    }
end
