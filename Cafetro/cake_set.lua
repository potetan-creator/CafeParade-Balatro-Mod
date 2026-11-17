-- Remove only the suit field while the original Blind debuff pipeline runs.
-- Other blind checks, Joker effects and SMODS debuff sources still run normally.
return function(cp)
    local suit_bosses = {bl_club=true, bl_goad=true, bl_window=true, bl_head=true}

    local function available()
        for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
            if card.config.center.key == 'j_cp_cake_set' and not card.debuff
                and not card.cp_cake_set_inactive and not card.removed
                and not card.destroyed then
                return true
            end
        end
        return false
    end

    local function suit_boss(blind)
        local def = blind and blind.config and blind.config.blind
        return def and suit_bosses[def.key] and not blind.disabled
            and blind.debuff and blind.debuff.suit
    end

    local function refresh()
        for _, card in ipairs(G.playing_cards or {}) do
            if not card.removed and not card.destroyed and not card.shattered then
                SMODS.recalc_debuff(card)
            end
        end
        return true
    end

    function cp.cake_set_active(blind)
        local hand = cp.cake_set_hand
        return hand and hand.blind == blind and hand.token == cp.hand_id()
            and suit_boss(blind) and available()
    end

    function cp.end_cake_set(deferred)
        if not cp.cake_set_hand then return end
        cp.cake_set_hand = nil
        if deferred then
            -- Restore the visual debuff after this hand's scoring animations.
            G.E_MANAGER:add_event(Event({func = refresh}))
        else
            refresh()
        end
    end

    function cp.begin_cake_set(context)
        local blind = G.GAME.blind
        if context.scoring_name ~= 'Pair' or not suit_boss(blind) or not available() then
            cp.end_cake_set(false)
            return false
        end
        if cp.cake_set_active(blind) then return false end
        -- Keep the actual scoring name; do not reclassify after Saki changes a suit.
        cp.cake_set_hand = {blind = blind, token = cp.hand_id()}
        refresh()
        return true
    end

    function cp.cake_set_added(card)
        card.cp_cake_set_inactive = nil
        if cp.cake_set_hand then refresh() end
    end

    function cp.cake_set_removed(card)
        card.cp_cake_set_inactive = true
        if not available() then cp.end_cake_set(false) end
    end

    local debuff_card = Blind.debuff_card
    function Blind:debuff_card(card, from_blind)
        if card.area == G.jokers or not cp.cake_set_active(self) then
            return debuff_card(self, card, from_blind)
        end
        local original, without_suit = self.debuff, {}
        for key, value in pairs(original) do
            if key ~= 'suit' then without_suit[key] = value end
        end
        self.debuff = without_suit
        local ok, result = pcall(debuff_card, self, card, from_blind)
        self.debuff = original
        if not ok then error(result, 0) end
        return result
    end
end
