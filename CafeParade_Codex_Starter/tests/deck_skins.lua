-- 登録構成だけの検証。元PNGの寸法/画素と実ゲーム表示は別途確認する。
local atlases, skins = {}, {}
SMODS = {
    Atlas = function(def) atlases[#atlases + 1] = def end,
    DeckSkin = function(def) skins[#skins + 1] = def end,
}
G = nil -- 設定や既存カードへの直接書き込みがあれば失敗する。
assert(loadfile(ROOT .. '/deck_skins.lua'))()()
assert(#atlases == 2 and #skins == 4)
local seen, registered = {}, {}
for _, atlas in ipairs(atlases) do
    assert(atlas.px == 71 and atlas.py == 95)
    registered['cp_' .. atlas.key] = true
    assert(not atlas.prefix_config, 'must not overwrite a vanilla atlas')
end
for _, skin in ipairs(skins) do
    assert(not seen[skin.suit]); seen[skin.suit] = true
    assert(skin.key ~= 'default_' .. skin.suit)
    assert(skin.loc_txt.ja == '水嶋咲')
    assert(#skin.palettes == 2)
    for i, palette in ipairs(skin.palettes) do
        assert(registered[palette.atlas])
        assert(palette.key == (i == 1 and 'lc' or 'hc'))
        assert(#palette.ranks == 13 and palette.ranks[13] == 'Ace')
        assert(palette.pos_style == 'deck')
        assert(#palette.display_ranks == 3)
    end
    assert(skin.palettes[2].hc_default)
end
assert(seen.Hearts and seen.Clubs and seen.Diamonds and seen.Spades)
print('Deck skin registration: four suits, two palettes and all thirteen ranks passed ')
