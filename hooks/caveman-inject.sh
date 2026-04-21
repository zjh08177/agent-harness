#!/bin/bash
# Inject caveman mode reminder at session start.
# Change LEVEL to: lite | full | ultra | wenyan-lite | wenyan-full | wenyan-ultra
# Set ENABLED=0 to disable without removing the hook.

ENABLED=1
LEVEL="full"

if [ "$ENABLED" != "1" ]; then
  exit 0
fi

case "$LEVEL" in
  lite)
    RULES='Caveman LITE active. Drop filler/hedging/pleasantries. Keep articles + full sentences. Professional but tight. Off via "stop caveman" / "normal mode".'
    ;;
  ultra)
    RULES='Caveman ULTRA active. Abbrev (DB/auth/cfg/req/res/fn/impl). Strip conjunctions. Arrows for causality (X → Y). One word when one word enough. Code blocks unchanged. Off via "stop caveman".'
    ;;
  wenyan-lite)
    RULES='文言 LITE 模式。去冗，存语法。文言语气。代码块不变。"stop caveman" 解除。'
    ;;
  wenyan-full)
    RULES='文言 FULL 模式。极简文言。压缩 80-90%。古典句式。动词在前，主语常省。文言虚词（之/乃/為/其）。代码块不变。"stop caveman" 解除。'
    ;;
  wenyan-ultra)
    RULES='文言 ULTRA 模式。极致压缩。古典文言风。代码块不变。"stop caveman" 解除。'
    ;;
  *)
    RULES='Caveman FULL active. Drop articles/filler/pleasantries/hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement solution for"). Code blocks + error quotes unchanged. Pattern: [thing] [action] [reason]. Drop caveman for security warnings, destructive op confirmations, multi-step sequences where misread risk. Off via "stop caveman" / "normal mode". Switch level: /caveman lite|ultra|wenyan-full.'
    ;;
esac

jq -nc --arg ctx "$RULES" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
