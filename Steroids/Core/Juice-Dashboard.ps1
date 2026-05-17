# Juice-Dashboard.ps1
# Lightweight local web server for TheSecretJuice v3.0 Control Center
# Provides a GUI for configuration and module management.
# SECURED with Session Tokens for v3.0.

function Start-JuiceDashboard {
    param([int]$Port = 8080)

    # SECURITY: Generate temporary session token to prevent unauthorized local access
    $sessionToken = [Guid]::NewGuid().ToString("N")
    $url = "http://localhost:$Port/?token=$sessionToken"
    
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$Port/")
    
    try {
        $listener.Start()
        Write-Host "`n🎨 The Secret Juice Dashboard is live at: http://localhost:$Port/" -ForegroundColor Green
        Write-Host "   Session Token: $sessionToken (Auto-applied in browser)" -ForegroundColor Gray
        Write-Host "   Press Ctrl+C to stop the server.`n" -ForegroundColor Gray
        
        # Open in default browser with the security token
        Start-Process $url

        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            # SECURITY GATE: Verify token
            $requestToken = $request.QueryString["token"]
            if ($requestToken -ne $sessionToken) {
                Write-Host "⚠️  Blocked unauthorized dashboard access attempt from $($request.RemoteEndPoint)" -ForegroundColor Red
                $response.StatusCode = 403
                $response.Close()
                continue
            }

            # Render HTML
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Juice Control Center</title>
    <style>
        body { background: #0b0e14; color: #e0e0e0; font-family: 'Segoe UI', sans-serif; padding: 2rem; }
        .card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); padding: 1.5rem; border-radius: 12px; margin-bottom: 1rem; }
        .btn { background: #8a2be2; color: white; border: none; padding: 0.5rem 1rem; border-radius: 6px; cursor: pointer; transition: opacity 0.2s; }
        .btn:hover { opacity: 0.8; }
        .gradient-text { background: linear-gradient(45deg, #00c9ff, #92fe9d); -webkit-background-clip: text; -webkit-text-fill-color: transparent; font-weight: 800; }
        code { background: rgba(0,0,0,0.3); padding: 0.2rem 0.4rem; border-radius: 4px; color: #00c9ff; }
    </style>
</head>
<body>
    <h1 class="gradient-text">The Secret Juice v3.0</h1>
    <div class="card">
        <h3>🛡️ Secured Control Center</h3>
        <p>This is your local GUI for managing steroids and visuals. Your session is protected by a unique token.</p>
        <button class="btn" onclick="alert('Profile Reload Triggered')">Reload Profile</button>
    </div>

    <div class="card">
        <h3>💡 Intelligence: Recommended Tools</h3>
        <ul style="list-style: none; padding: 0;">
            <li style="margin-bottom: 0.5rem;"><strong>bat</strong> (instead of <em>cat</em>) - Syntax highlighting</li>
            <li style="margin-bottom: 0.5rem;"><strong>ripgrep</strong> (instead of <em>grep</em>) - Blazing fast search</li>
            <li style="margin-bottom: 0.5rem;"><strong>eza</strong> (instead of <em>ls</em>) - Modern icons & colors</li>
            <li style="margin-bottom: 0.5rem;"><strong>zoxide</strong> (instead of <em>cd</em>) - Smarter navigation</li>
        </ul>
        <p style="font-size: 0.85rem; color: #888;">Run <code>juice list</code> in your terminal to see installed steroids.</p>
    </div>
    
    <footer style="margin-top: 2rem; font-size: 0.8rem; color: #444;">
        Session: $sessionToken | Part of The Secret Juice Ecosystem
    </footer>
</body>
</html>
"@
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
        }
    } catch {
        Write-Host "❌ Dashboard failed: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $listener.Stop()
    }
}
