return function(cp)
    local c = cp.config.embossing
    return {
        loc_vars = function() return {vars = {c.mult}} end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and cp.enhanced(context.other_card) then
                return {mult = c.mult}
            end
        end,
    }
end
