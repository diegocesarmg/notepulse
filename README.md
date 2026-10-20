# NotePulse

NotePulse is a meeting copilot for Claude Code on Windows. It captures the system audio locally, with no bot joining the call, shows a live transcript, and writes the meeting notes when the meeting ends.

**Status: prototype in daily use.** Expect rough edges.

## Requirements

- Windows 10 or 11, 64-bit
- [Claude Code](https://docs.claude.com/en/docs/claude-code/overview)
- Optional: a Deepgram API key, for cloud transcription

No Python or other runtime is needed. The engine ships as a compiled `notepulse.exe`.

## Install

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/diegocesarmg/notepulse/main/install.ps1 | iex
```

The installer downloads the latest release to `%LOCALAPPDATA%\NotePulse`, adds that folder to your user `PATH`, and prints the two lines below.

In Claude Code, run:

```text
/plugin marketplace add diegocesarmg/notepulse
/plugin install notepulse@notepulse
```

Open a new terminal before you start Claude Code, so the updated `PATH` is loaded.

Windows SmartScreen may warn that the installer or `notepulse.exe` is from an unknown publisher. The release is not code-signed yet.

## Update

Run the same install command again. It replaces the installed version and keeps a single `PATH` entry.

## Speech recognition

- **Local (default):** the Parakeet model downloads on first use and runs on your machine. Audio does not leave the computer.
- **Deepgram:** set the `DEEPGRAM_API_KEY` environment variable to use Deepgram instead. Audio is then sent to Deepgram for transcription. Speaker separation at the end of a meeting also needs this key.

## Usage

In Claude Code, the `notepulse` plugin provides these skills:

- `/notepulse:meeting` starts the live copilot and transcription
- `/notepulse:meeting-insights` lists decisions, owners, risks and open questions so far
- `/notepulse:meeting-summary` gives a summary of the meeting in progress
- `/notepulse:meeting-screen` turns screen capture on or off, or takes one capture now
- `/notepulse:meeting-end` ends the meeting and writes the notes

## Uninstall

1. Delete the `%LOCALAPPDATA%\NotePulse` folder.
2. Remove that folder from your user `PATH` (Environment Variables window).
3. In Claude Code, run `/plugin uninstall notepulse@notepulse`.

## License

Proprietary software. Copyright (c) 2026 Diego Silva. All rights reserved. See [LICENSE](LICENSE).
