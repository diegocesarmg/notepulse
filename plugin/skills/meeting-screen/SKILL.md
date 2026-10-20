---
name: meeting-screen
description: Liga, desliga ou tira agora uma captura da tela durante a reunião que o NotePulse está gravando. Use quando o usuário pedir para o Claude ver a tela, os slides ou o que está sendo compartilhado na reunião.
argument-hint: "on|off|now [monitor]"
---

# Captura de tela na reunião

Argumentos recebidos: $ARGUMENTS

1. O primeiro argumento é o modo: `on`, `off` ou `now`. Sem argumento ou com outro valor,
   mostre o uso (`/meeting-screen on|off|now [monitor]`) e pare.
2. O segundo argumento, se houver, é o número do monitor (inteiro; `1` é o primeiro monitor).
3. Chame a ferramenta `screen` do servidor MCP `live` do plugin com `mode` (`"on"`, `"off"` ou `"now"`)
   e, se houver, `monitor`.
4. Se der erro (nenhuma reunião em andamento, monitor inexistente, falha na captura), mostre a mensagem e pare.
5. Confirme em uma linha, em português:
   - `on`: "Captura de tela ligada (monitor N): salvo uma imagem quando a tela muda. Atenção: captura o monitor inteiro, incluindo notificações e outras janelas."
   - `off`: "Captura de tela desligada (N imagens nesta reunião)."
   - `now`: "Tela capturada: <last_image>."

Não descreva a imagem aqui: ela chega no próximo bloco do digest como linha `[tela ...]`
e é tratada pela regra da skill `meeting`.
