return function(cp)
    local c = cp.config.kamiya
    return {
        config = {extra = {used = {}, hand = ''}},
        loc_vars = function(self, queue, card)
            queue[#queue + 1] = {set = 'Other', key = 'cp_suits'}
            local n, d = SMODS.get_probability_vars(card, 1, c.odds, 'cp_kamiya')
            return {vars = {c.suits, c.dollars, n, d}}
        end,
        calculate = function(self, card, context)
            if context.after and not context.retrigger_joker and cp.suits(context.scoring_hand, c.suits) then
                local e, hand = card.ability.extra, cp.hand_id()
                -- Each qualifying hand pays. Keep only the duplicate-evaluation guard;
                -- old saves with a blind-scoped flag reset on their first new evaluation.
                if e.hand ~= hand then e.hand, e.used = hand, {} end
                local copy = context.blueprint and context.blueprint_card
                local key = copy and ('copy_' .. tostring(copy.sort_id)) or 'original'
                if e.used[key] then return end
                e.used[key] = true
                if SMODS.pseudorandom_probability(card, 'cp_kamiya', 1, c.odds, 'cp_kamiya') then
                    -- 予約枠で複数神谷/コピーによるオーバーフローを防ぐ。
                    local buffer = G.GAME.consumeable_buffer or 0
                    if #G.consumeables.cards + buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = buffer + 1
                        G.E_MANAGER:add_event(Event({func = function()
                            if #G.consumeables.cards < G.consumeables.config.card_limit then
                                SMODS.add_card({set = 'Tarot', area = G.consumeables, key_append = 'cp_kamiya'})
                            end
                            G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                            return true
                        end}))
                    end
                end
                return {dollars = c.dollars}
            end
        end,
    }
end
