return {
  descriptions = {
    Joker = {
      j_cp_kamiya = {name = "神谷幸広", text = {
        "得点カードのスーツが{C:attention}#1#種類{}以上なら",
        "{C:money}$#2#{}、{C:green}#4#分の#3#{}で{C:tarot}タロット{}1枚",
        "{C:inactive}(生成は空きが必要／ブラインドごとに1回)",
        "{C:inactive}(このブラインド：#6#)",
      }},
      j_cp_shinonome = {name = "東雲荘一郎", text = {
        "倍率{X:mult,C:white} X#3# {}",
        "{C:attention}ペア{}を含むハンドで倍率{C:mult} +#1#{}、",
        "得点後に{X:mult,C:white}X倍率{}が{C:attention}+#2#{}成長",
      }},
      j_cp_aslan = {name = "アスラン＝ベルゼビュートⅡ世", text = {
        "{C:attention}強化カード{}が得点されるたびに",
        "倍率{X:mult,C:white} X#1# {}",
      }},
      j_cp_makio = {name = "卯月巻緒", text = {
        "得点した{C:attention}ペア{}のカードを",
        "{C:attention}#2#回{}追加で発動させる",
        "{C:inactive}(左から#1#枚まで)",
      }},
      j_cp_saki = {name = "水嶋咲", text = {
        "{C:attention}ワイルドカード{}が得点されるたびに",
        "倍率{X:mult,C:white} X#1# {}",
        "プレイした{C:attention}最初のカード{}が",
        "{C:attention}未強化{}の場合、{C:attention}ワイルドカード{}に変える",
        "{C:inactive}(ブラインドごとに1回／#3#)",
      }},
      j_cp_plain_cakeroll = {name = "ロールケーキ", text = {
        "得点するカードが{C:attention}#2#{}枚の場合、",
        "各カードは得点時に",
        "{C:chips}+#1#{}チップを得る",
      }},
      j_cp_chocolate_spacial = {name = "Chocolate Spacial", text = {
        "{C:attention}フラッシュハウス{}で、ランダムな",
        "{C:spectral}スペクトル{}カードを最大{C:attention}#1#{}枚生成",
        "{C:inactive}(空きが必要)",
      }},
      j_cp_cake_set = {name = "ケーキセット", text = {
        "{C:attention}ワンペア{}の得点中のみ、",
        "ボスの{C:attention}スートによる",
        "{C:attention}カード無効化{}を解除",
      }},
      j_cp_satan = {name = "サタン", text = {
        "ジョーカースロット{C:attention} +#1#{}、倍率{X:mult,C:white} X#2# {}",
        "メンバー1人につき{X:mult,C:white}X倍率{}が{C:attention}+#3#{}",
        "{C:attention}ボス撃破{}ごとに1人につき{C:attention}+#4#{}成長",
        "{C:inactive}(#5#人／成長+#6#／現在{X:mult,C:white} X#7# {C:inactive})",
      }},
    },
    Other = {
      cp_suits = {name = "スーツの数え方", text = {"ワイルド1枚は1スーツ分", "スーツ変更の効果も反映"}},
      cp_pair = {name = "得点したペア", text = {"得点カードに同ランク2枚以上", "ストーンは除外"}},
      cp_makio = {name = "再発動の対象", text = {"左端のペアの組から2枚まで", "ツーペアでも合計2枚"}},
      cp_members = {name = "Café Paradeメンバー", text = {"神谷・東雲・アスラン・巻緒・咲", "各1人（無効化中は除外）", "成長分は人数が減っても残る"}},
    },
  },
  misc = {
    v_dictionary = {a_cp_growth = "成長！X#1#"},
    dictionary = {
      k_cp_wild = "Makeup!",
      k_cp_suit_relief = "スート制限解除",
      k_cp_unused = "未使用",
      k_cp_used = "使用済み",
    },
    challenge_names = {c_cp_practice = "Café Parade：お試しライブ"},
    v_text = {ch_c_cp_practice = {
      "Café Paradeの6枚を所持してスタート",
      "デッキは8枚、最初の手札に全カードがそろう",
    }},
  },
}
