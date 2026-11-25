return function(cp)
    local c = cp.config.cake_set
    return {
        config = {extra = {}},
        blueprint_compat = false,
        eternal_compat = false,
        pools = {Food = true},
        loc_vars = function(self, queue, card)
            local n, d = SMODS.get_probability_vars(card, 1, c.odds, 'cp_cake_set_food')
            return {vars = {n, d}}
        end,
        add_to_deck = function(self, card) cp.cake_set_added(card) end,
        remove_from_deck = function(self, card) cp.cake_set_removed(card) end,
        calculate = function(self, card, context)
            if not cp.original(context) then return end
            local eaten = cp.food_decay(card, context, c.odds, 'cp_cake_set_food')
            if eaten then return eaten end
            if context.before and cp.begin_cake_set(context) then
                return {message = localize('k_cp_suit_relief')}
            end
            if context.after then cp.end_cake_set(true) end
        end,
    }
end
