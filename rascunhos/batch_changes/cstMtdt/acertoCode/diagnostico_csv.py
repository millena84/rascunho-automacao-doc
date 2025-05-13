def diagnosticar_csv(caminho):
    print(f"\n📄 Diagnóstico do arquivo: {caminho}")
    try:
        with open(caminho, 'rb') as fbin:
            raw = fbin.read(200)
            print("▶ Primeiros bytes (hex):", raw[:20].hex())

        with open(caminho, 'r', encoding='utf-8-sig', newline='') as f:
            linhas = [f.readline().strip() for _ in range(5)]
            for i, linha in enumerate(linhas, start=1):
                print(f"Linha {i}: {linha}")
    except Exception as e:
        print("❌ Erro de leitura:", e)

# 🔄 Altere os caminhos abaixo conforme o nome real dos seus arquivos
diagnosticar_csv('./1_metadados/_DadoCustomMetadata_ref.csv')
diagnosticar_csv('./1_metadados/_VincParCustom-CanalFormato.csv')
