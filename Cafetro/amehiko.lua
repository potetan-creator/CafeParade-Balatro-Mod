return function(cp)
    local negative_editions = {e_negative = true}

    function cp.register_negative_edition(key)
        negative_editions[key] = true
    end

    function cp.is_negative_equivalent(card)
        if not card then return false end
        if card.seal == cp.chun_chun_seal then return true end
        local edition = card.edition
        if not edition then return false end
        local prototype = G and G.P_CENTERS and G.P_CENTERS[edition.key]
        return not not (edition.negative or edition.type == 'negative' or negative_editions[edition.key]
            or (prototype and (prototype.negative or (prototype.config and prototype.config.negative))))
    end

    function cp.count_negative_equivalent()
        local seen, count = {}, 0
        local function tally(card)
            if not seen[card] then
                seen[card] = true
                if cp.card_present(card) and cp.is_negative_equivalent(card) then count = count + 1 end
            end
        end
        if not G then return 0 end
        for _, area in ipairs({'jokers', 'consumeables'}) do
            for _, card in ipairs(G[area] and G[area].cards or {}) do tally(card) end
        end
        cp.each_playing_card(tally)
        return count
    end
    cp.negative_count = cp.count_negative_equivalent

    -- Use the normal setter for all capacity, cost and Edition callbacks.
    -- Also handles copies and generators that explicitly request an edition.
    local set_edition = Card.set_edition
    function Card:set_edition(edition, immediate, silent, ...)
        if self.config and self.config.center and self.config.center.key == 'j_cp_amehiko' then
            edition = {negative = true}
        end
        return set_edition(self, edition, immediate, silent, ...)
    end

    SMODS.DrawStep {
        key = 'amehiko_front',
        -- Edition/negative shine is 20; seals and stickers are 30/40.
        order = 25,
        conditions = {vortex = false, facing = 'front'},
        func = function(card)
            local center = card.config.center
            if center.key ~= 'j_cp_amehiko' or not (center.discovered or card.bypass_discovery_center) then return end
            local sprite = card.children.cp_amehiko_front
            if not sprite then
                sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h,
                    G.ASSET_ATLAS.cp_amehiko_front, {x = 0, y = 0})
                sprite:set_role({major = card, role_type = 'Glued', draw_major = card})
                sprite.float = false
                sprite.custom_draw = true -- Suppress the automatic "others" pass.
                sprite.states.collide.can = false
                sprite.states.hover.can = false
                sprite.states.click.can = false
                sprite.states.drag.can = false
                card.children.cp_amehiko_front = sprite
            end
            -- Follow the center exactly. No edition shader, shadow, float,
            -- scale/rotation oscillation or offset is applied to the portrait.
            sprite:draw_shader('dissolve', nil, nil, nil, card.children.center, 0, 0)
        end,
    }
end
