# Conversor de moedas

![Circle CI Build](https://img.shields.io/circleci/build/github/guigaoliveira/currency_converter/main?token=343f12bc81a3d93b7c268b8d7ab719bb0f755d0a) 
[![Coverage Status](https://coveralls.io/repos/github/guigaoliveira/currency_converter/badge.svg?t=PJyCB8)](https://coveralls.io/github/guigaoliveira/currency_converter)

Esse projeto tem como objetivo expor uma API REST que permite a conversão de valores em moedas diferentes. As taxas de câmbio são atualizadas a partir de uma API externa. As moedas suportadas atualmente são BRL, USD, EUR E JPY.

## Como rodar

Primeiramente, clone o projeto com git ou baixe os arquivos.
Esse projeto precisa que você tenha instalado em sua máquina as versões mais recentes de:

- Docker
- Docker-compose
- Erlang
- Elixir

Com as ferramentas instaladas, precisamos subir os containers Docker, para subir o banco de dados PostgreSQL. Faremos isso executando no terminal dentro da pasta do projeto o comando `docker-compose up -d`

Para executar o servidor do Phoenix:

- Entre na pasta do projeto
- Instale as dependências com `mix deps.get`
- Crie e migre o banco de dados com `mix ecto.setup`
- Execute `mix phx.server` para startar o servidor

A servidor estará rodando em [http://localhost:4000](http://localhost:4000). A versão 1 da API tem host em
[http://localhost:4000/api/v1/](http://localhost:4000/api/v1/).

## Documentação da API

A documentação da API se encontra na pasta [docs/api.apib](docs/api.apib) e é escrita no formato [API Blueprint](https://apiblueprint.org/). A documentação pode ser escrita usando [Apiary](https://apiary.io/) e testada usando [Dredd](https://github.com/apiaryio/dredd).
Para melhor visualização existe o arquivo em HTML [docs/api.html](docs/api.html) que é possível visualizar no browser, esse arquivo foi gerado usando [Aglio](https://github.com/danielgtaylor/aglio).

## Arquitetura

O projeto usa o Phoenix Framework para criar a API REST e expor os endpoints necessários. Essa API recebe e retorna dados no formato JSON. Para extrair os dados de taxa de câmbio atualmente se usa a API externa [exchangeratesapi.io](https://exchangeratesapi.io/). Um job é executado de tempos em tempos para obter os dados da API externa, fazendo uma requisição HTTP e armazenando esses dados em cache distribuído. Com isso, os controllers da API podem ler do cache e se possível podem realizar os cálculos necessários ao atender as solicitações.

## Ferramentas e bibliotecas utilizadas

- Phoenix Framework
  - Para construir a API REST
- Ecto/PostgreSQL
  - Para permitir persistir os dados de transações de conversão em banco de dados
- Tesla
  - Para construir o HTTP Client para fazer requisições a API Externa
- Oban
  - Para execução de Jobs recorrentes, com suporte a retentativas e outras features
- Cachex
  - Para o cache distribuído
- Ex_money, Ex_money_sql, Decimal
  - Para lidar com a representação de dinheiro em código e banco de dados
