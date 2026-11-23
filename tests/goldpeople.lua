-- Exercise the create-card boundary, with engine-owned pools and RNG inputs.
local count = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    count = count + 1
end
local gold = {config={center={key='j_cp_goldpeople'}}}
local rarity_roll, card_index, source_calls, weighted_calls = 0, 1, 0, 0
local seen_args, fail_creation
local temporary_pool = {}
G = {GAME={round_resets={ante=1},banned_keys={},used_jokers={}},
    jokers={cards={gold}}, pack_cards={}, shop_jokers={}, P_CENTERS={}}
local pools = {
    Common={'j_joker','j_mod_common'},
    Uncommon={'j_stencil','j_mod_uncommon'},
    Rare={'j_rare'}, Legendary={'j_cp_satan'},
}
for rarity, keys in pairs(pools) do
    local ids={Common=1,Uncommon=2,Rare=3,Legendary=4}
    for _,key in ipairs(keys) do G.P_CENTERS[key]={key=key,rarity=ids[rarity],set='Joker'} end
end
local function original(args)
    source_calls=source_calls+1; seen_args=args
    if fail_creation then error('original creation failed') end
    return {key=args.key and not G.GAME.banned_keys[args.key] and args.key or 'j_joker',
        edition=args.edition}, 'original second result'
end
SMODS = {create_card=original, ObjectTypes={Joker={rarities={
    {key='Common',weight=0.7},{key='Uncommon',weight=0.25},
    {key='Rare',weight=0.05},{key='Legendary',weight=0},
}}}, Rarities={Common={},Uncommon={},Rare={},Legendary={}}, optional_features={}}
-- Model the source pool boundary: sentinels, bans, duplicates and default fallback.
function get_current_pool(kind, rarity, legendary, append)
    eq(kind,'Joker'); eq(append,'buf','preserve in_pool source')
    for key in pairs(temporary_pool) do temporary_pool[key]=nil end
    local available=false
    for i,key in ipairs(pools[rarity]) do
        local blocked=G.GAME.banned_keys[key] or (G.GAME.used_jokers[key] and not G.GAME.showman)
        temporary_pool[i]=blocked and 'UNAVAILABLE' or key
        available=available or not blocked
    end
    if not available then
        for key in pairs(temporary_pool) do temporary_pool[key]=nil end
        temporary_pool[1]='j_joker'
    end
    return temporary_pool, kind..rarity..append
