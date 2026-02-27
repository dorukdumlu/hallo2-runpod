#!/bin/bash
set -e

echo "========================================="
echo "  Hallo2 A100 Setup & Render"
echo "========================================="

cd /workspace

# 1. Clone Hallo2
echo "[1/5] Hallo2 klonlaniyor..."
if [ ! -d "hallo2" ]; then
    git clone https://github.com/fudan-generative-ai/hallo2.git
fi
cd hallo2

# 2. Install deps
echo "[2/5] Paketler kuruluyor..."
pip install -q -r requirements.txt
pip install -q moviepy==1.0.3

# 3. Download models
echo "[3/5] Model agirliklari indiriliyor (~5GB)..."
python -c "
from huggingface_hub import snapshot_download
snapshot_download('fudan-generative-ai/hallo2', local_dir='pretrained_models')
print('[3/5] Modeller hazir!')
"

# 4. Copy input files
echo "[4/5] Input dosyalari kopyalaniyor..."
cp /workspace/hallo2-runpod/teacher.jpg examples/reference_images/teacher.jpg
cp /workspace/hallo2-runpod/teacher.wav examples/driving_audios/teacher.wav

# 5. Write config
echo "[5/5] Config yaziliyor..."
cat > configs/inference/render.yaml << 'YAML'
source_image: ./examples/reference_images/teacher.jpg
driving_audio: ./examples/driving_audios/teacher.wav

weight_dtype: fp16

data:
  n_motion_frames: 2
  n_sample_frames: 16
  source_image:
    width: 512
    height: 512
  driving_audio:
    sample_rate: 16000
  export_video:
    fps: 25

inference_steps: 40
cfg_scale: 3.5

use_mask: true
mask_rate: 0.25
use_cut: true

audio_ckpt_dir: pretrained_models/hallo2

save_path: ./output/teacher_hq/
cache_path: ./.cache

base_model_path: ./pretrained_models/stable-diffusion-v1-5
motion_module_path: ./pretrained_models/motion_module/mm_sd_v15_v2.ckpt

face_analysis:
  model_path: ./pretrained_models/face_analysis

wav2vec:
  model_path: ./pretrained_models/wav2vec/wav2vec2-base-960h
  features: all

audio_separator:
  model_path: ./pretrained_models/audio_separator/Kim_Vocal_2.onnx

vae:
  model_path: ./pretrained_models/sd-vae-ft-mse

face_expand_ratio: 1.2
pose_weight: 1.0
face_weight: 1.0
lip_weight: 1.0

unet_additional_kwargs:
  use_inflated_groupnorm: true
  unet_use_cross_frame_attention: false
  unet_use_temporal_attention: false
  use_motion_module: true
  use_audio_module: true
  motion_module_resolutions:
    - 1
    - 2
    - 4
    - 8
  motion_module_mid_block: true
  motion_module_decoder_only: false
  motion_module_type: Vanilla
  motion_module_kwargs:
    num_attention_heads: 8
    num_transformer_block: 1
    attention_block_types:
      - Temporal_Self
      - Temporal_Self
    temporal_position_encoding: true
    temporal_position_encoding_max_len: 32
    temporal_attention_dim_div: 1
  audio_attention_dim: 768
  stack_enable_blocks_name:
    - "up"
    - "down"
    - "mid"
  stack_enable_blocks_depth: [0,1,2,3]

enable_zero_snr: true

noise_scheduler_kwargs:
  beta_start: 0.00085
  beta_end: 0.012
  beta_schedule: "linear"
  clip_sample: false
  steps_offset: 1
  prediction_type: "v_prediction"
  rescale_betas_zero_snr: True
  timestep_spacing: "trailing"

sampler: DDIM
YAML

echo ""
echo "========================================="
echo "  SETUP TAMAMLANDI!"
echo "  GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'N/A')"
echo "  VRAM: $(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null || echo 'N/A')"
echo "========================================="
echo ""
echo "  Render baslatmak icin:"
echo "    bash /workspace/hallo2-runpod/render.sh"
echo ""
