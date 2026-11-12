return function(cp)
    local c = cp.config.saki
    return {
        config = {extra = {}},
        loc_vars = function(self, queue, card)
            queue[#queue + 1] = {set = 'Other', key = 'cp_saki'}
            queue[#queue + 1] = G.P_CENTERS.m_wild
            return {vars = {c.xmult, card.ability.extra.changed_blind == cp.blind_id() and 1 or 0,
                localize(card.ability.extra.changed_blind == cp.blind_id() and 'k_cp_used' or 'k_cp_unused')}}
        end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_wild') then
                return {xmult = c.xmult}
            end
            if context.after and cp.original(context) then
                local e, blind = card.ability.extra, cp.blind_id()
                if e.changed_blind == blind then return end
                -- after は全得点処理の後。直接変化させ、保存可能な状態を即時確定。
                -- 複数の咲も直前の変化を見て、強化済みカードを上書きしない。
                for _, target in ipairs(context.scoring_hand or {}) do
                    if cp.plain(target) and not target.removed and not target.shattered
                        and not target.destroyed then
                        target:set_ability(G.P_CENTERS.m_wild)
                        e.changed_blind = blind
                        return {message = localize('k_cp_wild'), colour = G.C.MULT}
                    end
                end
            end
        end,
    }
end
