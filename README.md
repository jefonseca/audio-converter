# audio-converter

Convierte archivos de audio de una carpeta a `.m4a` usando FFmpeg. La
configuración predeterminada produce HE-AACv2 a 48 kbps mediante `libfdk_aac`.

## Requisitos

- Bash 4+
- FFmpeg con el codec elegido disponible
- `zenity` o `kdialog` son opcionales; si no están instalados se usa la terminal

## Uso

```bash
audio-converter [opciones] CARPETA
```

Ejemplo:

```bash
./audio-converter ~/Musica
```

Los resultados se guardan en una carpeta `converted-AAAAMMDD-HHMMSS` dentro de
la carpeta de entrada. Solo se buscan archivos directamente en esa carpeta,
no en subcarpetas. La extensión se compara sin distinguir mayúsculas.

## Configuración

En el primer inicio se crea automáticamente:

```text
`${XDG_CONFIG_HOME:-$HOME/.config}/audio-converter/config`
```

Si se indica `--config`, se crea el archivo especificado si todavía no existe.
El archivo usa sintaxis Bash sencilla:

```bash
CODEC='libfdk_aac'
PROFILE='aac_he_v2'
BITRATE='48k'
EXTENSION='mp3'
```

Las opciones de la línea de órdenes sobrescriben el archivo:

```bash
./audio-converter --codec libfdk_aac --profile aac_he_v2 \
  --bitrate 48k --extension mp3 ~/Musica
```

Opciones disponibles:

| Opción | Descripción |
| --- | --- |
| `-c`, `--config ARCHIVO` | Usa otro archivo de configuración |
| `--codec CODEC` | Codec de FFmpeg |
| `--profile PERFIL` | Perfil del codec |
| `--no-profile` | No pasa perfil a FFmpeg |
| `-b`, `--bitrate BITRATE` | Bitrate objetivo |
| `-e`, `--extension EXTENSION` | Extensión de entrada |
| `-h`, `--help` | Muestra la ayuda |
| `-V`, `--version` | Muestra la versión |

Para HE-AACv2, FFmpeg debe estar compilado con `libfdk_aac`. Las portadas o
pistas adjuntas no se copian; se conserva la metadata compatible del audio.

## Tests

```bash
./tests/test_audio_converter.sh
```

El test usa un FFmpeg simulado y no modifica archivos del usuario.

## Paquete Debian

Construcción manual:

```bash
./packaging/build-deb.sh
```

La versión predeterminada es `0.0.1`; también puede indicarse otra versión:

```bash
./packaging/build-deb.sh 1.2.3
```

El paquete instala el comando en `/usr/bin/audio-converter` y declara `bash` y
`ffmpeg` como dependencias. `zenity` y `kdialog` son recomendaciones
opcionales.

## Releases

Al publicar un tag con formato `vX.Y.Z`, GitHub Actions construye el paquete
Debian y crea automáticamente un GitHub Release con el archivo `.deb` adjunto.

```bash
git tag v1.2.3
git push origin v1.2.3
```

## Licencia

MIT. Consulta `LICENSE`.
