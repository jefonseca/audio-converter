# AGENTS.md

## Proyecto

`audio-converter` es una utilidad Bash que convierte archivos de audio de una
carpeta a `.m4a` mediante FFmpeg.

## Estructura

- `audio-converter`: CLI principal, Bash.
- `README.md`: documentación de uso y configuración.
- `LICENSE`: licencia MIT.
- `tests/test_audio_converter.sh`: tests funcionales autocontenidos.
- `packaging/build-deb.sh`: constructor manual del paquete Debian.
- `.github/workflows/ci.yml`: lint, tests y construcción del `.deb`.
- `.github/workflows/release.yml`: construcción para tags `vX.Y.Z`.

## Comportamiento

- Recibe una carpeta como argumento posicional.
- Solo procesa archivos directamente dentro de esa carpeta, nunca subcarpetas.
- La extensión de entrada se compara sin distinguir mayúsculas/minúsculas.
- Crea la salida como `converted-AAAAMMDD-HHMMSS/` dentro de la carpeta de entrada.
- Genera archivos `.m4a` y no sobrescribe colisiones de nombres.
- Usa un archivo temporal y solo publica la salida cuando FFmpeg termina correctamente.
- Conserva metadata compatible mediante `-map_metadata 0`.
- Ignora pistas de vídeo, imágenes y adjuntos mediante `-map 0:a:0 -vn`.
- Interfaz de progreso, en este orden: `zenity`, `kdialog`, terminal.

## Configuración

El archivo se crea automáticamente, sin sobrescribirlo si ya existe, en:

```text
${XDG_CONFIG_HOME:-$HOME/.config}/audio-converter/config
```

Valores predeterminados:

```bash
CODEC='libfdk_aac'
PROFILE='aac_he_v2'
BITRATE='48k'
EXTENSION='mp3'
```

El archivo usa sintaxis Bash. Sus variables son sobrescritas por las opciones
CLI correspondientes. El archivo creado debe conservar permisos `600`.

## CLI

```text
audio-converter [opciones] CARPETA
```

Opciones soportadas:

- `-c`, `--config ARCHIVO`
- `--codec CODEC`
- `--profile PERFIL`
- `--no-profile`
- `-b`, `--bitrate BITRATE`
- `-e`, `--extension EXTENSION`
- `-h`, `--help`
- `-V`, `--version`

Los argumentos CLI tienen prioridad sobre la configuración.

## Desarrollo y verificación

Ejecutar desde la raíz del proyecto:

```bash
bash -n audio-converter packaging/build-deb.sh tests/test_audio_converter.sh
shellcheck audio-converter packaging/build-deb.sh tests/test_audio_converter.sh
./tests/test_audio_converter.sh
```

Los tests usan un FFmpeg simulado y no procesan audio real.

## Paquete Debian

Construcción manual:

```bash
./packaging/build-deb.sh
./packaging/build-deb.sh 1.2.3
```

El paquete instala `/usr/bin/audio-converter`, declara `bash` y `ffmpeg` como
dependencias, y recomienda `zenity | kdialog`. La versión predeterminada es
`0.0.1`.

Los tags con formato `vX.Y.Z` activan el workflow de release y generan el
artefacto `.deb`.

## Convenciones

- Mantener el código Bash simple y compatible con Bash 4+.
- Usar `set -Eeuo pipefail` y arrays para argumentos de comandos.
- Citar siempre rutas y variables que puedan contener espacios.
- No convertir directamente sobre los archivos de entrada.
- Mantener la licencia MIT y actualizar README/tests cuando cambie el CLI.
