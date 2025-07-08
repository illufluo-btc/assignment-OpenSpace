import rsa
import hashlib

# find nonce that satisfies POW
def find_pow_nonce(nickname, target_prefix="0000"):
    nonce = 0
    while True:
        message = (nickname + str(nonce)).encode('utf-8')
        hash_value = hashlib.sha256(message).hexdigest()
        if hash_value.startswith(target_prefix):
            return nonce, message, hash_value
        nonce += 1

# generate public and private key
(public_key, private_key) = rsa.newkeys(2048)

# example nickname
nickname = "illufluo"

# find nonce that satisfies POW
nonce, message, hash_value = find_pow_nonce(nickname)

# calculate hash value and check if it starts with 4 zeros
print(f"hash value: {hash_value}")

# sign and verify
if hash_value.startswith('0000'):
    # sign with private key
    signature = rsa.sign(message, private_key, 'SHA-256')
    print("signature success")

    # verify with public key
    try:
        rsa.verify(message, signature, public_key)
        print("verify success")
    except rsa.VerificationError:
        print("verify failed")
else:
    print("hash value not start with 4 zeros")

# print extra information
print(f"nickname: {nickname}")
print(f"nonce: {nonce}")