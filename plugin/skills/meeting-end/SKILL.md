---
name: meeting-end
description: Encerra a reunião que o NotePulse está gravando e escreve as notas. Use quando o usuário disser "encerrar", "terminar a reunião" ou pedir as notas finais.
---

# Encerrar a reunião

1. Chame `stop_meeting` do servidor MCP `live` do plugin. Se `forced` for `true`, avise que o encerramento foi forçado.
   Se não houver reunião rodando, use a última (o `get_transcript` ainda funciona) e siga.
2. Chame `get_transcript` (sem `since_line`) para ter o texto completo.
3. Se nenhuma linha de `Eles` tiver nome entre parênteses (ex.: `Eles (Silva, Ana)`), chame `diarize_remote`.
   - `status: "skipped"`: siga com `Eles`; se o motivo for falta de `DEEPGRAM_API_KEY`, diga isso em uma linha.
   - `status: "ok"`: para cada `S1..Sn`, proponha um nome a partir de pistas na fala (apresentações, alguém
     chamado pelo nome, "aqui é o..."), usando `speakers` e `lines`. Mostre a lista `S1 -> Nome (pista)`;
     sem pista, `S1 -> ?`. Peça ao usuário para confirmar ou corrigir e espere a resposta antes de escrever.
     Nas notas, use os nomes confirmados; falante sem nome confirmado vira `Eles (S1)`. Não reescreva o `.md`.
4. Escreva `<out>.notes.md` (mesma pasta e nome base do `.md`). Idioma: o argumento do comando escolhe
   (`en` inglês, `it` italiano); sem argumento, português. Use exatamente estes títulos, nesta ordem, no idioma escolhido:
   - pt: `Falantes remotos: ...`, `## Resumo`, `## Decisões`, `## Ações`, `## Perguntas em aberto`, `## Fontes externas` (dono desconhecido: `dono não identificado`)
   - en: `Remote speakers: ...`, `## Summary`, `## Decisions`, `## Actions`, `## Open questions`, `## External sources` (dono desconhecido: `owner unknown`)
   - it: `Interlocutori remoti: ...`, `## Riepilogo`, `## Decisioni`, `## Azioni`, `## Domande aperte`, `## Fonti esterne` (dono desconhecido: `responsabile non identificato`)

   Regras (as mesmas de `NOTES_PROMPTS.v2` em `plugin/hooks/notes.ts`, medidas pelo `/meeting-eval`):
   - Primeira linha do arquivo, obrigatória, antes de qualquer título: o status dos falantes remotos. Diga se vieram com nome do Teams, se foram separados
     em S1..Sn (com os nomes confirmados no passo 3) ou se não foram separados, e o motivo (ex.: sem DEEPGRAM_API_KEY).
   - Resumo: no máximo 5 linhas.
   - Decisões: uma por linha, `- [HH:MM:SS] decisão`, com o horário da linha da transcrição de onde veio.
   - Ações: uma por linha, `- [ ] dono: tarefa (prazo, se dito) [HH:MM:SS]`, com o horário da linha de onde veio.
   - Dono só quando o falante da linha que sustenta a ação está atribuído: o usuário ("Eu"), um nome do Teams
     ("Eles (Nome)") ou um S1..Sn com nome confirmado. Caso contrário, escreva o texto de dono desconhecido do idioma.
     Quando outra pessoa diz que "a equipe" ou "a gente" vai fazer algo, isso não é ação do usuário.
   - Seção vazia: escreva `Nenhuma.` (ou a tradução) sem marcador de lista.
   - Conteúdo de fora da transcrição (outra fonte que o usuário entregou) (texto ou arquivos que o usuário colou ou apontou, nunca as intervenções do próprio copiloto) entra só na seção de fontes externas,
     nunca no resumo, nas decisões, nas ações ou nas perguntas. Sem conteúdo externo, omita essa seção.
   - Nomes de pessoas, empresas e produtos ficam como estão.
   - Não invente nada que não esteja na transcrição.
5. Mostre o conteúdo das notas e os caminhos do `.md`, das notas e do áudio salvo.
