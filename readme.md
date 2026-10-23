### BINÁRIO TECH - AULA 04
## Histórico de Versionamento

=========================================================================

NOME: Ana Lívia Paixão e Bruno Rodrigues Garcia
E-MAIL: pessoal - analiviaany@gmail.com / brxnosong@gmail.com
        educacional - ana.l.paixao@edu.senai.br / b.garcia@edu.senai.br

DESCRIÇÃO DO PROJETO: Refatoração, resiliência de portas e automação 
de testes CRUD para a API de Gestão de Frotas de Veículos (frota_api.js) 
com captura dinâmica de IDs em Shell Script.

========================================================================

PRIMEIROS PASSOS:

1. Entrar
        - cd desafio_Live
        - cd aula04-refactor

2. Baixar ferramentas e dependências
        - npm install

3. Estrutura do Diretório de Pastas
        aula04-refactor
          |
          |-> frota_api.js
          |
          |-> teste_crud.sh
          |
          |-> auditoria_final.log
          |
          |-> package.json

(OBS: Outros arquivos que vem após instalação e readme.md estão sendo ignorados

========================================================================

VERSIONAMENTO: 

---

0.0.0 - frota_api.js

const express = require('express');
const app = express();
const PORT = 3000;

app.use(express.json());

// Banco de dados em memoria
let veiculos = [
	{ id: 1, placa: "ABC-1234", montadora: "Scania", modelo: "R450", status: "DISPONIVEL" },
	{ id: 2, placa: "XYZ-9876", montadora: "Mercedes Benz", modelo: "Actros", status: "EM ROTA" }
];

// 1. GET /api/v1/veiculos - Listar todos os veiculos (Suporta filtro por status query param)
app.get('/api/v1/veiculos', (req, res) => {
	const { status } = req.query;
	if (status) {
		const filtrados = veiculos.filter(v => v.status.toUpperCase() === status.toUpperCase());
		return res.status(200).json(filtrados);
	}
	res.status(200).json(veiculos);
});

// 2. GET /api/v1/veiculos/:id - Buscar veiculo por ID
app.get('/api/v1/veiculos/:id', (req, res) => {
	const id = parseInt(req.params.id);
	const veiculo = veiculos.find(v => v.id === id);
	if (!veiculo) {
		return res.status(404).json({ erro: "Veiculo nao encontrado na base de dados." });
	}
	res.status(200).json(veiculo);
});

// 3. POST /api/v1/veiculos - Cadastrar novo veiculo (Criacao)
app.post('/api/v1/veiculos', (req, res) => {
	const { placa, montadora, modelo } = req.body;
	if (!placa || !montadora || !modelo) {
		return res.status(400).json({ erro: "Campos 'placa', 'montadora' e 'modelo' sao obrigatorio."});
	}
	const novoVeiculo = {
		id: veiculos.length + 1,
		placa,
		montadora,
		modelo,
		status: "DISPONIVEL"
	};
	veiculos.push(novoVeiculo);
	res.status(201).json(novoVeiculo);
});

// 4. PATCH /api/v1/veiculos/:id/status - Atualizar status do veiculo
app.patch('/api/v1/veiculos/:id/status', (req, res) => {
	const id = parseInt(req.params.id);
	const { status } = req.body;
	const veiculo = veiculos.find(v => v.id === id);

	if (!veiculo) {
		return res.status(404).json({ erro: "Veiculo nao encontrado." });
	}
	if (!status) {
		return res.status(400).json({ erro: "O campo status eh obrigatorio."
		});
	}

	veiculo.status = status.toUpperCase();
	res.status(200).json({ mensagem: "Status atualizado com sucesso!", veiculo});
});

// 5. DELETE /api/v1/veiculos/:id - Remover veiculo da frota
app.delete('/api/v1/veiculos/:id', (req, res) => {
	const id = parseInt (req.params.id);
	const index = veiculos.findIndex(v => v.id === id);
	if (index === -1) {
		return res.status(404).json({ erro: "Veiculo nao encontrado." });
	}
	veiculos.splice(index, 1);
	res.status(200).json({ mensagem: `Veiculo ID ${id} removido com sucesso.`
	});
});

app.listen(PORT, () => {
	console.log(`[Binario Tech] API de Frotas rodando em http://localhost:${PORT}`);
});

// 6. PUT /api/v1/veiculos/:id - Substituir todos os dados de um veiculo
app.put('api/v1/veiculos/:id', (req, res) => {
	const id = parseInt(req.params.id);
	const index = veiculos.findIndex(v => v.id === id);

	if (index === -1) {
		return res.status(404).json({ erro: "Veiculo nao encontrado." });
	}
	const { placa, montadora, modelo, status } = req.body;

	if (!placa || !montadora || !modelo || !status) {
		return res.status(400).json({ erro: "Todos os campos (placa, montadora, modelo, status) sao obrigatorios para o PUT." });
	}
	veiculos[index] = {
		id, // Mantem o mesmo ID
		placa,
		montadora,
		modelo,
		status: status.toUpperCase()
	};

	res.status(200).json(veiculos[index]);
});

---

0.0.0 - teste_crud.sh

#!/bin/bash

API_URL="http://localhost:3000/api/v1/veiculos"
LOG_FILE="crud_result.log"

# Limpa o arquivo de log caso ele já exista e insere o cabeçalho
echo "=========================================" > "$LOG_FILE"
echo "Iniciando testes CRUD - $(date)" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# 1. CREATE: Cadastrando o primeiro veículo (ID 3)
echo -e "\n[1] Executando POST para cadastrar Veículo 1 (Volvo FH540)..." >> "$LOG_FILE"
curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{"placa": "DEF-5678", "montadora": "Volvo", "modelo": "FH540"}' >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 2. CREATE: Cadastrando o segundo veículo (ID 4)
echo -e "\n[2] Executando POST para cadastrar Veículo 2 (Iveco Stralis)..." >> "$LOG_FILE"
curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{"placa": "GHI-9012", "montadora": "Iveco", "modelo": "Stralis"}' >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 3. UPDATE: Atualizando todos os dados do veículo criado no passo 1 (ID 3) usando o novo PUT
echo -e "\n[3] Executando PUT para atualizar todos os dados do Veículo ID 3..." >> "$LOG_FILE"
curl -s -X PUT "$API_URL/3" \
  -H "Content-Type: application/json" \
  -d '{"placa": "DEF-5678", "montadora": "Volvo", "modelo": "FH540", "status": "EM MANUTENCAO"}' >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 4. DELETE: Deletando o veículo criado no passo 2 (ID 4)
echo -e "\n[4] Executando DELETE para remover o Veículo ID 4..." >> "$LOG_FILE"
curl -s -X DELETE "$API_URL/4" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 5. GET: Listando a frota final para confirmar as mudanças
echo -e "\n[5] Executando GET para listar a frota final..." >> "$LOG_FILE"
curl -s -X GET "$API_URL" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Finalização do Log
echo -e "\n=========================================" >> "$LOG_FILE"
echo "Testes finalizados com sucesso!" >> "$LOG_FILE"

echo "Testes executados! Verifique o arquivo '$LOG_FILE' para ver os resultados."

(OBS: Após a criacao de todos os arquivos, importante rodar node frota_api.js &)
========================================================================

MISSÕES:

Missão 1: Auditoria de Bugs no Código (Refactoring)
Cada dupla receberá ou criará uma refatoração do código do frota_api.js garantindo:
Mover todas as declarações de rotas (GET, POST, PUT, PATCH, DELETE) para antes do app.listen().
Corrigir qualquer variável de resposta e adicionar middlewares globais (express.json()).
Adicionar uma rota GET /api/v1/health que retorne o status da API, uptime do processo Node.js e uso de memória (process.uptime() e process.memoryUsage()).

0.0.1 - frota_api.js
require('dotenv').config();
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3004;

app.use(express.json());

// Banco de dados em memória
let veiculos = [
	{ id: 1, placa: "ABC-1234", montadora: "Scania", modelo: "R450", status: "DISPONIVEL" },
	{ id: 2, placa: "XYZ-9876", montadora: "Mercedes-Benz", modelo: "Actros", status: "EM_ROTA" }
];

// 1. GET /api/v1/veiculos - Listar todos os veículos (Suporta filtro por status query param)
app.get('/api/v1/veiculos', (req, res) => {
	const { status } = req.query;
	if (status) {
		const filtrados = veiculos.filter(v => v.status.toUpperCase() === status.toUpperCase());
		return res.status(200).json(filtrados);
	}
	res.status(200).json(veiculos);
});

// 2. GET /api/v1/veiculos/:id - Buscar veículo por ID
app.get ('/api/v1/veiculos/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const veiculo = veiculos.find(v => v.id === id);
    if (!veiculo) {
        return res.status(404).json({ erro: "Veiculo nao encontrado na base de dados." });
    }
    res.status(200).json(veiculo);
});

