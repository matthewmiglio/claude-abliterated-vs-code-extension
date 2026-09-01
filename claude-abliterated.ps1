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

# Snapshot any existing values so we can restore them afterward
$old = @{
    Base  = $env:ANTHROPIC_BASE_URL
    Tok   = $env:ANTHROPIC_AUTH_TOKEN
    Key   = $env:ANTHROPIC_API_KEY
    Model = $env:ANTHROPIC_MODEL
    Fast  = $env:ANTHROPIC_SMALL_FAST_MODEL
}

# Use ANTHROPIC_API_KEY (BYO-key mode), NOT ANTHROPIC_AUTH_TOKEN. When you are
# logged into a claude.ai org, auth-token mode makes Claude Code validate every
# model name against the org's allowed models and reject "abliterated-*" as
# "restricted by your organization", silently falling back to a Claude model.
# API-key mode skips that org model-gate, so abliteration's own model IDs pass.
$env:ANTHROPIC_BASE_URL   = 'https://api.abliteration.ai'
$env:ANTHROPIC_API_KEY    = $key
Remove-Item Env:\ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue

# Default + background models (abliteration has no Claude haiku).
$env:ANTHROPIC_MODEL            = 'abliterated-model-large-v2'
$env:ANTHROPIC_SMALL_FAST_MODEL = 'abliterated-model'

# Also force it with --model (beats a pinned model in ~/.claude/settings.json).
# In-session you can still swap with:  /model abliterated-model-large
$claudeArgs = @($args)
if ($claudeArgs -notcontains '--model') {
    $claudeArgs = @('--model', 'abliterated-model-large-v2') + $claudeArgs
}

try {
    claude @claudeArgs
} finally {
    if ($old.Base)  { $env:ANTHROPIC_BASE_URL = $old.Base }         else { Remove-Item Env:\ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue }
    if ($old.Tok)   { $env:ANTHROPIC_AUTH_TOKEN = $old.Tok }        else { Remove-Item Env:\ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue }
    if ($old.Key)   { $env:ANTHROPIC_API_KEY = $old.Key }          else { Remove-Item Env:\ANTHROPIC_API_KEY -ErrorAction SilentlyContinue }
    if ($old.Model) { $env:ANTHROPIC_MODEL = $old.Model }           else { Remove-Item Env:\ANTHROPIC_MODEL -ErrorAction SilentlyContinue }
    if ($old.Fast)  { $env:ANTHROPIC_SMALL_FAST_MODEL = $old.Fast } else { Remove-Item Env:\ANTHROPIC_SMALL_FAST_MODEL -ErrorAction SilentlyContinue }
}
