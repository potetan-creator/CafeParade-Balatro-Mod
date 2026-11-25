-- Food lifetime and hidden Makio weighting at real module boundaries.
local count = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    count = count + 1
end
local cp = dofile(ROOT..'/common.lua')
cp.config = dofile(ROOT..'/config.lua')
G = {GAME={round=1,round_resets={ante=1},banned_keys={},
    blind={config={blind={key='bl_small'}}}}, jokers={cards={}},play={},pack_cards={},
    P_CENTERS={},C={FILTER='filter'}}
local rolls, destroys, bonus_draws, selector_calls = {}, {}, 0, 0
local success, multiplier, chosen_index, bonus_roll = false, 1, 1, 1
local function original_select(pool, seed, args)
    selector_calls=selector_calls+1
    return pool[chosen_index], chosen_index
end
pseudorandom_element=original_select
function pseudoseed(key) return key end
function pseudorandom(seed)
    if seed:find('cp_goldpeople_rarity',1,true) then return 0.99 end
    eq(seed,'cp_food_makio'); bonus_draws=bonus_draws+1; return bonus_roll
end
function localize(key) return key end
SMODS = {
    get_probability_vars=function(card,n,d,id) return n*multiplier,d end,
    pseudorandom_probability=function(card,seed,n,d,id)
        rolls[#rolls+1]={card=card,seed=seed,n=n,d=d,id=id}; return success
    end,
    destroy_cards=function(cards,args)
        eq(args.pinch_anim,true,'use native food-removal animation')
        local queued={}
        for _,card in ipairs(cards) do
            if not card.protected then
                card.getting_sliced=true; card.destroyed=true
                queued[#queued+1]=card; destroys[#destroys+1]=card
            end
        end
        return queued
    end,
}
dofile(ROOT..'/food.lua')(cp)
local defs={}
for _,id in ipairs({'cake_set','plain_cakeroll','makio'}) do
    defs[id]=dofile(ROOT..'/jokers/'..id..'.lua')(cp)
end
local function card(id, extra)
    return {config={center={key='j_cp_'..id}},ability={extra=extra}}
end
local function round()
    G.GAME.round=G.GAME.round+1
    return {end_of_round=true,main_eval=true,game_over=false}
end

for id,odds in pairs({cake_set=5,plain_cakeroll=10}) do
    local def=defs[id]
    eq(def.pools.Food,true); eq(def.eternal_compat,false)
    local food=card(id)
    G.jokers.cards={food}; success=false
    local ctx=round(); local before=#rolls
    eq(def:calculate(food,ctx),nil); eq(#rolls,before+1)
    eq(rolls[#rolls].d,odds); eq(rolls[#rolls].n,1)
    eq(rolls[#rolls].seed,rolls[#rolls].id)
    eq(rolls[#rolls].card,food)
    eq(type(food.ability.extra),'table','migrate old saves lazily')
    eq(def:calculate(food,ctx),nil); eq(#rolls,before+1,'one roll per round even on survival')
    -- Saved guard prevents a repeat if end-of-round evaluation is resumed.
    local loaded=card(id,{food_round=food.ability.extra.food_round})
    eq(def:calculate(loaded,ctx),nil); eq(#rolls,before+1)
    ctx=round(); success=true
    local effect=def:calculate(food,ctx)
    eq(effect.message,'k_eaten_ex'); eq(effect.colour,G.C.FILTER)
    eq(#rolls,before+2); eq(food.destroyed,true); eq(destroys[#destroys],food)
    eq(cp.makio_food_weight(),1,'eaten card immediately stops attracting Makio')
    eq(def:calculate(food,ctx),nil); eq(#rolls,before+2)
    -- Actual engine removal happens after the returned popup.
    food.removed=true; G.jokers.cards={}
    eq(cp.makio_food_weight(),1)
    for _,flags in ipairs({{main_eval=false},{blueprint=1},{retrigger_joker=true},
        {individual=true},{repetition=true},{game_over=true},{end_of_round=false}}) do
        local target=card(id); local context=round()
        for key,value in pairs(flags) do context[key]=value end
        before=#rolls
        eq(def:calculate(target,context),nil); eq(#rolls,before,'non-original/non-winning contexts never roll')
    end
    for _,field in ipairs({'debuff','removed','destroyed','getting_sliced'}) do
        local target=card(id); target[field]=true
        before=#rolls; eq(def:calculate(target,round()),nil); eq(#rolls,before)
    end
    local eternal=card(id); eternal.ability.eternal=true
    before=#rolls; eq(def:calculate(eternal,round()),nil); eq(#rolls,before,'keep existing Eternal saves safe')
    local protected=card(id); protected.protected=true
    G.jokers.cards={protected}
    eq(def:calculate(protected,round()),nil,'native destruction protections take priority')
    eq(protected.destroyed,nil); eq(cp.makio_food_weight(),1.25)
    local first,second=card(id),card(id)
    local context=round(); before=#rolls
    eq(def:calculate(first,context).message,'k_eaten_ex')
    eq(def:calculate(second,context).message,'k_eaten_ex')
    eq(#rolls,before+2,'separate physical food cards roll independently')
    multiplier=2
    local variables=def:loc_vars({},card(id)).vars
    local index=id=='cake_set' and 1 or 3
    eq(variables[index],2); eq(variables[index+1],odds,'show modified probability')
    multiplier=1
end

local cake,roll=card('cake_set'),card('plain_cakeroll')
for _,cards in ipairs({{cake},{roll},{cake,roll},{cake,cake,roll,roll}}) do
    G.jokers.cards=cards
    eq(cp.makio_food_weight(),1.25)
    eq(defs.makio:get_weight(10),12.5,'modern weighted draws do not stack')
end
for _,food in ipairs({cake,roll}) do
    for _,field in ipairs({'debuff','removed','destroyed','getting_sliced'}) do
        G.jokers.cards={food}; food[field]=true
        eq(cp.makio_food_weight(),1); eq(defs.makio:get_weight(10),10)
        food[field]=nil
    end
end
G.jokers.cards={cake,roll}; cake.debuff=true
eq(cp.makio_food_weight(),1.25,'other active food retains attraction')
roll.debuff=true; eq(cp.makio_food_weight(),1)
cake.debuff=nil; roll.debuff=nil
G.jokers.cards={card('makio')}; eq(defs.makio:get_weight(10),10)

local keys={'j_cp_makio','j_other_rare','j_third_rare'}
for _,key in ipairs(keys) do G.P_CENTERS[key]={key=key,set='Joker',rarity=3} end
G.P_CENTERS.c_soul={key='c_soul',set='Spectral'}
G.jokers.cards={cake,roll}
-- Exhaust the independent RNG grid. 1.25/(1.25+1+1)=5/13,
-- versus 1/3 without food; the other two outcomes each retain weight 1.
local frequencies={}
for i=1,3 do
    chosen_index=i
    for j=0,12 do
        bonus_roll=(j+0.5)/13
        local key,index=pseudorandom_element(keys,'vanilla_seed')
        eq(keys[index],key,'preserve the value/key return contract')
        frequencies[key]=(frequencies[key] or 0)+1
    end
end
eq(frequencies.j_cp_makio,15); eq(frequencies.j_other_rare,12); eq(frequencies.j_third_rare,12)
eq(#keys,3,'do not mutate the engine pool')
chosen_index=2; bonus_roll=0
local value,index=pseudorandom_element(keys,'vanilla_seed')
eq(value,'j_cp_makio'); eq(index,1,'cloned Goldpeople Joker pools are supported too')
for _,pool in ipairs({{'j_other_rare','j_third_rare'}, {'j_cp_makio','c_soul'},
    {{rank=2},{rank=3}}, {}, {left='j_cp_makio',right='j_other_rare'}}) do
    local before=bonus_draws
    local expected,key=original_select(pool,'other_seed')
    local result,result_key=pseudorandom_element(pool,'other_seed')
    eq(result,expected); eq(result_key,key); eq(bonus_draws,before,'unrelated pools do not consume bias RNG')
end
local before=bonus_draws
eq(pseudorandom_element(keys,'filtered',{in_pool=function() return false end}),'j_other_rare')
eq(bonus_draws,before,'do not override callers with dynamic in_pool filters')
G.GAME.banned_keys.j_cp_makio=true
eq(pseudorandom_element(keys,'banned'),'j_other_rare'); eq(bonus_draws,before)
G.GAME.banned_keys={}
G.jokers.cards={}
eq(pseudorandom_element(keys,'no_food'),'j_other_rare'); eq(bonus_draws,before)
eq(selector_calls>0,true)

-- Integration: Goldpeople retains its native-pack restriction and rare roll,
-- while Makio gets the same legacy bias inside its copied eligible pool.
G.jokers.cards={cake,roll,card('goldpeople')}
G.P_CENTERS.j_stencil={key='j_stencil',set='Joker',rarity=2}
SMODS.ObjectTypes={Joker={rarities={{key='Uncommon',weight=0.25},{key='Rare',weight=0.05}}}}
SMODS.Rarities={Uncommon={},Rare={}}
SMODS.create_card=function(args) return {key=args.key or 'j_joker'} end
SMODS.OPENED_BOOSTER={config={center={key='p_buffoon_normal_1'}}}
function get_current_pool(set,rarity,legendary,append)
    return rarity=='Rare' and keys or {'j_stencil'}, 'pool_key'
end
dofile(ROOT..'/goldpeople.lua')()
eq(SMODS.create_card({set='Joker',area=G.pack_cards,key_append='buf'}).key,'j_cp_makio')
SMODS.OPENED_BOOSTER.config.center.key='p_mod_buffoon'
eq(SMODS.create_card({set='Joker',area=G.pack_cards,key_append='buf'}).key,'j_joker')

for _,lang in ipairs({'ja','en-us'}) do
    local loc=dofile(ROOT..'/localization/'..lang..'.lua')
    for id,variables in pairs({cake_set={1,5},plain_cakeroll={50,2,1,10}}) do
        local entry=loc.descriptions.Joker['j_cp_'..id]
        local text=table.concat(entry.text,' ')
        eq(text:find(lang=='ja' and '食べられる' or 'eaten',1,true)~=nil,true)
        eq(text:find('1.25',1,true),nil,'no hidden weight in tooltip')
        eq(text:find(lang=='ja' and '巻緒' or 'Makio',1,true),nil,'do not disclose hidden attraction')
        eq(#entry.text,5,'concise effect and decay without extra tooltip')
        local queue={}
        local actual=defs[id]:loc_vars(queue,card(id)).vars
        eq(#queue,0)
        for i,value in ipairs(variables) do eq(actual[i],value) end
    end
end
print('Food lifetime, localization and Makio weight assertions passed: '..count)
