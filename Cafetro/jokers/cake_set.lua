return function(cp)
    return {
        config = {extra = {}},
        blueprint_compat = false,
        loc_vars = function()
            return {vars = {}}
        end,
        add_to_deck = function(self, card) cp.cake_set_added(card) end,
        remove_from_deck = function(self, card) cp.cake_set_removed(card) end,
        calculate = function(self, card, context)
            if not cp.original(context) then return end
            if context.before and cp.begin_cake_set(context) then
                return {message = localize('k_cp_suit_relief')}
            end
            if context.after then cp.end_cake_set(true) end
        end,
    }
end
