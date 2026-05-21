#!/usr/bin/env python3
"""
Dev helper: Microsoft OAuth (PKCE) → POST /auth/token on the local API.

Default flow (no flags):
  1. Listen on http://localhost:8765/ for the OAuth redirect
  2. Open Microsoft sign-in in your browser
  3. Capture ?code= automatically
  4. POST code + codeVerifier + redirectUri to http://localhost:8080/auth/token

Prerequisites:
  - API running: docker compose up (port 8080)
  - backend/.env with MICROSOFT_TENANT_ID and MICROSOFT_CLIENT_ID
  - Azure redirect URI on the **Single-page application** platform (NOT Web):
      http://localhost:8765/
    Web + PKCE → AADSTS7000218 (client_secret required). SPA + PKCE works without a secret.

Run:
  cd backend && python3 scripts/microsoft_oauth_test.py
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import secrets
import sys
import threading
import urllib.error
import urllib.parse
import urllib.request
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent.parent
DEFAULT_ENV = BACKEND_DIR / ".env"
DEFAULT_API = "http://localhost:8080"
DEFAULT_CALLBACK_PORT = 8765
DEFAULT_REDIRECT_CAPTURE = f"http://localhost:{DEFAULT_CALLBACK_PORT}/"
DEFAULT_REDIRECT_MANUAL = "http://localhost:8080/"
SCOPES = "openid profile email offline_access"


def load_dotenv(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.is_file():
        return out
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        out[key.strip()] = value.strip().strip("\"'")
    return out


def pkce_pair() -> tuple[str, str]:
    verifier = secrets.token_urlsafe(48)[:64]
    digest = hashlib.sha256(verifier.encode("ascii")).digest()
    challenge = base64.urlsafe_b64encode(digest).rstrip(b"=").decode("ascii")
    return verifier, challenge


def authorize_url(tenant_id: str, client_id: str, redirect_uri: str, challenge: str) -> str:
    params = {
        "client_id": client_id,
        "response_type": "code",
        "redirect_uri": redirect_uri,
        "response_mode": "query",
        "scope": SCOPES,
        "code_challenge": challenge,
        "code_challenge_method": "S256",
        "state": secrets.token_urlsafe(16),
    }
    base = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/authorize"
    return f"{base}?{urllib.parse.urlencode(params)}"


def listen_host_for_redirect(redirect_uri: str) -> str:
    host = urllib.parse.urlparse(redirect_uri).hostname or "127.0.0.1"
    if host in ("localhost", "::1"):
        return "127.0.0.1"
    return host


def exchange_via_api(
    api_base: str,
    code: str,
    code_verifier: str,
    redirect_uri: str,
) -> tuple[int, dict | str]:
    url = f"{api_base.rstrip('/')}/auth/token"
    payload = {
        "provider": "microsoft",
        "code": code,
        "codeVerifier": code_verifier,
        "redirectUri": redirect_uri,
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            body = resp.read().decode("utf-8")
            return resp.status, json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        try:
            parsed: dict | str = json.loads(body)
        except json.JSONDecodeError:
            parsed = body
        return e.code, parsed


def finish_exchange(
    args: argparse.Namespace,
    code: str,
    verifier: str,
    redirect_uri: str,
) -> int:
    print(f"    POST {args.api_base}/auth/token")
    print(
        "    body: "
        + json.dumps(
            {
                "provider": "microsoft",
                "code": f"{code[:8]}…",
                "codeVerifier": f"{verifier[:8]}…",
                "redirectUri": redirect_uri,
            }
        )
    )
    status, body = exchange_via_api(args.api_base, code, verifier, redirect_uri)
    print(f"\nHTTP {status}")
    print(json.dumps(body, indent=2) if isinstance(body, dict) else body)

    if status >= 400 and isinstance(body, dict):
        msg = str(body.get("message", ""))
        if "AADSTS7000218" in msg:
            print(
                "\n--- Fix AADSTS7000218 ---\n"
                "Your redirect URI is registered as a **Web** app (confidential).\n"
                "PKCE without client_secret needs the **Single-page application** platform.\n"
                "\n"
                "Azure Portal → App registration → Authentication:\n"
                "  1. Add platform → Single-page application\n"
                f"  2. Redirect URI: {redirect_uri}\n"
                "  3. Remove the same URI from the **Web** platform if it is listed there\n"
                "  4. Save, wait ~1 minute, run this script again\n"
                "\n"
                "Alternative: add MICROSOFT_CLIENT_SECRET to backend/.env (Web/confidential apps).",
                file=sys.stderr,
            )

    if status == 200 and isinstance(body, dict):
        token = body.get("accessToken", "")
        print("\n--- Sample authenticated request ---")
        print(
            f'curl -s "{args.api_base}/users/me" '
            f'-H "Authorization: Bearer <accessToken>"'
        )
        if token:
            print(f"\n(accessToken length: {len(token)} chars)")
        return 0
    return 1


def run_auto_capture(args: argparse.Namespace, tenant: str, client: str) -> int:
    redirect_uri = args.redirect_uri or DEFAULT_REDIRECT_CAPTURE
    verifier, challenge = pkce_pair()
    auth_url = authorize_url(tenant, client, redirect_uri, challenge)

    print("--- Microsoft OAuth test (auto redirect + /auth/token) ---")
    print(f"Azure redirect URI (must match): {redirect_uri}")
    print(f"Backend:                         {args.api_base}/auth/token")
    print()

    bind_host = listen_host_for_redirect(redirect_uri)
    port = urllib.parse.urlparse(redirect_uri).port or 80
    result: dict[str, str | None] = {"code": None, "error": None}
    done = threading.Event()

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, _fmt: str, *_args) -> None:
            pass

        def do_GET(self) -> None:
            query = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            if "error" in query:
                result["error"] = query.get("error_description", query["error"])[0]
            elif "code" in query:
                result["code"] = query["code"][0]
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            if result["code"]:
                body = (
                    "<h1>Sign-in OK</h1>"
                    "<p>Code captured. Close this tab — check your terminal.</p>"
                )
            else:
                body = f"<h1>Sign-in failed</h1><pre>{result['error']}</pre>"
            self.wfile.write(body.encode("utf-8"))
            done.set()

    server = HTTPServer((bind_host, port), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    print(f"1/3 Listening on {redirect_uri}")
    print("2/3 Opening Microsoft sign-in in browser …")
    if not args.no_open:
        webbrowser.open(auth_url)
    else:
        print(auth_url)

    print("    (complete sign-in in the browser)")
    if not done.wait(args.timeout):
        server.shutdown()
        print(
            f"\nTimed out after {args.timeout:.0f}s.\n"
            f"Add this exact redirect URI in Azure → App registration → Authentication:\n"
            f"  {redirect_uri}",
            file=sys.stderr,
        )
        return 1
    server.shutdown()

    if result["error"]:
        print(f"\nMicrosoft error: {result['error']}", file=sys.stderr)
        return 1
    code = result["code"]
    if not code:
        print("\nNo code in redirect.", file=sys.stderr)
        return 1

    print("3/3 Redirect received — exchanging with backend …")
    return finish_exchange(args, code, verifier, redirect_uri)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Open Microsoft OAuth, capture redirect, POST /auth/token"
    )
    parser.add_argument("--env", type=Path, default=DEFAULT_ENV)
    parser.add_argument("--api-base", default=DEFAULT_API)
    parser.add_argument(
        "--redirect-uri",
        default=None,
        help=f"Callback URL in Azure (default {DEFAULT_REDIRECT_CAPTURE})",
    )
    parser.add_argument(
        "--manual",
        action="store_true",
        help=f"Paste code by hand (redirect {DEFAULT_REDIRECT_MANUAL})",
    )
    parser.add_argument("--no-open", action="store_true", help="Do not open the browser")
    parser.add_argument("--timeout", type=float, default=300.0)
    args = parser.parse_args()

    env = load_dotenv(args.env)
    tenant = env.get("MICROSOFT_TENANT_ID") or env.get("MicrosoftAuth__TenantId", "")
    client = env.get("MICROSOFT_CLIENT_ID") or env.get("MicrosoftAuth__ClientId", "")
    if not tenant or not client:
        print(f"Missing MICROSOFT_TENANT_ID or MICROSOFT_CLIENT_ID in {args.env}", file=sys.stderr)
        return 1

    if args.manual:
        redirect_uri = args.redirect_uri or DEFAULT_REDIRECT_MANUAL
        verifier, challenge = pkce_pair()
        auth_url = authorize_url(tenant, client, redirect_uri, challenge)
        print("--- Manual mode ---")
        print(f"Redirect URI: {redirect_uri}")
        if not args.no_open:
            webbrowser.open(auth_url)
        print(auth_url)
        code = input("\nPaste the `code` from the browser URL: ").strip()
        if not code:
            return 1
        print("Exchanging …")
        return finish_exchange(args, code, verifier, redirect_uri)

    return run_auto_capture(args, tenant, client)


if __name__ == "__main__":
    sys.exit(main())
