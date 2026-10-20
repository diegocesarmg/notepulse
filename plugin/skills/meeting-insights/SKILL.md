---
name: meeting-insights
description: Decisões, ações com dono, riscos e perguntas em aberto da reunião em andamento até agora. Use quando o usuário pedir insights, pendências ou o que foi decidido na reunião que o NotePulse está transcrevendo.
---

# Insights da reunião até agora

1. Chame `get_transcript` (sem `since_line`) do servidor MCP `live` do plugin.
2. Se não houver linhas, diga que ainda não há transcrição e pare.
3. Se a captura de tela foi usada: chame `meeting_status` para pegar `out`, liste `<out>.screens/*.jpg` e,
   se for relevante (números, prazos, decisões na tela), leia com Read no máximo as 3 mais recentes.
4. Responda em português, com estas seções (omita as vazias e diga "nada até agora" se todas estiverem vazias):
   - **Decisões**: o que foi decidido, com `[HH:MM:SS]`.
   - **Ações**: `dono: tarefa (prazo, se dito)`; dono desconhecido vira `dono não identificado`.
   - **Riscos e bloqueios**.
   - **Perguntas em aberto**: perguntas feitas e não respondidas.
   - **Contradições**: falas que se contradizem ou contrariam a pauta informada no início.
5. Cada item em uma linha, citando o horário.

Não invente nada que não esteja na transcrição. Não encerre a reunião.
