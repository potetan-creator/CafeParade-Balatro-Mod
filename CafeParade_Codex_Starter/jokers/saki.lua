return function(cp)
    local c = cp.config.saki
    return {
        config = {extra = {}},
        loc_vars = function(self, queue, card)
            queue[#queue + 1] = G.P_CENTERS.m_wild
            return {vars = {c.xmult, card.ability.extra.changed_blind == cp.blind_id() and 1 or 0,
                localize(card.ability.extra.changed_blind == cp.blind_id() and 'k_cp_used' or 'k_cp_unused')}}
        end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_wild') then
                return {xmult = c.xmult}
            end
            if context.before and cp.original(context) then
                local e, blind = card.ability.extra, cp.blind_id()
                if e.changed_blind == blind then return end
                -- プレイした左端だけを判定し、中央・右の未強化カードは探さない。
                local target = (context.full_hand or {})[1]
                if not target or not cp.plain(target) or target.removed
                    or target.shattered or target.destroyed then return end
                -- 同じブラインドの再評価・再発動に備え、先に使用枠を確保。
                e.changed_blind = blind
                return {
                    message = localize('k_cp_wild'),
                    colour = c.makeup_colour,
                    sound = c.makeup_sound,
                    message_card = target,
                    juice_card = target,
                    card = card,
                    -- Steamodded は message → func の順で効果を解決する。
                    func = function()
                        delay(c.makeup_delay)
                        -- 能力はこのハンドの得点前に確定。見た目だけを
                        -- キューへ送り、Makeup! → 待機 → ワイルド化とする。
                        target:set_ability(G.P_CENTERS.m_wild, nil, true)
                    end,
                }
            end
        end,
    }
end
