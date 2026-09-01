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

$env:ANTHROPIC_BASE_URL   = 'https://api.abliteration.ai'
$env:ANTHROPIC_AUTH_TOKEN = $key
Remove-Item Env:\ANTHROPIC_API_KEY -ErrorAction SilentlyContinue

# Background/small-fast model (abliteration has no Claude haiku).
$env:ANTHROPIC_SMALL_FAST_MODEL = 'abliterated-model'

# Force the model with the CLI flag: a pinned "model" in ~/.claude/settings.json
# overrides the ANTHROPIC_MODEL env var, but a --model flag beats settings.json.
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
    if ($old.Key)   { $env:ANTHROPIC_API_KEY = $old.Key }
    if ($old.Model) { $env:ANTHROPIC_MODEL = $old.Model }           else { Remove-Item Env:\ANTHROPIC_MODEL -ErrorAction SilentlyContinue }
    if ($old.Fast)  { $env:ANTHROPIC_SMALL_FAST_MODEL = $old.Fast } else { Remove-Item Env:\ANTHROPIC_SMALL_FAST_MODEL -ErrorAction SilentlyContinue }
}
