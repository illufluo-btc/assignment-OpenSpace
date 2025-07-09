import hashlib
import json
from datetime import datetime
import time
import random

def create_block(index, transactions, previous_hash, proof=0):
    
    return {
        'index': index,
        'timestamp': int(datetime.now().timestamp()),
        'transactions': transactions,
        'previous_hash': previous_hash,
        'proof': proof
    }

def calculate_hash(block):
    # calculate the hash of the block
    block_string = json.dumps(block, sort_keys=True)
    return hashlib.sha256(block_string.encode()).hexdigest() #SHA-256

def proof_of_work(block, difficulty=4):
    # proof of work algorithm
    proof = 0
    target = '0' * difficulty
    start_time = time.time()
    
    while True:
        block['proof'] = proof
        block_hash = calculate_hash(block)
        if block_hash.startswith(target):
            end_time = time.time()
            return proof, block_hash, end_time - start_time
        proof += 1

def create_genesis_block():
    # create the genesis block
    genesis_block = create_block(
        index=0,
        transactions=[{"sender": "genesis", "recipient": "genesis", "amount": 0}],
        previous_hash="0" * 64
    )
    proof, block_hash, mining_time = proof_of_work(genesis_block)
    print("创世区块已创建:")
    print(json.dumps(genesis_block, indent=2, ensure_ascii=False))
    print(f"创世区块哈希: {block_hash}")
    print(f"证明: {proof}")
    print(f"挖矿耗时: {mining_time:.2f}秒\n")
    return genesis_block

def add_block(chain, transactions, difficulty):
    # add a new block
    previous_block = chain[-1]
    new_block = create_block(
        index=len(chain),
        transactions=transactions,
        previous_hash=calculate_hash(previous_block)
    )
    proof, block_hash, mining_time = proof_of_work(new_block, difficulty)
    chain.append(new_block)
    print(f"区块 {new_block['index']} 已创建:")
    print(json.dumps(new_block, indent=2, ensure_ascii=False))
    print(f"区块哈希: {block_hash}")
    print(f"证明: {proof}")
    print(f"挖矿耗时: {mining_time:.2f}秒\n")
    return new_block

def generate_random_transaction():
    # generate random transactions
    users = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    sender = random.choice(users)
    recipient = random.choice([u for u in users if u != sender])
    amount = random.uniform(1, 1000)
    return {"sender": sender, "recipient": recipient, "amount": amount}

# automatically run the blockchain
chain = [create_genesis_block()]
difficulty = 4

while True:
    # generate random transactions
    num_transactions = random.randint(1, 10)
    transactions = [generate_random_transaction() for _ in range(num_transactions)]
    
    # add a new block
    add_block(chain, transactions, difficulty)
    time.sleep(1)
