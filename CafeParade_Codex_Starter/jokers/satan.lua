return function(cp)
    local c = cp.config.satan
    return {
        config = {extra = {growth = 0}},
        loc_vars = function(self, queue, card)
            local members = cp.members()
            return {vars = {c.slots, c.base, c.per_member, c.growth, members,
                card.ability.extra.growth, c.base + c.per_member * members + card.ability.extra.growth}}
        end,
        -- transient な印は copy_card がコピーする ability に入れない。
        add_to_deck = function(self, card)
            if not card.cp_slot_applied then
                G.jokers.config.card_limit = G.jokers.config.card_limit + c.slots
                card.cp_slot_applied = true
            end
        end,
        remove_from_deck = function(self, card)
            if card.cp_slot_applied then
                G.jokers.config.card_limit = G.jokers.config.card_limit - c.slots
                card.cp_slot_applied = nil
            end
        end,
        load = function(self, card, saved)
            -- CardArea の保存済み上限には加算分が含まれる。ロードで再加算しない。
            card.cp_slot_applied = saved.added_to_deck and not saved.debuff or nil
        end,
        calculate = function(self, card, context)
            local e = card.ability.extra
            if context.end_of_round and not context.individual and not context.repetition
                and not context.game_over and context.beat_boss and cp.original(context)
                and not cp.used(card, 'grown_boss', cp.blind_id()) then
                e.growth = e.growth + cp.members() * c.growth
            end
            if context.joker_main then
                return {xmult = c.base + c.per_member * cp.members() + e.growth}
            end
        end,
    }
end
