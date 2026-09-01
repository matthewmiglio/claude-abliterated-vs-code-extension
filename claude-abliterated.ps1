# Claude Abliterated - Routes Claude Code to abliteration.ai
# Usage: .\claude-abliterated.ps1 [args to pass to claude]

$key = $env:ABLITERATION_API_KEY
if (-not $key) {
    $key = [Environment]::GetEnvironmentVariable('ABLITERATION_API_KEY','User')
}

if (-not $key) {
    Write-Host "ABLITERATION_API_KEY is not set. Set it once with:" -ForegroundColor Red
    Write-Host "  [Environment]::SetEnvironmentVariable('ABLITERATION_API_KEY','<your-key>','User')" -ForegroundColor Yellow
    exit 1
}

# Snapshot any values we change so we can restore them afterward
$old = @{
    Cfg   = $env:CLAUDE_CONFIG_DIR
    Base  = $env:ANTHROPIC_BASE_URL
    Tok   = $env:ANTHROPIC_AUTH_TOKEN
    Key   = $env:ANTHROPIC_API_KEY
    Model = $env:ANTHROPIC_MODEL
    Fast  = $env:ANTHROPIC_SMALL_FAST_MODEL
    Ctx   = $env:CLAUDE_CODE_MAX_CONTEXT_TOKENS
}

# Dedicated config dir with NO claude.ai login. When you are logged into a
# claude.ai org, Claude Code validates every model name against the org's
# allowed Anthropic models and rejects "abliterated-*" as "restricted by your
# organization", silently falling back to a Claude model. A separate
# CLAUDE_CONFIG_DIR (pure API-key mode, no login) removes that gate, so
# abliteration's own model IDs are accepted.
$env:CLAUDE_CONFIG_DIR = Join-Path $env:USERPROFILE '.claude-abliterated'

# API-key mode (NOT ANTHROPIC_AUTH_TOKEN) - also needed to skip the org gate.
$env:ANTHROPIC_BASE_URL = 'https://api.abliteration.ai'
$env:ANTHROPIC_API_KEY  = $key
Remove-Item Env:\ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue

# large-v2 has a 1M context window; tell Claude Code so it doesn't assume 200k
# for this (to Claude Code) unrecognized model name.
$env:CLAUDE_CODE_MAX_CONTEXT_TOKENS = '1000000'

# Default + background models (abliteration has no Claude haiku).
$env:ANTHROPIC_MODEL            = 'abliterated-model-large-v2'
$env:ANTHROPIC_SMALL_FAST_MODEL = 'abliterated-model'

# Force the model with --model too (beats any pinned model in settings).
# In-session you can still swap with:  /model abliterated-model-large
$claudeArgs = @($args)
if ($claudeArgs -notcontains '--model') {
    $claudeArgs = @('--model', 'abliterated-model-large-v2') + $claudeArgs
}

try {
    claude @claudeArgs
} finally {
    if ($old.Cfg)   { $env:CLAUDE_CONFIG_DIR = $old.Cfg }            else { Remove-Item Env:\CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue }
    if ($old.Base)  { $env:ANTHROPIC_BASE_URL = $old.Base }          else { Remove-Item Env:\ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue }
    if ($old.Tok)   { $env:ANTHROPIC_AUTH_TOKEN = $old.Tok }         else { Remove-Item Env:\ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue }
    if ($old.Key)   { $env:ANTHROPIC_API_KEY = $old.Key }            else { Remove-Item Env:\ANTHROPIC_API_KEY -ErrorAction SilentlyContinue }
    if ($old.Model) { $env:ANTHROPIC_MODEL = $old.Model }            else { Remove-Item Env:\ANTHROPIC_MODEL -ErrorAction SilentlyContinue }
    if ($old.Fast)  { $env:ANTHROPIC_SMALL_FAST_MODEL = $old.Fast }  else { Remove-Item Env:\ANTHROPIC_SMALL_FAST_MODEL -ErrorAction SilentlyContinue }
    if ($old.Ctx)   { $env:CLAUDE_CODE_MAX_CONTEXT_TOKENS = $old.Ctx } else { Remove-Item Env:\CLAUDE_CODE_MAX_CONTEXT_TOKENS -ErrorAction SilentlyContinue }
}
