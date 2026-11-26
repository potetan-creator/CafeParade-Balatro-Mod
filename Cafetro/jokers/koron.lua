return function(cp)
    local c = cp.config.koron
    return {
        loc_vars = function() return {vars = {c.chips}} end,
        calculate = function(self, card, context)
            local scored = context.other_card
            if context.individual and context.cardarea == G.play and scored and scored:get_seal() then
                return {chips = c.chips}
            end
        end,
    }
end
