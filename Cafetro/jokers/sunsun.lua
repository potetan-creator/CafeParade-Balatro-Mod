return function(cp)
    local c = cp.config.sunsun
    return {
        loc_vars = function() return {vars = {c.repetitions}} end,
        calculate = function(self, card, context)
            if context.repetition and context.cardarea == G.play
                and not SMODS.has_no_rank(context.other_card) and context.other_card:get_id() == 6 then
                for _, scored in ipairs(context.scoring_hand or {}) do
                    if scored == context.other_card then
                        return {repetitions = c.repetitions, message = localize('k_again_ex'),
                            card = context.blueprint_card or card}
                    end
                end
            end
        end,
    }
end
