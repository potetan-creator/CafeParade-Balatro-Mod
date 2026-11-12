return function(cp)
    local c = cp.config.kamiya
    return {
        config = {extra = {used = {}, blind = ''}},
        loc_vars = function(self, queue, card)
            local n, d = SMODS.get_probability_vars(card, 1, c.odds, 'cp_kamiya')
            local e = card.ability.extra
            return {vars = {c.suits, c.dollars, n, d,
                e.blind == cp.blind_id() and e.used.original and 1 or 0}}
        end,
        calculate = function(self, card, context)
            if context.after and not context.retrigger_joker and cp.suits(context.scoring_hand, c.suits) then
                local e, blind = card.ability.extra, cp.blind_id()
                if e.blind ~= blind then e.blind, e.used = blind, {} end
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
