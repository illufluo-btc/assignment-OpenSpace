import hashlib
import time

def find_hash(nickname, prefix_zeros, start_nonce=0):
    nonce = start_nonce
    start_time = time.time()
    while True:
        content = f"{nickname}{nonce}"
        hash_value = hashlib.sha256(content.encode()).hexdigest()
        if hash_value.startswith("0" * prefix_zeros):
            end_time = time.time()
            print(f"满足 {prefix_zeros} 个 0 开头的哈希值：")
            print(f"用时: {end_time - start_time:.4f} 秒")
            print(f"内容: {content}")
            print(f"Hash值: {hash_value}\n")
            return nonce
        nonce += 1


nickname = "illufluo"
nonce_4 = find_hash(nickname, 4)
nonce_5 = find_hash(nickname, 5, start_nonce=nonce_4 + 1)
