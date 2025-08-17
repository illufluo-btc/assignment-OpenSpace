// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RebaseToken {
    string public constant name = "Rebase Token";
    string public constant symbol = "RBT";
    uint8  public constant decimals = 18;

    uint256 private constant INITIAL_SUPPLY = 100_000_000 * 1e18;
    uint256 private constant PERIOD = 1 minutes;
    uint256 private constant NUM = 99;
    uint256 private constant DEN = 100;
    uint256 private constant MAX_UINT = type(uint256).max;
    uint256 private constant TOTAL_GONS = MAX_UINT - (MAX_UINT % INITIAL_SUPPLY);

    uint256 private _gpf;
    mapping(address => uint256) private _gons;
    uint256 private _last;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        _gpf = TOTAL_GONS / INITIAL_SUPPLY;
        _gons[msg.sender] = TOTAL_GONS;
        _last = block.timestamp;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }

    function totalSupply() public view returns (uint256) {
        return TOTAL_GONS / _gpf;
    }

    function balanceOf(address a) public view returns (uint256) {
        return _gons[a] / _gpf;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(to != address(0), "zero");
        uint256 g = amount * _gpf;
        require(_gons[msg.sender] >= g, "bal");
        unchecked { _gons[msg.sender] -= g; _gons[to] += g; }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function rebase() external returns (uint256 s) {
        uint256 n = (block.timestamp - _last) / PERIOD;
        require(n > 0, "wait");
        s = totalSupply();
        for (uint256 i = 0; i < n; ++i) s = (s * NUM) / DEN;
        _gpf = TOTAL_GONS / s;
        _last += n * PERIOD;
    }
}
