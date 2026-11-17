return function(cp)
    local c = cp.config.plain_cakeroll
    return {
        loc_vars = function() return {vars = {c.chips, c.targets}} end,
        calculate = function(self, card, context)
            local scoring_hand = context.scoring_hand or {}
            if context.individual and context.cardarea == G.play and #scoring_hand == c.targets then
                for _, target in ipairs(scoring_hand) do
                    if target == context.other_card then
                        return {chips = c.chips}
                    end
                end
            end
        end,
    }
end
