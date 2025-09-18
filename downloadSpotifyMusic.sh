while true; do
  if [ -n "$1" ]; then
    url="$1"
    break
  else
    echo "請輸入 Spotify 音樂的網址:"
    read -r url
  fi

  if [ -z "$url" ]; then
    echo "網址不能為空，請重新輸入!"
    continue
  fi

  break;
done

OUTPUT_DIR="./DownloadedMusic"
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || exit

# 使用 spotdl 下載音訊，並自動並嵌入字幕、縮圖和元數據
# 相同音樂不會覆蓋
python3 -m spotdl "$url"

echo "下載完成！ 以儲存至 $OUTPUT_DIR 目錄中。"

read -rsp $'按任意鍵退出...\n' -n 1