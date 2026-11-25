return function(cp)
    function cp.negative_count()
        local seen, count = {}, 0
        local function scan(cards)
            for _, card in ipairs(cards or {}) do
                if not seen[card] then
                    seen[card] = true
                    local edition = card.edition
                    if edition and (edition.negative or edition.key == 'e_negative')
                        and not card.removed and not card.destroyed and not card.shattered
                        and not card.getting_sliced then count = count + 1 end
                end
            end
        end
        if not G then return 0 end
        scan(G.jokers and G.jokers.cards)
        scan(G.consumeables and G.consumeables.cards)
        scan(G.playing_cards)
        -- Standard cards live in playing_cards; scan owned areas too for mods
        -- that register cards late. Never scan shops, packs or UI previews.
        for _, key in ipairs({'deck', 'hand', 'play', 'discard'}) do
            scan(G[key] and G[key].cards)
        end
        return count
    end

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
