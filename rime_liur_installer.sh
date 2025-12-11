#!/usr/bin/env bash
# created by Ryan Chou
# more info: https://blog.typeart.cc/rime-liur/guide/
RIME_FOLDER="$HOME"/Library/Rime
RIME_LIUR_FOLDER=$RIME_FOLDER/rime-liur-master
SQUIRREL_APP=/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel

echo "     +---------------------------+"
echo "     | RIME 蝦米輸入方案自動安裝小工具 |"
echo "     +---------------------------+"
echo "請注意！本工具將會執行以下作業："
echo "1. 透過 plum 初始化「預設所有輸入法」"
echo "2. 初始化「蝦米輸入方案」(若已存在則覆蓋)"
echo "3. 部署 RIME (安裝所有輸入法)"
echo
echo "※ 若 macOS 有開啟「勿擾模式」，將看不到 RIME 部署成功的通知，建議先關閉「勿擾模式」以掌握安裝進度"
echo "※ 若有自己的客制化版本尚未備份，請盡速按下 ctrl + c 終止作業！"
echo
if [ ! -f "$SQUIRREL_APP" ]; then
    echo "檢查到尚未安裝鼠鬚管！終止作業"
    echo "請先至鼠鬚管官方網站(https://rime.im/download/)下載並安裝鼠鬚管後，再次執行本工具"
    exit
fi
for i in {5..1};
do
    echo "將在 $i 秒後開始作業…";
    sleep 1
done
echo
#echo "+------------------------------------+"
#echo "| step 1: 使用 plum 初始化注音輸入法 |"
#echo "+------------------------------------+"
#curl -fsSL https://git.io/rime-install | bash
echo
echo "+----------------------------------+"
echo "| Step 2: 初始化 RIME 蝦米輸入方案 |"
echo "+----------------------------------+"
cd $RIME_FOLDER && curl -L https://github.com/hsuanyi-chou/rime-liur/archive/refs/heads/master.zip | tar xz
cp -R $RIME_LIUR_FOLDER/Rime/* $RIME_FOLDER
rm -rf $RIME_LIUR_FOLDER
echo
echo "+-----------------------+"
echo "| Step 3: 自動部署 RIME |"
echo "+-----------------------+"
"$SQUIRREL_APP" --reload
echo
echo "     +------------------------+"
echo "     | RIME 蝦米輸入方案 安裝完成 ✨ |"
echo "     +------------------------+"
echo
echo "設定加字加詞方式："
echo "1. 點擊右上角 鼠鬚管「㞢」"
echo "2. 點擊「用戶設定」(會打開資料夾)"
echo "3. 打開「openxiami_CustomWord.dict.yaml」輸入加字加詞"
echo "4. 點右上角 鼠鬚管「㞢」，按下「重新部署」生效加字加詞"
echo
echo "更多資訊請參考：https://blog.typeart.cc/rime-liur/guide/"