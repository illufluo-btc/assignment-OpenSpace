import React, { useState, useEffect } from 'react';
import { createWalletClient, createPublicClient, http, parseUnits, formatUnits } from 'viem';
import { sepolia } from 'viem/chains';

// 合约地址 - 需要替换为实际地址
const TOKEN_BANK_ADDRESS = '0xC86979C7dc8a5B5652C1f944fc5A15c9f3aeD7Ea'; // TokenBank 合约地址
const TOKEN_ADDRESS = '0x3f8854046A6ad012c5A5e09DA9F6F8bd02Ef0B79'; // ERC20 Token 合约地址

const ERC20_ABI = [
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function'
  },
  {
    inputs: [{ name: 'spender', type: 'address' }, { name: 'value', type: 'uint256' }],
    name: 'approve',
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function'
  }
];

const TOKEN_BANK_ABI = [
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'deposits',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function'
  },
  {
    inputs: [{ name: '_amount', type: 'uint256' }],
    name: 'deposit',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function'
  },
  {
    inputs: [{ name: '_amount', type: 'uint256' }],
    name: 'withdraw',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function'
  }
];

function TokenBank() {
  const [account, setAccount] = useState(null);
  const [tokenBalance, setTokenBalance] = useState('0');
  const [depositBalance, setDepositBalance] = useState('0');
  const [amount, setAmount] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const publicClient = createPublicClient({
    chain: sepolia,
    transport: http()
  });

  // 连接钱包
  const connectWallet = async () => {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    setAccount(accounts[0]);
  };

  // 获取余额
  const fetchBalances = async () => {
    if (!account) return;
    
    const tokenBal = await publicClient.readContract({
      address: TOKEN_ADDRESS,
      abi: ERC20_ABI,
      functionName: 'balanceOf',
      args: [account]
    });
    setTokenBalance(formatUnits(tokenBal, 18));

    const depositBal = await publicClient.readContract({
      address: TOKEN_BANK_ADDRESS,
      abi: TOKEN_BANK_ABI,
      functionName: 'deposits',
      args: [account]
    });
    setDepositBalance(formatUnits(depositBal, 18));
  };

  useEffect(() => {
    if (account) fetchBalances();
  }, [account]);

  // 存款
  const deposit = async () => {
    if (!amount) return;
    setIsLoading(true);
    
    const walletClient = createWalletClient({
      chain: sepolia,
      transport: http(),
      account
    });

    try {
      // 授权
      await walletClient.writeContract({
        address: TOKEN_ADDRESS,
        abi: ERC20_ABI,
        functionName: 'approve',
        args: [TOKEN_BANK_ADDRESS, parseUnits(amount, 18)]
      });

      // 存款
      await walletClient.writeContract({
        address: TOKEN_BANK_ADDRESS,
        abi: TOKEN_BANK_ABI,
        functionName: 'deposit',
        args: [parseUnits(amount, 18)]
      });

      setAmount('');
      fetchBalances();
    } catch (error) {
      console.error(error);
    }
    setIsLoading(false);
  };

  // 取款
  const withdraw = async () => {
    if (!amount) return;
    setIsLoading(true);
    
    const walletClient = createWalletClient({
      chain: sepolia,
      transport: http(),
      account
    });

    try {
      await walletClient.writeContract({
        address: TOKEN_BANK_ADDRESS,
        abi: TOKEN_BANK_ABI,
        functionName: 'withdraw',
        args: [parseUnits(amount, 18)]
      });

      setAmount('');
      fetchBalances();
    } catch (error) {
      console.error(error);
    }
    setIsLoading(false);
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow-lg">
      <h1 className="text-2xl font-bold mb-6">Token Bank</h1>
      
      {!account ? (
        <button 
          onClick={connectWallet}
          className="w-full bg-blue-500 text-white py-2 rounded hover:bg-blue-600"
        >
          连接钱包
        </button>
      ) : (
        <div className="space-y-4">
          <div>
            <p>Token 余额: {parseFloat(tokenBalance).toFixed(4)}</p>
            <p>存款余额: {parseFloat(depositBalance).toFixed(4)}</p>
          </div>
          
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="输入金额"
            className="w-full p-2 border rounded"
          />
          
          <div className="flex gap-2">
            <button
              onClick={deposit}
              disabled={isLoading}
              className="flex-1 bg-green-500 text-white py-2 rounded hover:bg-green-600 disabled:bg-gray-400"
            >
              存款
            </button>
            <button
              onClick={withdraw}
              disabled={isLoading}
              className="flex-1 bg-red-500 text-white py-2 rounded hover:bg-red-600 disabled:bg-gray-400"
            >
              取款
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default TokenBank;
