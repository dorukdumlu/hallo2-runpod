#!/bin/bash
set -e

cd /workspace/hallo2

echo "========================================="
echo "  Hallo2 Render (40 steps, A100)"
echo "  GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'N/A')"
echo "========================================="

START=$(date +%s)

python scripts/inference_long.py --config configs/inference/render.yaml

END=$(date +%s)
ELAPSED=$((END - START))
MINUTES=$((ELAPSED / 60))

echo ""
echo "========================================="
echo "  RENDER TAMAMLANDI!"
echo "  Sure: ${MINUTES} dakika (${ELAPSED} saniye)"
echo "========================================="

OUTPUT="/workspace/hallo2/output/teacher_hq/teacher/merge_video.mp4"

if [ -f "$OUTPUT" ]; then
    echo "  Cikti: $OUTPUT"
    ls -lh "$OUTPUT"
    echo ""
    echo "  Videoyu indirmek icin RunPod file browser kullan"
    echo "  veya: runpodctl send $OUTPUT"
else
    echo "  HATA: Video bulunamadi!"
    echo "  Segment videolari kontrol et:"
    ls -la /workspace/hallo2/output/teacher_hq/teacher/ 2>/dev/null || echo "  Klasor bos"
fi
