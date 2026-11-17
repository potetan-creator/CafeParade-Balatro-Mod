local mod = SMODS.current_mod
local function load(path) return assert(SMODS.load_file(path))() end
local cp = load('common.lua')
cp.config = load('config.lua')
mod.cafeparade = cp
load('cake_set.lua')(cp)
load('badges.lua')(mod)
SMODS.Atlas {key = 'jokers', path = 'cafeparade_jokers.png', px = 71, py = 95}
SMODS.Atlas {key = 'satan_top', path = 'cafeparade_satan_top.png', px = 71, py = 95}
SMODS.Atlas {key = 'modicon', path = 'cafeparade_icon.png', px = 34, py = 34}
local atlas_columns = 5
for i, id in ipairs({'kamiya', 'shinonome', 'aslan', 'makio', 'saki', 'satan', 'cake_set', 'chocolate_spacial', 'plain_cakeroll', 'three_one_five'}) do
    local def = load('jokers/' .. id .. '.lua')(cp)
    def.key, def.rarity, def.cost = id, cp.config[id].rarity, cp.config[id].cost
    def.atlas, def.pos = 'jokers', {x = (i - 1) % atlas_columns, y = math.floor((i - 1) / atlas_columns)}
    def.unlocked, def.discovered = true, true
    if def.blueprint_compat == nil then def.blueprint_compat = true end
    def.eternal_compat, def.perishable_compat = true, true
    SMODS.Joker(def)
end
load('challenges/practice.lua')
load('challenges/member_challenges.lua')
load('deck_skins.lua')()
