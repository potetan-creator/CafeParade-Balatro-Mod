return function(cp)
    local c = cp.config.plain_cakeroll
    return {
        eternal_compat = false,
        pools = {Food = true},
        loc_vars = function(self, queue, card)
            local n, d = SMODS.get_probability_vars(card, 1, c.odds, 'cp_cakeroll_food')
            return {vars = {c.chips, c.targets, n, d}}
        end,
        calculate = function(self, card, context)
            local scoring_hand = context.scoring_hand or {}
            if context.individual and context.cardarea == G.play and #scoring_hand == c.targets then
                for _, target in ipairs(scoring_hand) do
                    if target == context.other_card then
                        return {chips = c.chips}
                    end
                end
            end
            return cp.food_decay(card, context, c.odds, 'cp_cakeroll_food')
        end,
    }
end
