return function(cp)
    if JokerDisplay and JokerDisplay.Definitions then
        JokerDisplay.Definitions.j_cp_sora = {
            text = {
                {text = 'Chun-Chun '},
                {ref_table = 'card.joker_display_values', ref_value = 'remaining'},
            },
            calc_function = function(card)
                card.joker_display_values.remaining = cp.chun_chun_remaining()
            end,
        }
    end

    return {
        loc_vars = function(self, info_queue)
            info_queue[#info_queue + 1] = {key = 'cp_chun_chun_seal', set = 'Other',
                vars = {cp.config.sora.seal_mult}}
            return {vars = {cp.config.sora.round_limit}}
        end,
        calculate = function(self, card, context)
            if context.after and not context.retrigger_joker then
                return cp.prepare_chun_chun(context.full_hand, card)
            end
        end,
    }
end
