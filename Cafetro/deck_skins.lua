-- Steamodded標準のデッキカスタマイズに追加する選択式スキン。
-- 画像: assets/{1x,2x}/saki_cards_{lc,hc}.png
-- 元のトランプや、ユーザーが選んでいるスキンは書き換えない。
return function()
    SMODS.Atlas {key = 'saki_cards_lc', path = 'saki_cards_lc.png', px = 71, py = 95}
    SMODS.Atlas {key = 'saki_cards_hc', path = 'saki_cards_hc.png', px = 71, py = 95}
    for _, suit in ipairs({'Hearts', 'Clubs', 'Diamonds', 'Spades'}) do
        SMODS.DeckSkin {
            key = 'saki_' .. suit,
            suit = suit,
            loc_txt = {ja = '水嶋咲', ['en-us'] = 'Saki Mizushima'},
            palettes = {
                {
                    key = 'lc',
                    atlas = 'cp_saki_cards_lc',
                    ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'},
                    display_ranks = {'Jack', 'Queen', 'King'},
                    pos_style = 'deck',
                },
                {
                    key = 'hc',
                    atlas = 'cp_saki_cards_hc',
                    ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'},
                    display_ranks = {'Jack', 'Queen', 'King'},
                    pos_style = 'deck',
                    hc_default = true,
                },
            },
        }
    end
end
