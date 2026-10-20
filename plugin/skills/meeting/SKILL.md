---
name: meeting
description: Copiloto de reunião ao vivo. Use quando o usuário pedir para acompanhar, transcrever ou tomar notas de uma reunião em andamento. Inicia a captura local, acompanha a transcrição em silêncio, intervém só quando importa e escreve as notas ao encerrar.
argument-hint: "[pauta, participantes] [--deepgram] [--map <arquivo>]"
---

# Copiloto de reunião

Argumentos recebidos: $ARGUMENTS

## 1. Iniciar

1. Dos argumentos, extraia:
   - `--deepgram` -> `engine: "deepgram"`; sem ele, `engine: "parakeet"`.
   - `--map <arquivo>` -> `map_path` (caminho absoluto).
   - O resto é contexto livre (pauta, participantes). Guarde-o para interpretar a reunião.
     Se houver contexto, gere um `title` curto (até 5 palavras) a partir dele.
2. Chame a ferramenta `start_meeting` (servidor MCP `live` deste plugin) com `title`, `engine`, `map_path`.
   Guarde `out`, `md_path` e `pid` do resultado.
3. Se der erro, mostre a mensagem ao usuário e pare aqui.
4. Diga em uma linha: gravando, caminho do `.md`, e os comandos `/meeting-summary`, `/meeting-insights`, `/meeting-screen on|off|now` (captura de tela, desligada por padrão) e `/meeting-end` (ou dizer "encerrar").

## 2. Acompanhar

Use a ferramenta Monitor com timeout de 30 minutos, `description` exatamente `digest da reunião NotePulse`
(o plugin oculta da tela as notificações com essa descrição) e este comando (troque `<out>` e `<pid>`):

```
notepulse digest --out "<out>" --every 60 --until-pid <pid>
```

Quando o Monitor expirar, chame `meeting_status`; se `running` for `true`, arme o mesmo Monitor de novo.
O digest novo começa do fim do arquivo: nada é repetido.

## 3. A cada bloco `--- digest HH:MM:SS (N linhas) ---`

Fique em silêncio: não escreva nada no chat. Nada de "Still recording", "ainda gravando" ou status:
a faixa já mostra que está gravando. Uma resposta sem texto é a resposta certa.
Decisões, ações, riscos, contradições e perguntas abertas aparecem sozinhos no painel Insights
(botão `Insights` na faixa), junto com o resumo ao vivo. Não os repita aqui.

Escreva no chat só quando:

- uma linha `> aviso:` disser que a captura parou ou que a conexão caiu: avise em uma linha;
- chegar `--- fim da reunião ---` sem o usuário ter pedido: avise que a captura parou e siga a seção 5.

Itens da pauta que ficaram sem resposta vão nas notas do `meeting-end`, não no meio da reunião.
`Eles/S1` etc. são vozes do outro lado; `Eu` é o usuário.
Linhas `[tela HH:MM:SS] <caminho>` são capturas de tela novas: leia a imagem com Read, em silêncio,
para responder perguntas do usuário e escrever as notas finais.
Nunca descreva a tela só porque ela mudou.

## 4. Pergunta do usuário durante a reunião

Chame `get_transcript` (sem `since_line`, transcrição inteira) e responda a partir dela,
citando os horários `[HH:MM:SS]` relevantes. Se a resposta não estiver na transcrição, diga isso.

## 5. Fim da reunião

Quando o usuário disser "encerrar", rodar `/meeting-end`, ou chegar `--- fim da reunião ---`:
siga a skill `meeting-end` (se o fim veio sem o usuário pedir, avise antes que a captura parou).
