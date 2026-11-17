return function(cp)
    local c = cp.config.three_one_five
    return {
        loc_vars = function() return {vars = {c.xmult}} end,
        calculate = function(self, card, context)
            if context.joker_main then
                for _, target in ipairs(context.scoring_hand or {}) do
                    if not target.debuff and not SMODS.has_no_rank(target) then
                        local rank = target:get_id()
                        if rank == 3 or rank == 5 then
                            return {xmult = c.xmult}
                        end
                    end
                end
            end
        end,
    }
end
