return function(cp)
    local c = cp.config.three_one_five
    return {
        loc_vars = function() return {vars = {c.xmult}} end,
        calculate = function(self, card, context)
            if context.joker_main then
                local has_three, has_five = false, false
                for _, target in ipairs(context.full_hand or {}) do
                    if not SMODS.has_no_rank(target) then
                        local rank = target:get_id()
                        has_three = has_three or rank == 3
                        has_five = has_five or rank == 5
                    end
                end
                if not (has_three and has_five) then return end
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
