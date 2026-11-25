local cp = dofile(ROOT..'/common.lua')
cp.config = dofile(ROOT..'/config.lua')
local mod, seal, challenge = {}, nil, nil
function HEX(value) return value end
function localize(key) return key end
SMODS = {
    has_no_rank = function(card) return card.stone end,
    has_no_suit = function(card) return card.stone end,
    Seal = function(def) seal = def end,
    DrawStep = function() end,
    Challenge = function(def) challenge = def end,
}
Card = {set_edition = function() end}
JokerDisplay = {Definitions = {}}
local function clone(t)
    if type(t) ~= 'table' then return t end
    local copy = {}
    for k, v in pairs(t) do copy[k] = clone(v) end
    return copy
end
local function set_seal(self, key) self.seal = key end
local function get_id(self) return self.rank end
local function playing(id, rank, suit, seal_key, edition)
    return {playing_card = id, rank = rank, base = {suit = suit}, seal = seal_key, edition = edition,
        set_seal = set_seal, get_id = get_id, enhancement = 'm_glass'}
end
function copy_card(source, destination, scale, id, strip_edition)
    local result = destination or {}
    local identity = id or result.playing_card
    for k, v in pairs(clone(source)) do result[k] = v end
    result.playing_card = identity
    if strip_edition then result.edition = nil end
    return result
end

dofile(ROOT..'/chun_chun.lua')(cp, mod)
dofile(ROOT..'/amehiko.lua')(cp)
local sora = dofile(ROOT..'/jokers/sora.lua')(cp)
local amehiko = dofile(ROOT..'/jokers/amehiko.lua')(cp)
dofile(ROOT..'/challenges/sora_test.lua')
local key = cp.chun_chun_seal
local function start_round()
    G = {
        GAME = {round = 1, hands_played = 0, round_resets = {ante = 1},
            blind = {config = {blind = {key = 'bl_small'}}}},
        playing_cards = {}, jokers = {cards = {{edition = {negative = true}}}},
        P_CENTERS = {}, play = {cards = {}}, hand = {cards = {}}, deck = {cards = {}}, discard = {cards = {}},
    }
end
local function stamp(hand, blueprint)
    G.play.cards = hand
    return sora:calculate(nil, {after = true, full_hand = hand, blueprint = blueprint})
end
local function advance() G.GAME.hands_played = G.GAME.hands_played + 1 end
local function finish()
    -- Steamodded leaves the last evaluated area in the global context.
    mod:calculate({end_of_round = true, main_eval = true, cardarea = G.discard})
end
local function score(card, area, retrigger)
    return seal:calculate(card, {main_scoring = true, cardarea = area, repetition = retrigger})
end

start_round()
assert(seal.key == 'chun_chun' and not seal:in_pool() and seal.weight == 0)
local left = playing(1, 2, 'Hearts')
local previous = playing(2, 2, 'Diamonds')
local current = playing(3, 2, 'Clubs')
local target = playing(4, 2, 'Spades', nil, {negative = true})
local duplicate = playing(5, 2, 'Spades')
local protected = playing(6, 2, 'Diamonds', 'other_mod_seal')
local same_suit = playing(7, 2, 'Hearts')
local wrong_rank = playing(8, 3, 'Spades')
local stone = playing(9, 2, 'Diamonds'); stone.stone = true
local formerly_played = playing(10, 2, 'Clubs')
local area_only = playing(11, 2, 'Diamonds')
G.playing_cards = {left, previous, current, target, duplicate, protected, same_suit, wrong_rank, stone, formerly_played}
G.deck.cards = {target, area_only}
mod:calculate({before = true, full_hand = {previous}})
mod:calculate({debuffed_hand = true, full_hand = {formerly_played}})
local saved = clone(G.GAME)
G.GAME = clone(saved)
advance()
assert(not sora:calculate(nil, {before = true, full_hand = {left}}) and not target.seal)
assert(stamp({left, current, wrong_rank}, 1), 'Blueprint can resolve before the original Joker')
assert(target.seal == key and area_only.seal == key and cp.chun_chun_remaining() == 7)
assert(not stamp({left, current, wrong_rank}), 'original and copy share this hand')
for _, card in ipairs({previous, current, duplicate, same_suit, wrong_rank, stone, formerly_played}) do
    assert(not card.seal)
