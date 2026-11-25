local count = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    count = count + 1
end
local cp = dofile(ROOT..'/common.lua')
cp.config = dofile(ROOT..'/config.lua')
local step, edition_calls, sprites, draws = nil, {}, {}, {}
Card = {}
function Card:set_edition(edition, immediate, silent, extra)
    edition_calls[#edition_calls+1]={card=self,edition=edition,immediate=immediate,silent=silent,extra=extra}
    if self.added_to_deck and self.edition and self.edition.negative then
        G.jokers.config.card_limit=G.jokers.config.card_limit-1
    end
    self.edition=edition and edition~='e_polychrome' and edition or nil
    if self.edition and self.edition.negative then self.edition.key='e_negative' end
    if self.added_to_deck and self.edition and self.edition.negative then
        G.jokers.config.card_limit=G.jokers.config.card_limit+1
    end
    return 'native setter result', extra
end
SMODS = {DrawStep=function(def) step=def end}
G = {jokers={cards={},config={card_limit=5}},consumeables={cards={}},playing_cards={},
    deck={cards={}},hand={cards={}},play={cards={}},discard={cards={}},
    shop_jokers={cards={}},pack_cards={cards={}},ASSET_ATLAS={cp_amehiko_front='front-atlas'}}
dofile(ROOT..'/amehiko.lua')(cp)
local def=dofile(ROOT..'/jokers/amehiko.lua')(cp)
local function card(key, edition)
    return setmetatable({config={center={key=key or 'j_cp_amehiko',discovered=true}},
        edition=edition,ability={},children={center={}},T={x=1,y=2,w=3,h=4}}, {__index=Card})
end
local function negative(key) return card(key or 'j_other',{negative=true,key='e_negative'}) end
local amehiko=card()
eq(cp.negative_count(),0); eq(def:calculate(amehiko,{joker_main=true}).xmult,1)
def:set_ability(amehiko)
eq(amehiko.edition.negative,true)
eq(edition_calls[#edition_calls].immediate,true); eq(edition_calls[#edition_calls].silent,true)
G.jokers.cards={amehiko}
eq(cp.negative_count(),1); eq(def:calculate(amehiko,{joker_main=true}).xmult,1.25,'include self')
eq(cp.members(),0,'not a CafeParade unit member')
local other,consumable,playing=negative(),negative('c_mod_item'),negative('m_base')
G.jokers.cards={amehiko,other}; G.consumeables.cards={consumable}; G.playing_cards={playing}
eq(cp.negative_count(),4); eq(def:calculate(amehiko,{joker_main=true}).xmult,2)
-- The registry and card areas contain the same physical playing cards.
for _,key in ipairs({'deck','hand','play','discard'}) do G[key].cards={playing} end
eq(cp.negative_count(),4,'deduplicate all owned sources')
for _,key in ipairs({'deck','hand','play','discard'}) do
    local extra=negative('mod_playing_'..key)
    G[key].cards={playing,extra}
end
eq(cp.negative_count(),8,'include mod cards not yet in playing_cards')
eq(def:calculate(amehiko,{joker_main=true}).xmult,3)
local duplicate=card(); def:set_ability(duplicate)
G.jokers.cards[#G.jokers.cards+1]=duplicate
eq(cp.negative_count(),9); eq(def:calculate(amehiko,{joker_main=true}).xmult,3.25)
eq(def:calculate(amehiko,{joker_main=true,blueprint=1}).xmult,3.25,'copies use the same owned count')
for _,context in ipairs({{before=true},{after=true},{individual=true},{repetition=true},{end_of_round=true}}) do
    eq(def:calculate(amehiko,context),nil,'only main Joker scoring applies XMult')
end
G.shop_jokers.cards={negative()}; G.pack_cards.cards={negative()}
G.collection={cards={negative()}}
eq(cp.negative_count(),9,'shop, pack and collection previews are not owned')
-- A debuff does not remove the Negative edition or ownership.
consumable.debuff=true; playing.debuff=true; eq(cp.negative_count(),9)
for _,field in ipairs({'removed','destroyed','shattered','getting_sliced'}) do
    playing[field]=true; eq(cp.negative_count(),8,field..' cards stop counting immediately')
    playing[field]=nil
end
G.playing_cards={}; G.deck.cards={}; G.hand.cards={}; G.play.cards={}; G.discard.cards={}
G.consumeables.cards={}; G.jokers.cards={amehiko}
eq(cp.negative_count(),1); eq(def:loc_vars().vars[2],1.25,'selling or using cards updates the tooltip')
for _,edition in ipairs({{}, {foil=true},{polychrome=true},{card_limit=1,key='e_mod_slots'}}) do
    G.consumeables.cards={card('c_other',edition)}
    eq(cp.negative_count(),1,'extra capacity alone is not Negative')
end
G.consumeables.cards={card('c_mod_negative',{negative=true,key='e_mod_negative'})}
eq(cp.negative_count(),2,'mods can advertise the Negative flag')
G.consumeables.cards={card('c_negative',{key='e_negative'})}
eq(cp.negative_count(),2,'canonical edition key is recognized')
G.consumeables=nil; G.playing_cards=nil; G.deck=nil; G.hand=nil; G.play=nil; G.discard=nil
eq(cp.negative_count(),1,'missing optional areas are safe')
local game=G; G=nil; eq(cp.negative_count(),0); eq(def:loc_vars().vars[2],1); G=game

-- Edition requests from shops, forced generators, copies and edition effects
-- all pass through the native setter. No manual slot grant is added.
amehiko.added_to_deck=true; G.jokers.config.card_limit=6
for _,edition in ipairs({false,'e_foil','e_polychrome',{holo=true},{negative=true}}) do
    local result,extra=amehiko:set_edition(edition or nil,false,true,'opaque argument')
    eq(result,'native setter result'); eq(extra,'opaque argument')
    eq(amehiko.edition.negative,true); eq(G.jokers.config.card_limit,6,'no extra capacity on repeat')
    local call=edition_calls[#edition_calls]
    eq(call.immediate,false); eq(call.silent,true)
end
local ordinary=card('j_other')
local requested={foil=true}
ordinary:set_edition(requested,true,false,'normal')
eq(ordinary.edition,requested,'other Jokers preserve their requested edition')
eq(edition_calls[#edition_calls].extra,'normal')
amehiko.config.center.key='j_other'
amehiko:set_edition(nil,true,true)
eq(amehiko.edition,nil,'edition lock ends when transformed into another Joker')
amehiko.config.center.key='j_cp_amehiko'; def:set_ability(amehiko)
eq(amehiko.edition.negative,true)

-- Foreground: one cached child, glued to the card, drawn after negative shine
-- and before stickers. Render only dissolve, with zero added motion.
function Sprite(x,y,w,h,atlas,pos)
    local sprite={T={x=x,y=y,w=w,h=h},atlas=atlas,pos=pos,states={
        collide={can=true},hover={can=true},click={can=true},drag={can=true}}}
    function sprite:set_role(role) self.role=role end
    function sprite:draw_shader(shader,shadow,send,unused,reference,scale,rotate)
        draws[#draws+1]={sprite=self,shader=shader,shadow=shadow,send=send,
            reference=reference,scale=scale,rotate=rotate}
    end
    sprites[#sprites+1]=sprite
    return sprite
end
eq(step.key,'amehiko_front'); eq(step.order,25)
eq(step.conditions.facing,'front'); eq(step.conditions.vortex,false)
eq(def.soul_pos,nil); eq(def.soul_atlas,nil,'never enter the legendary floating-sprite pass')
step.func(ordinary); eq(#sprites,0,'other Jokers do not get a portrait')
amehiko.config.center.discovered=false
step.func(amehiko); eq(#sprites,0,'undiscovered preview is hidden')
amehiko.bypass_discovery_center=true
step.func(amehiko); step.func(amehiko)
eq(#sprites,1); eq(#draws,2,'draw once per pass and reuse the child')
local sprite=sprites[1]
eq(amehiko.children.cp_amehiko_front,sprite)
eq(sprite.atlas,'front-atlas'); eq(sprite.pos.x,0); eq(sprite.pos.y,0)
eq(sprite.T.x,amehiko.T.x); eq(sprite.T.y,amehiko.T.y)
eq(sprite.T.w,amehiko.T.w); eq(sprite.T.h,amehiko.T.h)
eq(sprite.role.major,amehiko); eq(sprite.role.draw_major,amehiko); eq(sprite.role.role_type,'Glued')
eq(sprite.float,false); eq(sprite.custom_draw,true,'do not auto-draw in the later others pass')
for _,state in pairs(sprite.states) do eq(state.can,false) end
for _,draw in ipairs(draws) do
    eq(draw.shader,'dissolve'); eq(draw.shadow,nil); eq(draw.send,nil)
    eq(draw.reference,amehiko.children.center); eq(draw.scale,0); eq(draw.rotate,0)
end
-- Native sprite rebuilding clears children; the next draw rebuilds the layer.
amehiko.children={center={}}
step.func(amehiko); eq(#sprites,2); eq(draws[#draws].reference,amehiko.children.center)
for _,lang in ipairs({'ja','en-us'}) do
    local entry=dofile(ROOT..'/localization/'..lang..'.lua').descriptions.Joker.j_cp_amehiko
    eq(entry.name,lang=='ja' and '葛之葉雨彦' or 'Amehiko Kuzunoha')
    local last=entry.text[#entry.text]
    eq(last:find('#2#',1,true)~=nil,true,'current XMult is in the final row')
    eq(last:find('{X:mult,C:white}',1,true)~=nil,true)
    eq(entry.text[2]:find('#2#',1,true),nil)
    eq(def:loc_vars().vars[1],0.25)
end
-- The requested in-game test challenge: emulate native starter events, which
-- ignore consumable editions, then verify every advertised count transition.
local challenge, events = nil, {}
SMODS.Challenge=function(d) challenge=d; d.id='c_cp_'..d.key end
function Event(event) return event end
dofile(ROOT..'/challenges/amehiko_test.lua')
eq(challenge:unlocked(),true)
eq(challenge.key,'amehiko_test'); eq(#challenge.jokers,3); eq(#challenge.consumeables,3)
eq(#challenge.deck.cards,8)
local params={}
for _,modifier in ipairs(challenge.rules.modifiers) do params[modifier.id]=modifier.value end
eq(params.hand_size,8); eq(params.dollars,50); eq(params.hands,6); eq(params.discards,6)
eq(params.joker_slots,5); eq(params.consumable_slots,2)
G={GAME={challenge=challenge.id}, E_MANAGER={add_event=function(_,e) events[#events+1]=e end}}
challenge:apply()
eq(#events,1); eq(events[1].blocking,false); eq(events[1].blockable,false)
eq(events[1].func(),false,'wait for starter events without blocking them')
local strength=card('c_strength')
G.consumeables={cards={strength}}
eq(events[1].func(),false,'one consumable is not enough to finish initialization')
eq(strength.edition.negative,true)
local before=#edition_calls
eq(events[1].func(),false); eq(#edition_calls,before,'do not set the same edition twice while waiting')
G.consumeables.cards[2]=card('c_pluto'); G.consumeables.cards[3]=card('c_hanged_man')
eq(events[1].func(),true); eq(G.GAME.cp_amehiko_test_editions,true)
eq(G.consumeables.cards[2].edition.negative,true); eq(G.consumeables.cards[3].edition,nil)
G.jokers={cards={},config={card_limit=5}}
for _,spec in ipairs(challenge.jokers) do
    eq(spec.eternal,nil,'starter Jokers remain sellable')
    local target=card(spec.id)
    if spec.id=='j_cp_amehiko' then def:set_ability(target) end
    if spec.edition then target:set_edition({[spec.edition]=true},true,true) end
    G.jokers.cards[#G.jokers.cards+1]=target
end
G.playing_cards={}
local negative_playing
for _,spec in ipairs(challenge.deck.cards) do
    local target=card('m_base',spec.d and {[spec.d]=true})
    G.playing_cards[#G.playing_cards+1]=target
    if target.edition then negative_playing=target; eq(spec.s,'H'); eq(spec.r,'2') end
end
G.hand={cards=G.playing_cards}
eq(cp.negative_count(),5)
eq(def:calculate(G.jokers.cards[1],{joker_main=true}).xmult,2.25,'advertised starting multiplier')
table.remove(G.consumeables.cards,1)
eq(cp.negative_count(),4); eq(def:loc_vars().vars[2],2,'use Negative Strength')
table.remove(G.consumeables.cards,1)
eq(cp.negative_count(),3); eq(def:loc_vars().vars[2],1.75,'use Negative Pluto')
table.remove(G.consumeables.cards,1)
eq(cp.negative_count(),3,'using the normal Hanged Man alone does not change count')
negative_playing.destroyed=true
eq(cp.negative_count(),2); eq(def:loc_vars().vars[2],1.5,'destroy the Negative playing card')
table.remove(G.jokers.cards,2)
eq(cp.negative_count(),1); eq(def:loc_vars().vars[2],1.25,'sell the Negative Joker')
table.remove(G.jokers.cards,2)
eq(cp.negative_count(),1,'selling a normal Joker does not change count')
before=#edition_calls
challenge:apply(); eq(events[#events].func(),true)
eq(#edition_calls,before); eq(#G.consumeables.cards,0,'do not respawn used cards on repeated setup')
G.GAME={challenge=challenge.id}
challenge:apply(); local pending=events[#events]
G.GAME={challenge='c_cp_solo_saki'}
eq(pending.func(),true,'old events cannot modify another run')
eq(#edition_calls,before)
for _,lang in ipairs({'ja','en-us'}) do
    local loc=dofile(ROOT..'/localization/'..lang..'.lua').misc
    eq(type(loc.challenge_names[challenge.id]),'string')
    eq(#loc.v_text.ch_c_cp_amehiko_test,4)
end
print('Amehiko ability, foreground and test-challenge assertions passed: '..count)
