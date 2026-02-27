# Hallo2 RunPod Render

AI Teacher Demo icin Hallo2 talking head video render.

## Kullanim

RunPod A100 terminalinde:

```bash
cd /workspace
git clone https://github.com/dorukdumlu/hallo2-runpod.git
bash hallo2-runpod/setup.sh
bash hallo2-runpod/render.sh
```

## Dosyalar

- `teacher.jpg` — Kaynak fotograf
- `teacher.wav` — ElevenLabs Turkce ses (16kHz mono)
- `setup.sh` — Hallo2 kurulum scripti
- `render.sh` — Render scripti (40 inference steps)

## Cikti

`/workspace/hallo2/output/teacher_hq/teacher/merge_video.mp4`