end
assert(protected.seal == 'other_mod_seal' and target.edition.negative and target.enhancement == 'm_glass')
assert(cp.count_negative_equivalent() == 3, 'count the dual card and each physical object once')
assert(amehiko:calculate(nil, {joker_main = true}).xmult == 1.75)
assert(score(target, G.play).mult == 5 and score(target, G.play).mult == 5, 'each scoring pass gains Mult')
assert(not seal:calculate(target, {repetition = true, cardarea = G.play}))
assert(not score(target, G.hand))
target.debuff = true
assert(not score(target, G.play))
target.debuff = nil

local new = copy_card(target, nil, 1, 99)
assert(target.seal == key and not new.seal and new.edition.negative and new.enhancement == target.enhancement)
local into = playing(98, 3, 'Clubs', 'Red')
assert(copy_card(target, into) == into and not into.seal and into.playing_card == 98)
assert(copy_card(protected).seal == 'other_mod_seal')
assert(copy_card(target, nil, 1, 97, true).edition == nil)
target:set_seal(nil)
advance()
assert(not stamp({left, current}))
assert(not duplicate.seal, 'a cleared seal cannot reclaim the rank and suit this round')

local custom = {edition = {key = 'e_other_negative'}}
assert(not cp.is_negative_equivalent(custom))
cp.register_negative_edition('e_other_negative')
assert(cp.is_negative_equivalent(custom))
G.P_CENTERS.e_custom = {config = {negative = true}}
assert(cp.is_negative_equivalent({edition = {key = 'e_custom'}}))
assert(not cp.is_negative_equivalent({edition = {key = 'e_capacity', card_limit = 1}}))
assert(cp.is_negative_equivalent({edition = {type = 'negative'}}))

start_round()
assert(challenge:unlocked() and #challenge.deck.cards == 13 and #challenge.jokers == 3)
assert(challenge.jokers[1].id == 'j_blueprint' and challenge.jokers[2].id == 'j_cp_sora'
    and challenge.jokers[3].id == 'j_cp_amehiko')
local suits = {H = 'Hearts', D = 'Diamonds', C = 'Clubs', S = 'Spades'}
local anchors = {}
for id, spec in ipairs(challenge.deck.cards) do
    local card = playing(id, tonumber(spec.r), suits[spec.s], spec.g, spec.d and {negative = true})
    G.playing_cards[id] = card
    if spec.s == 'H' then anchors[tonumber(spec.r)] = card end
end
assert(cp.count_negative_equivalent() == 2)
for rank = 2, 4 do
    assert(stamp({anchors[rank]}, rank == 2 and 1 or nil))
    assert(not stamp({anchors[rank]}, 1))
    assert(cp.chun_chun_remaining() == 9 - (rank - 1) * 3)
    G.GAME = clone(G.GAME)
    G.playing_cards = clone(G.playing_cards)
    advance()
end
assert(amehiko:calculate(nil, {joker_main = true}).xmult == 3.5)
local extra_left = playing(100, 6, 'Hearts')
local extra_target = playing(101, 6, 'Clubs')
G.deck.cards = {extra_left, extra_target}
assert(not stamp({extra_left}) and not extra_target.seal, 'save/load preserves cap across ranks and copies')

local display = {joker_display_values = {}}
JokerDisplay.Definitions.j_cp_sora.calc_function(display)
JokerDisplay.Definitions.j_cp_amehiko.calc_function(display)
assert(display.joker_display_values.remaining == 0 and display.joker_display_values.x_mult == 3.5)

G.playing_cards, G.hand.cards = {}, G.playing_cards
local sealed = G.hand.cards[2]
assert(sealed.seal == key and score(sealed, G.play).mult == 5, 'seal scores without Sora')
mod:calculate({end_of_round = true, main_eval = true, individual = true, cardarea = G.hand})
assert(sealed.seal == key)
finish()
finish()
assert(not sealed.seal and sealed.edition.negative and sealed.enhancement == 'm_glass')
assert(G.hand.cards[13].seal == 'Red' and cp.count_negative_equivalent() == 2)
assert(not stamp({extra_left}), 'no late stamping after end of round')
G.GAME.round = 2
assert(stamp({extra_left}) and extra_target.seal == key and cp.chun_chun_remaining() == 8)

for _, lang in ipairs({'ja', 'en-us'}) do
    local loc = dofile(ROOT..'/localization/'..lang..'.lua')
    assert(loc.descriptions.Other.cp_chun_chun_seal.text[2]:find('dark_edition'))
    assert(loc.misc.labels.cp_chun_chun_seal == loc.descriptions.Other.cp_chun_chun_seal.name)
    assert(loc.misc.challenge_names.c_cp_sora_test and loc.misc.v_text.ch_c_cp_sora_test)
end
print('Chun-Chun: scoring, copies, owned-card API, saved cap, round expiry and challenge passed')
