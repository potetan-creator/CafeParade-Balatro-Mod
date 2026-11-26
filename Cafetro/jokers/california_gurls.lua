return function(cp)
    local c = cp.config.california_gurls
    local chip_seed = 'cp_california_gurls_chips'
    local departure_seed = 'cp_california_gurls_departure'
    return {
        config = {extra = {}},
        eternal_compat = false,
        loc_vars = function(self, queue, card)
            local chip_n, chip_d = SMODS.get_probability_vars(card, 1, c.odds, chip_seed)
            local exit_n, exit_d = SMODS.get_probability_vars(card, 1, c.odds, departure_seed)
            return {vars = {c.chips, chip_n, chip_d, exit_n, exit_d}}
        end,
        calculate = function(self, card, context)
            local extra = card.ability.extra
            if context.press_play then
                if cp.original(context) and not cp.used(card, 'chip_hand', cp.hand_id()) then
                    extra.won_chips = SMODS.pseudorandom_probability(card, chip_seed, 1, c.odds, chip_seed)
                end
                return
            end
            if context.joker_main then
                if extra.chip_hand == cp.hand_id() and extra.won_chips then
                    return {chips = c.chips}
                end
                return
            end
            return cp.food_decay(card, context, c.odds, departure_seed, 'k_cp_departed')
        end,
    }
end
