get_json_value() {
  local chave="$1"
  local index="$2"
  awk -v passo="\"passo\": \"$index\"" -v chave="\"$chave\"" '
    $0 ~ passo { dentro_bloco=1 }
    dentro_bloco {
      if ($0 ~ chave) {
        gsub(/[",]/, "", $0)
        split($0, arr, ":")
        print arr[2]
        exit
      }
      if ($0 ~ /^\s*},/) {
        dentro_bloco=0
      }
    }
  ' "$jsonFile" | xargs
}
