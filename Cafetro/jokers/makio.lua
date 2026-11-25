return function(cp)
    local c = cp.config.makio
    return {
        get_weight = function(self, weight) return weight * cp.makio_food_weight() end,
        loc_vars = function(self, queue)
            queue[#queue + 1] = {set = 'Other', key = 'cp_pair'}
            queue[#queue + 1] = {set = 'Other', key = 'cp_makio'}
            return {vars = {c.targets, c.repetitions}}
        end,
        calculate = function(self, card, context)
            if context.repetition and context.cardarea == G.play then
                local targets = cp.pair_cards(context.scoring_hand)
                for i = 1, math.min(c.targets, #targets) do
                    if targets[i] == context.other_card then
                        return {repetitions = c.repetitions, message = localize('k_again_ex'), card = context.blueprint_card or card}
                    end
                end
            end
        end,
    }
end
