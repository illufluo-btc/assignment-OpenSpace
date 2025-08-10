# LinearVesting（12 个月 Cliff + 24 个月线性释放）

一个简单的 ERC20 代币归属合约：部署即开始计时；**12 个月 Cliff**；从第 **13 个月** 起按 **24 个月** 线性释放；仅受益人可 `release()`。

## 目录结构

```
.
├─ src/
│  ├─ LinearVesting.sol
│  └─ BERC20.sol
├─ test/
│  └─ LinearVesting.t.sol
├─ script/
│  └─ DeployVesting.s.sol
├─ foundry.toml
└─ remappings.txt
```

## 环境与依赖

* 已安装 Foundry（`forge --version`）
* 安装 OpenZeppelin：

```bash
forge install openzeppelin/openzeppelin-contracts --no-commit
```

* `remappings.txt` 至少包含：

```
@openzeppelin/=lib/openzeppelin-contracts/
```

## 编译与测试（含时间模拟）

```bash
forge build
forge test -vv
```

> 测试使用 `vm.warp` 模拟时间，覆盖 Cliff 前为 0、第 13 个月释放 1/24、期末全部释放。

## 主要方法

* `seed(uint256 amount)`：一次性锁定并转入代币（调用前需先对本合约 `approve`）。只可调用一次。
* `release()`：由受益人提取当前可释放的代币。
* `releasable()`：查看此刻可释放数量。
* `vestedAmount(uint64 t)`：按时间 `t` 计算已归属数量。

## 注意事项

* 月长度按链上计算为 `30 days`。
* `release()` 仅允许 **受益人** 调用。
* `seed()` 只能调用一次，锁定总额度后不可变更。
* 如果代币 `decimals` 不是 18，请按实际精度调整数量。