#!/bin/bash
# Genera las miniaturas que usa la rejilla del reporte.
#
#   ./generar-thumbs.sh          solo las que faltan
#   ./generar-thumbs.sh --todas  rehace todas
#
# Cada foto de fotos/ produce un JPEG de 400px en fotos/thumb/, con el mismo
# nombre base. El reporte carga esas miniaturas en las tarjetas y sustituye
# por la original al abrir la ficha de la persona.

set -euo pipefail
cd "$(dirname "$0")/fotos"
mkdir -p thumb

ANCHO=400
CALIDAD=80
rehechas=0
saltadas=0

for f in *.png *.jpg *.jpeg; do
  [ -f "$f" ] || continue
  out="thumb/${f%.*}.jpg"

  # Salta la miniatura si ya existe y es más nueva que la foto original
  if [ "${1:-}" != "--todas" ] && [ -f "$out" ] && [ "$out" -nt "$f" ]; then
    saltadas=$((saltadas + 1))
    continue
  fi

  sips -s format jpeg -s formatOptions "$CALIDAD" -Z "$ANCHO" "$f" --out "$out" >/dev/null
  echo "  $f -> $out"
  rehechas=$((rehechas + 1))
done

echo
echo "miniaturas generadas: $rehechas | ya al día: $saltadas | total: $(ls thumb | wc -l | xargs)"

# Avisa de miniaturas cuya foto original ya no existe
for t in thumb/*.jpg; do
  [ -f "$t" ] || continue
  base=$(basename "$t" .jpg)
  if [ ! -e "$base.png" ] && [ ! -e "$base.jpg" ] && [ ! -e "$base.jpeg" ]; then
    echo "huérfana (su foto ya no está): $t"
  fi
done
