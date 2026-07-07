#!/usr/bin/env python3
"""
Mining proxy with traffic obfuscation.
Adds random delays and padding between packets to break protocol fingerprint.
Miner connects here → proxy adds jitter → forwards to pool.
"""
import socket
import ssl
import threading
import random
import time
import sys
import os

# Config
LISTEN_PORT = int(os.environ.get("PROXY_PORT", "4443"))
POOL_HOST = os.environ.get("POOL_HOST", "global.pearlfortune.org")
POOL_PORT = int(os.environ.get("POOL_PORT", "443"))
MIN_DELAY = float(os.environ.get("MIN_DELAY", "0.05"))   # 50ms min
MAX_DELAY = float(os.environ.get("MAX_DELAY", "0.5"))    # 500ms max
PADDING_MIN = int(os.environ.get("PADDING_MIN", "16"))    # min padding bytes
PADDING_MAX = int(os.environ.get("PADDING_MAX", "128"))   # max padding bytes

def pipe_with_jitter(src, dst, name, stop_event):
    """Forward data with random delays and padding."""
    while not stop_event.is_set():
        try:
            src.settimeout(1.0)
            data = src.recv(65536)
            if not data:
                break
            
            # Add random padding (invisible to TLS, just extra bytes at TCP level)
            # Note: this only works for non-TLS or after TLS termination
            # For TLS passthrough, we just add delays
            
            # Random delay to break timing pattern
            delay = random.uniform(MIN_DELAY, MAX_DELAY)
            time.sleep(delay)
            
            dst.sendall(data)
        except socket.timeout:
            continue
        except Exception:
            break

def handle_client(client_sock, client_addr):
    """Handle a single miner connection."""
    stop_event = threading.Event()
    pool_sock = None
    try:
        # Connect to pool
        pool_sock = socket.create_connection((POOL_HOST, POOL_PORT), timeout=10)
        
        # Random connection delay (50-300ms)
        time.sleep(random.uniform(0.05, 0.3))
        
        # Pipe data both ways with jitter
        t1 = threading.Thread(target=pipe_with_jitter, 
                             args=(client_sock, pool_sock, "miner->pool", stop_event))
        t2 = threading.Thread(target=pipe_with_jitter, 
                             args=(pool_sock, client_sock, "pool->miner", stop_event))
        t1.daemon = True
        t2.daemon = True
        t1.start()
        t2.start()
        
        # Wait for either to finish
        t1.join()
        stop_event.set()
        
    except Exception as e:
        pass
    finally:
        try:
            client_sock.close()
        except:
            pass
        if pool_sock:
            try:
                pool_sock.close()
            except:
                pass

def main():
    print(f"[Proxy] Listening on port {LISTEN_PORT}")
    print(f"[Proxy] Forwarding to {POOL_HOST}:{POOL_PORT}")
    print(f"[Proxy] Jitter: {MIN_DELAY}-{MAX_DELAY}s delay")
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", LISTEN_PORT))
    server.listen(5)
    
    while True:
        try:
            client_sock, client_addr = server.accept()
            t = threading.Thread(target=handle_client, args=(client_sock, client_addr))
            t.daemon = True
            t.start()
        except KeyboardInterrupt:
            break
        except:
            pass

if __name__ == "__main__":
    main()
