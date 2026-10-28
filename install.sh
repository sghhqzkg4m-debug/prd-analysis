#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/sghhqzkg4m-debug/prd-analysis/main"
SKILLS=(prd-to-feishu-design prd-to-knowledge prd-to-ui-spec sangfor-cloud-console beautiful-feishu-whiteboard)
SOURCE_DIR=""
FORCE=0
TARGET="codex"

usage() {
  cat <<'EOF'
Usage: bash install.sh [--target codex|trae] [--source-dir REPO_DIR] [--force]

Installs all five bundled skills. The default target is Codex.
TRAE CN global skills are installed into ~/.trae-cn/skills.
With --source-dir, reads packages from a local checkout instead of downloading.
Existing different skills are preserved unless --force is given; --force backs them up.
EOF
}

while (($#)); do
  case "$1" in
    --target) TARGET="${2:?missing target after --target}"; shift 2 ;;
    --source-dir) SOURCE_DIR="${2:?missing directory after --source-dir}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$TARGET" in
  codex) DEST="${CODEX_HOME:-$HOME/.codex}/skills" ;;
  trae) DEST="$HOME/.trae-cn/skills" ;;
  *) echo "Unsupported target: $TARGET (choose codex or trae)" >&2; exit 2 ;;
esac

if ! command -v tar >/dev/null || ! command -v curl >/dev/null; then
  echo "tar and curl are required." >&2
  exit 1
fi
if command -v shasum >/dev/null; then
  hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
elif command -v sha256sum >/dev/null; then
  hash_file() { sha256sum "$1" | awk '{print $1}'; }
else
  echo "shasum or sha256sum is required." >&2
  exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
PACKAGES="$WORK_DIR/packages"
mkdir -p "$PACKAGES" "$WORK_DIR/extracted"

if [[ -n "$SOURCE_DIR" ]]; then
  SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
  cp "$SOURCE_DIR/packages/SHA256SUMS" "$PACKAGES/SHA256SUMS"
  for skill in "${SKILLS[@]}"; do
    cp "$SOURCE_DIR/packages/$skill.tar.gz" "$PACKAGES/"
  done
else
  curl -fsSL "$REPO_RAW/packages/SHA256SUMS" -o "$PACKAGES/SHA256SUMS"
  for skill in "${SKILLS[@]}"; do
    curl -fsSL "$REPO_RAW/packages/$skill.tar.gz" -o "$PACKAGES/$skill.tar.gz"
  done
fi

for skill in "${SKILLS[@]}"; do
  expected="$(awk -v file="$skill.tar.gz" '$2 == file {print $1}' "$PACKAGES/SHA256SUMS")"
  [[ -n "$expected" ]] || { echo "Missing checksum for $skill" >&2; exit 1; }
  actual="$(hash_file "$PACKAGES/$skill.tar.gz")"
  [[ "$actual" == "$expected" ]] || { echo "Checksum mismatch: $skill" >&2; exit 1; }
  tar -xzf "$PACKAGES/$skill.tar.gz" -C "$WORK_DIR/extracted"
  [[ -f "$WORK_DIR/extracted/$skill/SKILL.md" ]] || { echo "Missing SKILL.md: $skill" >&2; exit 1; }
done

mkdir -p "$DEST"
for skill in "${SKILLS[@]}"; do
  if [[ -e "$DEST/$skill" && "$FORCE" -eq 0 ]] && ! diff -qr "$WORK_DIR/extracted/$skill" "$DEST/$skill" >/dev/null; then
    echo "Existing skill differs: $DEST/$skill (use --force to back it up and replace it)" >&2
    exit 1
  fi
done

BACKUP=""
for skill in "${SKILLS[@]}"; do
  if [[ -e "$DEST/$skill" ]]; then
    if diff -qr "$WORK_DIR/extracted/$skill" "$DEST/$skill" >/dev/null; then
      echo "Already installed: $skill"
      continue
    fi
    if [[ -z "$BACKUP" ]]; then
      BACKUP="$DEST/.backup/prd-analysis-$(date +%Y%m%d-%H%M%S)"
      mkdir -p "$BACKUP"
    fi
    mv "$DEST/$skill" "$BACKUP/$skill"
  fi
  mv "$WORK_DIR/extracted/$skill" "$DEST/$skill"
  echo "Installed: $skill"
done
[[ -z "$BACKUP" ]] || echo "Previous versions: $BACKUP"
if [[ "$TARGET" == "trae" ]]; then
  echo 'Done. Restart TRAE, then ask it to use prd-to-feishu-design.'
else
  echo 'Done. Start a new Codex session and invoke $prd-to-feishu-design.'
fi
