return function(cp)
    local c = cp.config.shinonome
    return {
        config = {extra = {xmult = c.initial}},
        loc_vars = function(self, queue, card)
            return {vars = {c.mult, c.growth, card.ability.extra.xmult}}
        end,
        calculate = function(self, card, context)
            local e = card.ability.extra
            if context.before and cp.original(context) and #cp.pair_cards(context.scoring_hand) > 0
                and not cp.used(card, 'grown_hand', cp.hand_id()) then
                e.xmult = e.xmult + c.growth
            end
            if context.joker_main then
                return {mult = #cp.pair_cards(context.scoring_hand) > 0 and c.mult or 0, xmult = e.xmult}
            end
        end,
    }
end
