return function(cp)
    local c = cp.config.shinonome
    local function finish_growth(extra)
        if extra.pending_growth then
            extra.xmult = extra.pending_growth.xmult
            extra.pending_growth = nil
        end
    end
    return {
        config = {extra = {xmult = c.initial}},
        loc_vars = function(self, queue, card)
            queue[#queue + 1] = {set = 'Other', key = 'cp_pair'}
            return {vars = {c.mult, c.growth, card.ability.extra.xmult}}
        end,
        load = function(self, card)
            -- A save made before the queued animation still contains the earned growth.
            finish_growth(card.ability.extra)
        end,
        calculate = function(self, card, context)
            local e = card.ability.extra
            if context.after and cp.original(context) and #cp.pair_cards(context.scoring_hand) > 0
                and not cp.used(card, 'grown_hand', cp.hand_id()) then
                local pending = {xmult = e.xmult + c.growth}
                e.pending_growth = pending
                return {card = card, func = function()
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = c.growth_delay, func = function()
                        if e.pending_growth ~= pending then return true end
                        -- Change the value and show the popup in the same event,
                        -- after the hand's scoring animations have finished.
                        finish_growth(e)
                        if not card.removed and not card.destroyed then
                            card:juice_up(0.3, 0.5)
                            play_sound('tarot1', 1, 0.6)
                            attention_text({
                                text = localize({type = 'variable', key = 'a_cp_growth',
                                    vars = {string.format('%.2f', e.xmult)}}),
                                scale = 0.7, hold = 0.8, major = card, align = 'cm',
                                offset = {x = 0, y = -0.05},
                                backdrop_colour = G.C.MULT, colour = G.C.WHITE, silent = true,
                            })
                        end
                        return true
                    end}))
                end}
            end
            if context.joker_main then
                return {mult = #cp.pair_cards(context.scoring_hand) > 0 and c.mult or 0, xmult = e.xmult}
            end
        end,
    }
end