end
function pseudoseed(key) return key end
function pseudorandom(key) eq(key,'cp_goldpeople_rarity1buf'); return rarity_roll end
function pseudorandom_element(pool, seed)
    eq(seed,'Joker'..(G.P_CENTERS[pool[1]].rarity==2 and 'Uncommon' or 'Rare')..'buf')
    return pool[math.min(card_index,#pool)], math.min(card_index,#pool)
end
SMODS.poll_object=function(args)
    weighted_calls=weighted_calls+1
    eq(args.type,'Joker'); eq(args.guaranteed,true); eq(args.append,'buf')
    for _,entry in ipairs(args.pool) do
        eq(entry.type,'Joker'); eq(G.P_CENTERS[entry.key].rarity~=1,true)
    end
    return args.pool[math.min(card_index,#args.pool)].key
end
local original_rarities=SMODS.ObjectTypes.Joker.rarities
local original_common=SMODS.Rarities.Common
dofile(ROOT..'/goldpeople.lua')()
local function open(key) SMODS.OPENED_BOOSTER={config={center={key=key,kind='Buffoon'}}} end
local function args() return {set='Joker',area=G.pack_cards,skip_materialize=true,
    soulable=true,key_append='buf',edition='e_foil',stickers={'eternal'}} end
local function generate(key)
    if key then open(key) end
    local request=args()
    local card, extra=SMODS.create_card(request)
    eq(request.key,nil,'caller arguments are unchanged')
    eq(card.edition,'e_foil'); eq(seen_args.skip_materialize,true); eq(seen_args.soulable,true)
    eq(seen_args.stickers,request.stickers); eq(extra,'original second result')
    return card.key
end
for _,key in ipairs({'p_buffoon_normal_1','p_buffoon_normal_2','p_buffoon_jumbo_1','p_buffoon_mega_1'}) do
    rarity_roll=0; eq(generate(key),'j_stencil')
    rarity_roll=0.99; eq(generate(key),'j_rare')
end
-- Modded Common is also excluded; modded Uncommon remains eligible.
rarity_roll=0; card_index=2; eq(generate(),'j_mod_uncommon'); card_index=1
-- Remaining rarity odds are 5:1, rather than upgrading every Common to Rare.
rarity_roll=0.83; eq(generate(),'j_stencil')
rarity_roll=0.84; eq(generate(),'j_rare')
SMODS.Rarities.Rare.get_weight=function(self,weight,object_type)
    eq(object_type,SMODS.ObjectTypes.Joker); return weight*10
end
rarity_roll=0.5; eq(generate(),'j_rare')
SMODS.Rarities.Rare.get_weight=nil
G.GAME.uncommon_mod=0; rarity_roll=0; eq(generate(),'j_rare'); G.GAME.uncommon_mod=nil
-- Positive custom rarities remain supported; the zero-weight Legendary stays excluded.
table.insert(SMODS.ObjectTypes.Joker.rarities,{key='mod_special',weight=0.5})
SMODS.Rarities.mod_special={}
pools.mod_special={'j_mod_special'}
G.P_CENTERS.j_mod_special={key='j_mod_special',rarity='mod_special',set='Joker'}
SMODS.optional_features.object_weights=true
rarity_roll=0.99; eq(generate(),'j_mod_special')
SMODS.optional_features.object_weights=nil
table.remove(SMODS.ObjectTypes.Joker.rarities)
SMODS.Rarities.mod_special=nil
rarity_roll=0
-- Engine bans, used cards, Showman and exhausted-rarity fallback.
G.GAME.banned_keys.j_stencil=true; eq(generate(),'j_mod_uncommon')
G.GAME.used_jokers.j_mod_uncommon=true; eq(generate(),'j_rare')
G.GAME.showman=true; eq(generate(),'j_mod_uncommon'); G.GAME.showman=nil
G.GAME.banned_keys.j_rare=true; eq(generate(),'j_stencil','non-Common default if all pools exhausted')
eq(G.GAME.banned_keys.j_stencil,true,'fixed fallback restores ban')
fail_creation=true; eq(pcall(SMODS.create_card,args()),false); fail_creation=nil
eq(G.GAME.banned_keys.j_stencil,true,'fallback also restores ban on error')
G.GAME.banned_keys={}; G.GAME.used_jokers={}
-- Optional object-weight support is given only eligible cards of the chosen rarity.
SMODS.optional_features.object_weights=true
card_index=2; eq(generate(),'j_mod_uncommon'); eq(weighted_calls,2)
card_index=1; SMODS.optional_features.object_weights=nil
-- No effect for mod packs, other pack types or pack-like names.
for _,key in ipairs({'p_mod_buffoon_normal_1','p_buffoon_normal_3','p_mod_gold',
    'p_arcana_normal_1','p_celestial_normal_1','p_spectral_normal_1','p_standard_normal_1'}) do
    eq(generate(key),'j_joker')
end
open('p_buffoon_normal_1')
for _,cards in ipairs({{},{{config={center={key='j_cp_sunsun'}}}},
    {{debuff=true,config=gold.config}}}) do
    G.jokers.cards=cards; eq(generate(),'j_joker')
end
G.jokers.cards={gold,{debuff=true,config=gold.config}}; eq(generate(),'j_stencil')
G.jokers.cards={gold,gold}; eq(generate(),'j_stencil','does not stack')
G.jokers.cards={gold}; gold.debuff=true; eq(generate(),'j_joker'); gold.debuff=nil
G.jokers.cards={}; eq(generate(),'j_joker','sold'); G.jokers.cards={gold}
-- Shop, other generation areas and non-Jokers are untouched even with native pack open.
for _,area in ipairs({G.shop_jokers,G.jokers,{}}) do
    local request=args(); request.area=area
    SMODS.create_card(request); eq(seen_args,request)
end
local request=args(); request.set='Spectral'; SMODS.create_card(request); eq(seen_args,request)
SMODS.OPENED_BOOSTER=nil; request=args(); SMODS.create_card(request); eq(seen_args,request)
open('p_buffoon_normal_1')
request=args(); request.key='j_mod_common'; eq(SMODS.create_card(request).key,'j_stencil')
eq(request.key,'j_mod_common')
request=args(); request.key='j_mod_uncommon'; eq(SMODS.create_card(request).key,'j_mod_uncommon')
eq(seen_args,request,'already forced non-Common is preserved')
G.GAME.banned_keys.j_mod_uncommon=true
eq(SMODS.create_card(request).key,'j_stencil','banned forced key is reselected instead of falling back to Common')
G.GAME.banned_keys.j_mod_uncommon=nil
-- No global probability changes survive an error in the original creator.
fail_creation=true; eq(pcall(SMODS.create_card,args()),false); fail_creation=nil
eq(SMODS.ObjectTypes.Joker.rarities,original_rarities); eq(SMODS.Rarities.Common,original_common)
eq(original_rarities[1].weight,0.7); eq(original_rarities[2].weight,0.25)
eq(SMODS.Rarities.Common.get_weight,nil)
eq(generate(),'j_stencil','works after creation failure')
eq(source_calls>0,true)
print('Goldpeople assertions passed: '..count)