// 3. GET /api/v1/health - Mostrar o status da API
app.get ('/api/v1/health', (req, res) => {
	res.status(200).json({ status: "ONLINE", application: "BINARIO TECH API V1.1", uptime: process.uptime(), memory: process.memoryUsage() });
});

// 4. POST /api/v1/veiculos - Cadastrar novo veiculo (Criacao)
app.post('/api/v1/veiculos', (req, res) => {
    const { placa, montadora, modelo } = req.body;
    if (!placa || !montadora || !modelo) {
        return res.status(400).json({ erro: "Campos 'placa', 'montadora' e 'modelo' sao obrigatorios." });
    }
    const novoVeiculo = {
        id: veiculos.length + 1,
        placa,
        montadora,
        modelo,
        status: "DISPONIVEL"
    };
    veiculos.push(novoVeiculo);
    res.status(201).json(novoVeiculo);
});

// 5. PATCH /api/v1/veiculos/:id/status - Atualizar status do veiculo
app.patch('/api/v1/veiculos/:id/status', (req, res) => {
    const id = parseInt(req.params.id);
    const { status } = req.body;
    const veiculo = veiculos.find(v => v.id === id);

    if (!veiculo) {
        return res.status(404).json({ erro: "Veiculo nao encontrado." });
    }
    if (!status) {
        return res.status(400).json({ erro: "O campo 'status' e obrigatorio." });
    }

    veiculo.status = status.toUpperCase();
    res.status(200).json({ mensagem: "Status atualizado com sucesso!", veiculo });
});

