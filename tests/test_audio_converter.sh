#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEST_DIR"' EXIT

assert_file() {
    [[ -f $1 ]] || { printf 'Fallo: no existe %s\n' "$1" >&2; exit 1; }
}

mkdir -p "$TEST_DIR/bin" "$TEST_DIR/input" "$TEST_DIR/config"
cat > "$TEST_DIR/bin/ffmpeg" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
output=${!#}
printf 'fake audio' > "$output"
EOF
chmod +x "$TEST_DIR/bin/ffmpeg"
printf 'audio' > "$TEST_DIR/input/track.Mp3"

HOME="$TEST_DIR" XDG_CONFIG_HOME="$TEST_DIR/config" \
PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    "$ROOT_DIR/audio-converter" --codec fake --no-profile \
    --bitrate 32k --extension .MP3 "$TEST_DIR/input"

config="$TEST_DIR/config/audio-converter/config"
assert_file "$config"
[[ $(stat -c '%a' "$config") == 600 ]] || {
    printf 'Fallo: la configuración no tiene permisos 600\n' >&2
    exit 1
}
outputs=("$TEST_DIR/input"/converted-*/*.m4a)
[[ ${#outputs[@]} == 1 ]] || {
    printf 'Fallo: se esperaba un archivo convertido, hay %s\n' "${#outputs[@]}" >&2
    exit 1
}
assert_file "${outputs[0]}"

mkdir -p "$TEST_DIR/input-custom"
printf 'audio' > "$TEST_DIR/input-custom/track.WAV"
cat > "$TEST_DIR/custom.conf" <<'EOF'
CODEC='fake-from-config'
PROFILE=''
BITRATE='24k'
EXTENSION='wav'
EOF

PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    "$ROOT_DIR/audio-converter" --config "$TEST_DIR/custom.conf" \
    "$TEST_DIR/input-custom"
custom_outputs=("$TEST_DIR/input-custom"/converted-*/*.m4a)
[[ ${#custom_outputs[@]} == 1 ]] || {
    printf 'Fallo: no se aplicó la configuración personalizada\n' >&2
    exit 1
}
assert_file "${custom_outputs[0]}"

printf 'Tests correctos.\n'
