## Introdução
Vocês foram contratados pela empresa FIAP X que precisa avançar no desenvolvimento de um
projeto de processamento de imagens. Em uma rodada de investimentos, a empresa apresentou um
projeto simples que processa um vídeo e retorna as imagens dele em um arquivo .zip.
Os investidores gostaram tanto do projeto, que querem investir em uma versão onde eles possam
enviar um vídeo e fazer download deste zip.

## Desafio
O projeto desenvolvido está sem nenhuma das boas práticas de arquitetura de software que nós
aprendemos no curso.
O seu desafio será desenvolver uma aplicação utilizando os conceitos apresentados no curso como:
desenho de arquitetura, desenvolvimento de microsservicos, Qualidade de Software, Mensageria
…etc  
E para ajudar o seu grupo nesta etapa de levantamento de requisitos, segue alguns dos pré
requisitos esperados para este projeto:
- A nova versão do sistema deve processar mais de um vídeo ao mesmo tempo;
- Em caso de picos o sistema não deve perder uma requisição;
- O Sistema deve ser protegido por usuário e senha;
- O fluxo deve ter uma listagem de status dos vídeos de um usuário;
- Em caso de erro um usuário pode ser notificado (email ou um outro meio de comunicação)

## Requisitos técnicos
- O sistema deve persistir os dados;
- O sistema deve estar em uma arquitetura que o permita ser escalado;
- O projeto deve ser versionado no Github;
- O projeto deve ter testes que garantam a sua qualidade;
- CI/CD da aplicacao

## Entregaveis
- Documentação da arquitetura proposta para o projeto;
- Script de criação do banco de dados ou de outros recursos utilizados;
- Link do Github do(s) projeto(s);
- Vídeo de no máximo 10 minutos apresentando: Documentação, Arquitetura escolhida e o
  projeto funcionando.