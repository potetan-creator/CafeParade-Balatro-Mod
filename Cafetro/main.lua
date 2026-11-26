local mod = SMODS.current_mod
local function load(path)
    return assert(SMODS.load_file(path))()
end

local cp = load('common.lua')
cp.config = load('config.lua')
mod.cafeparade = cp
load('food.lua')(cp)
load('cake_set.lua')(cp)
load('goldpeople.lua')()
load('amehiko.lua')(cp)
load('badges.lua')(mod)

SMODS.Atlas {key = 'jokers', path = 'cafeparade_jokers.png', px = 71, py = 95}
SMODS.Atlas {key = 'satan_top', path = 'cafeparade_satan_top.png', px = 71, py = 95}
SMODS.Atlas {key = 'amehiko_front', path = 'cafeparade_amehiko_front.png', px = 71, py = 95}
SMODS.Atlas {key = 'modicon', path = 'cafeparade_icon.png', px = 34, py = 34}
SMODS.Atlas {key = 'chun_chun', path = 'cafeparade_chun_chun.png', px = 71, py = 95}
load('chun_chun.lua')(cp, mod)

local atlas_columns = 5
local joker_ids = {
    'kamiya', 'shinonome', 'aslan', 'makio', 'saki', 'satan',
    'cake_set', 'chocolate_spacial', 'plain_cakeroll', 'three_one_five',
    'embossing', 'sunsun', 'goldpeople', 'amehiko', 'sora',
    'koron', 'hazama', 'california_gurls',
}
for i, id in ipairs(joker_ids) do
    local def = load('jokers/' .. id .. '.lua')(cp)
    def.key, def.rarity, def.cost = id, cp.config[id].rarity, cp.config[id].cost
    def.atlas = 'jokers'
    def.pos = {x = (i - 1) % atlas_columns, y = math.floor((i - 1) / atlas_columns)}
    def.unlocked, def.discovered = true, true
    if def.blueprint_compat == nil then def.blueprint_compat = true end
    if def.eternal_compat == nil then def.eternal_compat = true end
    if def.perishable_compat == nil then def.perishable_compat = true end
    SMODS.Joker(def)
end

load('challenges/member_challenges.lua')
load('challenges/amehiko_test.lua')
load('challenges/sora_test.lua')
load('deck_skins.lua')()
