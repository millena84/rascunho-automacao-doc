import subprocess

try:
    # Executa o script 51.py como subprocesso
    resultado = subprocess.run(
        ["python", "51.py"],  # ou "python3" conforme seu ambiente
        check=True,           # Lança erro se o script falhar
        capture_output=True,  # Captura stdout e stderr
        text=True             # Retorna saída como string (Python 3.7+)
    )
    print("Script 51.py executado com sucesso.")
    print("Saída do script:")
    print(resultado.stdout)

except subprocess.CalledProcessError as e:
    print("Erro ao executar 51.py")
    print("Código de saída:", e.returncode)
    print("Erro:")
    print(e.stderr)
except FileNotFoundError:
    print("Erro: o script 51.py não foi encontrado.")
except Exception as ex:
    print(f"Erro inesperado: {ex}")
