while true; do
  if [ -n "$1" ]; then
    url="$1"
    break
  else
    echo "請輸入 YouTube 影片的網址:"
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

# 使用 yt-dlp 下載音樂 (mp3 格式)，並嵌入字幕、縮圖和元數據
# 相同音樂不會覆蓋
yt-dlp -f "ba" --output "%(title)s.%(ext)s" --write-subs --embed-thumbnail --add-metadata --extract-audio --audio-format mp3 "$url"

# 查看字幕列表
# yt-dlp --list-subs "$url"

# 匯出資訊
# yt-dlp -j "$url" > info.json

echo "下載完成！"

read -rsp $'按任意鍵退出...\n' -n 1