get_json_value() {
  node -e "
    const path = '$1'.split('.');
    let data = require('./$CONFIG_FILE');
    for (const key of path) {
      data = data[key];
      if (data === undefined) {
        console.error('❌ Caminho inválido: $1');
        process.exit(1);
      }
    }
    // Remove espaços e quebras de linha
    const clean = typeof data === 'string' ? data.trim() : data;
    console.log(clean);
  "
}
