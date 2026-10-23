#!/bin/bash

# Configuração dinâmica de Porta via parâmetros de linha de comando (padrão: 3004)
PORT=${1:-3004}

API_URL="http://localhost:${PORT}/api/v1/veiculos"
LOG_FILE="auditoria_final.log"

# Limpa o arquivo de log caso ele já exista e insere o cabeçalho
echo "=========================================" > "$LOG_FILE"
echo "Iniciando testes CRUD - $(date)" >> "$LOG_FILE"
echo "API URL: $API_URL" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# 1. CREATE: Cadastrando o primeiro veículo
echo -e "\n[1] Executando POST para cadastrar Veículo 1 (Volvo FH540)..." >> "$LOG_FILE"
RESP_1=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{"placa": "DEF-5678", "montadora": "Volvo", "modelo": "FH540"}')

# Registra a resposta no log sem quebrar se não for JSON
echo "$RESP_1" | jq . >> "$LOG_FILE" 2>&1 || echo "$RESP_1" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Extrai o ID gerado
ID_1=$(echo "$RESP_1" | jq -r '.id // empty' 2>/dev/null)

if [ -z "$ID_1" ]; then
  echo "Erro: Não foi possível obter o ID do Veículo 1. Resposta da API:"
  echo "$RESP_1"
  exit 1
fi

# 2. CREATE: Cadastrando o segundo veículo
echo -e "\n[2] Executando POST para cadastrar Veículo 2 (Iveco Stralis)..." >> "$LOG_FILE"
RESP_2=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{"placa": "GHI-9012", "montadora": "Iveco", "modelo": "Stralis"}')

echo "$RESP_2" | jq . >> "$LOG_FILE" 2>&1 || echo "$RESP_2" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Extrai o ID gerado
ID_2=$(echo "$RESP_2" | jq -r '.id // empty' 2>/dev/null)

if [ -z "$ID_2" ]; then
  echo "Erro: Não foi possível obter o ID do Veículo 2. Resposta da API:"
  echo "$RESP_2"
  exit 1
fi

# 3. UPDATE: Atualizando o veículo criado no passo 1 ($ID_1)
echo -e "\n[3] Executando PUT para atualizar todos os dados do Veículo ID ${ID_1}..." >> "$LOG_FILE"
curl -s -X PUT "$API_URL/${ID_1}" \
  -H "Content-Type: application/json" \
  -d '{"placa": "DEF-5678", "montadora": "Volvo", "modelo": "FH540", "status": "EM MANUTENCAO"}' >> "$LOG_FILE" 2>&1
echo "" >> "$LOG_FILE"

# 4. DELETE: Deletando o veículo criado no passo 2 ($ID_2)
echo -e "\n[4] Executando DELETE para remover o Veículo ID ${ID_2}..." >> "$LOG_FILE"
curl -s -X DELETE "$API_URL/${ID_2}" | jq . >> "$LOG_FILE" 2>&1
echo "" >> "$LOG_FILE"

# 5. GET: Listando a frota final
echo -e "\n[5] Executando GET para listar a frota final..." >> "$LOG_FILE"
curl -s -X GET "$API_URL" | jq . >> "$LOG_FILE" 2>&1
echo "" >> "$LOG_FILE"

# Finalização do Log
echo -e "\n=========================================" >> "$LOG_FILE"
echo "Testes finalizados com sucesso!" >> "$LOG_FILE"

echo "Testes executados! Verifique o arquivo '$LOG_FILE' para ver os resultados."
