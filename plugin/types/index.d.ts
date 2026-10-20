export type Meeting = {
  running: boolean
  mdPath: string
  startedAtMs: number
  lines: number
  screens: number
  screenOn: boolean
  endedAtMs?: number
  // When the transcript last gained a speech line; drives the silence suggestion.
  lastSpeechAtMs?: number
}

export type ItemKind = 'decisao' | 'acao' | 'risco' | 'pergunta'

export type Item = { kind: ItemKind; text: string; owner?: string; at?: string }

export type Lang = 'pt' | 'en' | 'it'

// Model runs behind the Insights pane: when the last one succeeded and how many failed in a row since.
export type InsightsHealth = { okAtMs: number | null; failures: number }

declare module 'claude-code' {
  interface PluginState {
    'notepulse': {
      meeting: Meeting | null
      tail: string[]
      warning: string | null
      items: Item[]
      summary: string[]
      lang: Lang
      liveTranslate: boolean
      translations: { pt: Record<string, string>; en: Record<string, string>; it: Record<string, string> }
      insightsHealth: InsightsHealth
    }
  }
}
