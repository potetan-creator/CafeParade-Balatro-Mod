local M = {}
M.chun_chun_seal = 'cp_chun_chun'

function M.card_present(card)
    return not (card.removed or card.destroyed or card.shattered or card.getting_sliced)
end

function M.each_playing_card(visit)
    if not G then return end
    local seen = {}
    local function scan(cards)
        for _, card in ipairs(cards or {}) do
            if not seen[card] then
                seen[card] = true
                if visit(card) then return true end
            end
        end
    end
    if scan(G.playing_cards) then return end
    for _, area in ipairs({'deck', 'hand', 'play', 'discard'}) do
        if scan(G[area] and G[area].cards) then return end
    end
end
local members = {
    j_cp_kamiya = true,
    j_cp_shinonome = true,
    j_cp_aslan = true,
    j_cp_makio = true,
    j_cp_saki = true,
}

function M.members()
    local seen, count = {}, 0
    for _, c in ipairs(G.jokers and G.jokers.cards or {}) do
        local key = c.config.center.key
        if members[key] and not c.debuff and not seen[key] then
            seen[key], count = true, count + 1
        end
    end
    return count
end

function M.blind_id()
    local game = G.GAME
    if not (game and game.blind and game.blind.config and game.blind.config.blind) then return '' end
    return table.concat({
        tostring(game.round_resets and game.round_resets.ante or 0),
        tostring(game.round or 0),
        tostring(game.blind.config.blind.key or ''),
    }, ':')
end

function M.hand_id()
    return M.blind_id() .. ':' .. tostring(G.GAME.hands_played)
end

function M.original(context)
    return not context.blueprint and not context.retrigger_joker
end

function M.enhanced(card)
    return next(SMODS.get_enhancements(card)) ~= nil
end

function M.plain(card)
    return not M.enhanced(card)
end

-- 石などランクを持たないカードは除外。順序は scoring_hand の左から。
function M.pair_cards(hand)
    local counts = {}
    for _, c in ipairs(hand or {}) do
        if not SMODS.has_no_rank(c) then
            local rank = c:get_id()
            counts[rank] = (counts[rank] or 0) + 1
        end
    end
    local chosen, result = nil, {}
    for _, c in ipairs(hand or {}) do
        if not SMODS.has_no_rank(c) then
            local rank = c:get_id()
            if (counts[rank] or 0) >= 2 and (not chosen or chosen == rank) then
                chosen = rank
                result[#result + 1] = c
            end
        end
    end
    return result
end

-- 二部マッチング: ワイルドも1枚に1スートのみ割り当てる。
function M.suits(hand, required)
    local assigned = {}
    local function assign(card, visited)
        if SMODS.has_no_suit(card) then return false end
        for _, suit in ipairs(SMODS.Suit.obj_buffer) do
            if not visited[suit] and card:is_suit(suit) then
                visited[suit] = true
                if not assigned[suit] or assign(assigned[suit], visited) then
                    assigned[suit] = card
                    return true
                end
            end
        end
        return false
    end
    local count = 0
    for _, card in ipairs(hand or {}) do
        if assign(card, {}) then count = count + 1 end
        if count >= required then return true end
    end
    return false
end

function M.used(card, field, token)
    local e = card.ability.extra
    if e[field] == token then return true end
    e[field] = token
    return false
end

return M
