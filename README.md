# LLaMA 3.1 8B LoRA Fine-Tuning

Fine-tuning LLaMA 3.1 8B with LoRA adapters on the Alpaca dataset.

## Quick Start

```bash
git clone https://github.com/flowerwhiterosesss-art/llama-finetune.git
cd llama-finetune
pip install -r requirements.txt
python3 train.py
```

## Requirements

- Python 3.10+
- CUDA 12.x
- 24GB+ GPU memory

## Training

```bash
python3 train.py --epochs 3 --batch-size 4 --learning-rate 2e-4
```

## Checkpoints

Checkpoints are saved to `./checkpoints/llama-3.1-8b-lora/`

## License

MIT
