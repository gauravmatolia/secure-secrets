#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
shopt -s nullglob

for f in secrets/*.env; do
  if ! grep -q '^sops_version=' "$f"; then
    echo "FAIL: $f is not SOPS-encrypted"; fail=1
  fi
  if grep -vE '^(sops_|#|$)' "$f" | grep -vqE '=ENC\['; then
    echo "FAIL: $f contains plaintext values"; fail=1
  fi
done

if git ls-files | grep -E '(^|/)(\.env|keys\.txt)$|\.agekey$'; then
  echo "FAIL: key file or plaintext .env is tracked by git"; fail=1
fi

if grep -rEIl --exclude-dir=.git 'AGE-SECRET-KEY-1[A-Z0-9]{50,}' .; then
  echo "FAIL: age private key found"; fail=1
fi

[[ $fail -eq 0 ]] && echo "OK: no plaintext secrets or private keys found"
exit $fail
