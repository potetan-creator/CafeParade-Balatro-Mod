return {
  descriptions = {
    Mod = {
      CafeParade = {name = "Cafetro!", text = {
        "アイドルマスターSideMに登場する",
        "アイドルユニット「CafeParade」を",
        "モチーフとしたジョーカーを中心に、",
        "新チャレンジ・トランプの見た目などを",
        "追加するMODです。",
        "このMODはChatGPT-6.1Sol Codexの",
        "力を借りて生成されています。",
        "Art:Potetan",
      }},
    },
    Joker = {
      j_cp_amehiko = {name = "葛之葉雨彦", text = {
        "所持する{C:dark_edition}ネガティブ{}カード",
        "1枚につき倍率{X:mult,C:white}X#1#{}を得る",
        "必ず{C:dark_edition}ネガティブ{}加工で出現",
        "{C:inactive}（現在 倍率{X:mult,C:white}X#2#{C:inactive}）",
      }},
      j_cp_goldpeople = {name = "金人間", text = {
        "{C:attention}道化師パック{}に",
        "{C:blue}コモン{}ジョーカーが",
        "出現しなくなる",
      }},
      j_cp_embossing = {name = "エンボスジョーカー", text = {
        "{C:attention}強化カード{}は得点時に",
        "倍率{C:mult}+#1#{}",
      }},
      j_cp_sunsun = {name = "スンスン", text = {
        "プレイした{C:attention}6{}のカードを",
        "{C:attention}#1#回{}追加で再発動させる",
        "{C:inactive,s:0.6}[Fan art of PUPPET SUNSUN (Unofficial)]",
      }},
      j_cp_kamiya = {name = "神谷幸広", text = {
        "得点カードのスーツが{C:attention}#1#種類{}以上なら",
        "{C:money}$#2#{}を得る。{C:green}#4#分の#3#{}の確率で",
        "{C:tarot}タロット{}カードを1枚生成",
        "{C:inactive}（空きが必要）",
      }},
      j_cp_shinonome = {name = "東雲荘一郎", text = {
        "{C:attention}ペア{}を含むハンドで倍率{C:mult}+#1#{}、",
        "得点後に倍率{X:mult,C:white}X#2#{}を得る",
        "{C:inactive}（現在 倍率{X:mult,C:white}X#3#{C:inactive}）",
      }},
      j_cp_aslan = {name = "アスラン＝ベルゼビュートⅡ世", text = {
        "{C:attention}強化カード{}が得点されるたびに",
        "倍率{X:mult,C:white}X#1#{}",
      }},
      j_cp_makio = {name = "卯月巻緒", text = {
        "得点した{C:attention}ペア{}のカードを",
        "{C:attention}#2#回{}追加で発動させる",
        "{C:inactive}(左から#1#枚まで)",
      }},
      j_cp_saki = {name = "水嶋咲", text = {
        "{C:attention}ワイルドカード{}が得点されるたびに",
        "倍率{X:mult,C:white}X#1#{}",
        "プレイした{C:attention}一番左のカード{}が得点し、",
        "{C:attention}未強化{}なら{C:attention}ワイルドカード{}に変える",
        "{C:inactive}(ブラインドごとに1回／#3#)",
      }},
      j_cp_three_one_five = {name = "THREE ONE FIVE", text = {
        "プレイしたハンドに{C:attention}3{}と{C:attention}5{}を含み、",
        "どちらかが得点すると",
        "倍率{X:mult,C:white}X#1#{}",
        "{C:inactive,s:0.6}アイドルマスターSideM×FiFS展 THREE ONE FIVE",
      }},
      j_cp_plain_cakeroll = {name = "ロールケーキ", text = {
        "得点するカードが{C:attention}#2#{}枚の場合、",
        "各カードは得点時に",
        "チップ{C:chips}+#1#{}を得る",
        "ラウンド終了時に",
        "{C:green}#4#分の#3#{}の確率で食べられる",
      }},
      j_cp_chocolate_spacial = {name = "Chocolate Spacial", text = {
        "{C:attention}フラッシュハウス{}で、ランダムな",
        "{C:spectral}スペクトル{}カードを最大{C:attention}#1#{}枚生成",
        "{C:inactive}(空きが必要)",
      }},
      j_cp_cake_set = {name = "ケーキセット", text = {
        "プレイしたハンドが{C:attention}ペア{}を含む場合、",
        "得点中のボスの{C:attention}スートによる",
        "{C:attention}カード無効化{}を解除",
        "ラウンド終了時に",
        "{C:green}#2#分の#1#{}の確率で食べられる",
      }},
      j_cp_satan = {name = "サタン", text = {
        "ジョーカースロット{C:attention}+#1#{}、倍率{X:mult,C:white}X#2#{}",
        "メンバー1人につき倍率{X:mult,C:white}X#3#{}を得る",
        "{C:attention}ボス{}撃破時、1人につき倍率{X:mult,C:white}X#4#{}を得る",
        "{C:inactive}（現在 倍率{X:mult,C:white}X#5#{C:inactive}）",
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
    challenge_names = {
      c_cp_amehiko_test = "葛之葉雨彦：ネガティブ動作確認",
      c_cp_solo_kamiya = "神谷幸広：三色のおもてなし",
      c_cp_solo_shinonome = "東雲荘一郎：一対ずつの積み重ね",
      c_cp_solo_aslan = "アスラン：闇のパティスリー",
      c_cp_solo_makio = "卯月巻緒：ふたり分のケーキ",
      c_cp_solo_saki = "水嶋咲：Makeup! ワンステージ",
      c_cp_finale = "Café Parade：悪魔のフルコース",
    },
    v_text = {
      ch_c_cp_amehiko_test = {
        "{C:attention}動作確認用{}：初期ネガティブは{C:attention}5枚{}",
        "雨彦の初期倍率は{X:mult,C:white}X2.25{}",
        "全{C:attention}8枚{}が初手にそろう",
        "売却・使用・破壊で{C:attention}倍率の変化{}を確認",
      },
      ch_c_cp_solo_member = {
        "主役は{C:attention}エターナル{}",
        "他のメンバーとサタンは出現しない",
      },
      ch_c_cp_no_faces = {"絵札のない{C:attention}40枚{}のデッキで開始"},
      ch_c_cp_finale_roster = {
        "{C:attention}5人とサタン{}はエターナル",
        "追加のジョーカーは入手できない",
      },
      ch_c_cp_finale_scaling = {"要求スコアの上昇率は{C:attention}パープルステーク{}相当"},
    },
  },
}
