return function(cp)
    local c = cp.config.amehiko
    local function xmult() return c.base + c.per_negative * cp.negative_count() end
    return {
        set_ability = function(self, card)
            -- SMODS skips the random creation-edition roll if already set.
            card:set_edition({negative = true}, true, true)
        end,
        loc_vars = function()
            return {vars = {c.per_negative, xmult()}}
        end,
        calculate = function(self, card, context)
            if context.joker_main then return {xmult = xmult()} end
        end,
    }
end
