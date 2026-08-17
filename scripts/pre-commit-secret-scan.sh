#!/bin/sh
#
# pre-commit-secret-scan.sh — blocks commits that stage secrets.
#
# Scans the files staged by `git commit` for:
#   - sensitive filenames:   *.jks, *.keystore, key.properties
#   - secret content:        <key>-equals assignments (password / secret /
#                            api key) and private-key blocks
#
# Exit 0 = allow commit, exit 1 = block commit.
#
# Install per clone (Git does not track .git/hooks):
#   cp scripts/pre-commit-secret-scan.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
set -u

git rev-parse --show-toplevel >/dev/null 2>&1 || exit 1

FILENAME_RE='(\.jks$|\.keystore$|key\.properties$)'
CONTENT_RE='(password[[:space:]]*=|secret[[:space:]]*=|api[_-]?key[[:space:]]*=|BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY)'
# Documented safe template (contains only CHANGE_ME placeholders).
ALLOWLIST='key\.properties\.example'

STAGED=$(git diff --cached --name-only --diff-filter=ACM)
[ -z "$STAGED" ] && exit 0

fail=0

while IFS= read -r f; do
    [ -z "$f" ] && continue

    if printf '%s\n' "$f" | grep -qE "$ALLOWLIST"; then
        continue
    fi

    # 1) Sensitive filename?
    if printf '%s\n' "$f" | grep -qiE "$FILENAME_RE"; then
        echo "pre-commit: BLOCKED '$f' (sensitive filename: *.jks / *.keystore / key.properties)"
        fail=1
        continue
    fi

    # 2) Secret content? (text files only — grep -I skips binaries)
    if [ -f "$f" ] && grep -qI . "$f" 2>/dev/null; then
        if matches=$(grep -nE "$CONTENT_RE" "$f" 2>/dev/null); then
            echo "pre-commit: BLOCKED '$f' (potential secret content):"
            printf '%s\n' "$matches" | head -5 | sed 's/^/    /'
            fail=1
        fi
    fi
done <<EOF
$STAGED
EOF

if [ "$fail" -ne 0 ]; then
    echo ""
    echo "Commit blocked: possible secrets staged. Remove them and retry."
    exit 1
fi

exit 0