// 6. DELETE /api/v1/veiculos/:id - Remover veiculo da frota
app.delete('/api/v1/veiculos/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const index = veiculos.findIndex(v => v.id === id);
    if (index === -1) {
        return res.status(404).json({ erro: "Veiculo nao encontrado." });
    }
    veiculos.splice(index, 1);
    res.status(200).json({ mensagem: `Veiculo ID ${id} removido com sucesso.` });
});

// 7. PUT /api/v1/veiculos/:id - Substituir todos os dados de um veiculo
app.put('/api/v1/veiculos/:id', (req, res) => {
        const id = parseInt(req.params.id);
        const index = veiculos.findIndex(v => v.id === id);

        if (index === -1) {
                return res.status(404).json({ erro: "Veiculo nao encontrado." });
        }
        const { placa, montadora, modelo, status } = req.body;

        if (!placa || !montadora || !modelo || !status) {
                return res.status(400).json({ erro: "Todos os campos (placa, montadora, modelo, status) sao obrigatorios para o PUT." });
        }
        veiculos[index] = {
                id, // Mantem o mesmo ID
                placa,
                montadora,
                modelo,
                status: status.toUpperCase()
        };

        res.status(200).json(veiculos[index]);
});

app.listen(PORT, () => {
    console.log(`[Binario Tech] API de Frotas rodando em http://localhost:${PORT}`);
});

Missão 2: Resiliência de Portas via Variáveis de Ambiente
Alterar o arquivo principal para ler a porta dinamicamente via process.env.PORT || 3000.
Testar a inicialização da API em portas diferentes diretamente pelo terminal Linux Debian sem alterar o código-fonte (ex: PORT=4000 node frota_api.js).

Versão 0.0.1 que foi feita na Missão 1 já foi atualizada com o process.env.PORT || 3004

Missão 3: Script Bash Dinâmico e Parâmetros CLI
Atualizar o script teste_crud.sh para aceitar a porta e a URL base dinamicamente como parâmetro de linha de comando:
Exemplo de execução: ./teste_crud.sh 4000
O script deve capturar o ID gerado no POST via jq e usá-lo automaticamente nas chamadas de PATCH, PUT e DELETE subsequentes (eliminando IDs fixos no script).

0.0.1 - teste_crud.sh

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

Missão 4: Automação Git & Relatório no Terminal
Executar o teste automatizado enviando a saída formatada para auditoria_final.log.
Criar um novo commit com mensagem no padrão Conventional Commits:
feat(aula04-refactor): adiciona resiliencia de portas e script bash dinamico
Fazer o git push para a main.

Entrega foi feita com o link do repositório do Desafio_LiveCoding, prints dos desafios e print do commit final
