return function(cp)
    local c = cp.config.aslan
    return {
        loc_vars = function() return {vars = {c.xmult}} end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and cp.enhanced(context.other_card) then
                return {xmult = c.xmult}
            end
        end,
    }
end
