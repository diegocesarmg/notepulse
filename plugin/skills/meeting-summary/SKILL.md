---
name: meeting-summary
description: Resumo da reunião em andamento (ou da última) até agora. Use quando o usuário pedir um resumo da reunião que o NotePulse está transcrevendo.
---

# Resumo da reunião até agora

1. Chame `get_transcript` (sem `since_line`) do servidor MCP `live` do plugin.
2. Se não houver linhas, diga que ainda não há transcrição e pare.
3. Se a captura de tela foi usada: pegue `out` de `meeting_status`, liste `<out>.screens/*.jpg` e,
   se for relevante para o resumo, leia com Read no máximo as 3 mais recentes.
4. Responda em português, no máximo 8 tópicos, em ordem cronológica, cada um com o horário `[HH:MM:SS]` de início.
   Agrupe por assunto; não repita a transcrição palavra por palavra.
5. Termine com uma linha: horário da última linha transcrita e se a reunião ainda está gravando (`meeting_status`).

Não invente nada que não esteja na transcrição. Não encerre a reunião.
