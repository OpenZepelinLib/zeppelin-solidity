pragma solidity ^0.4.11;
contract Token {
    string public standard = 'Token 0.1';
    string public name;                                  //!< name for display purporses 
    string public symbol;                               //!< symbol for display purporses
    uint8 public decimals;                             //!< amount of decimals for display purporses

    mapping (address => uint256) public balanceOf;      //!< array of all balances
    mapping (address => mapping (address => uint256)) public allowed;

    uint256 totalTokens;

    uint totalReward;
    uint lastDivideRewardTime;
    uint restReward;

    struct TokenHolder {
        uint256 balance;
        uint       balanceUpdateTime;
        uint       rewardWithdrawTime;
    }
    mapping(address => TokenHolder) holders;

    function Token(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol) {
        totalTokens = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
    }

    // @brief Send coins
    // @param _to recipient of coins
    // @param _value amount of coins for send
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value || _value <= 0) throw;
        beforeBalanceChanges(msg.sender);
        beforeBalanceChanges(_to);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    // @brief Send coins
    // @param _from source of coins
    // @param _to recipient of coins
    // @param _value amount of coins for send
    function transferFrom(address _from, address _to, uint256 _value) {
        if (balanceOf[_from] < _value || _value <= 0) throw;
        if (allowed[_from][msg.sender] < _value) throw;
        beforeBalanceChanges(_from);
        beforeBalanceChanges(_to);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowed[_from][msg.sender] -= _value;
    }

    // @brief Allow another contract to spend some tokens in your behalf
    // @param _spender another contract address
    // @param _value amount of approved tokens
    function approve(address _spender, uint256 _value) {
        allowed[msg.sender][_spender] = _value;
    }

    // @brief Get allowed amount of tokens
    // @param _owner owner of allowance
    // @param _spender spender contract
    // @return the rest of allowed tokens
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function reward() constant public returns(uint) {
        if (holders[msg.sender].rewardWithdrawTime >= lastDivideRewardTime) {
            return 0;
        }
        uint256 balance;
        if (holders[msg.sender].balanceUpdateTime <= lastDivideRewardTime) {
            balance = balanceOf[msg.sender];
        } else {
            balance = holders[msg.sender].balance;
        }
        return totalReward * balance / totalTokens;
    }

    function withdrawReward() public returns(uint) {
        uint value = reward();
        if (value == 0) {
            return 0;
        }
        if (!msg.sender.send(value)) {
            return 0;
        }
        if (balanceOf[msg.sender] == 0) {
            // garbage collector
            delete holders[msg.sender];
        } else {
            holders[msg.sender].rewardWithdrawTime = now;
        }
        return value;
    }

    // Divide up reward and make it accesible for withdraw
    function divideUpReward() public {
        if (lastDivideRewardTime + 30 days > now) throw;
        lastDivideRewardTime = now;
        totalReward = this.balance;
        restReward = this.balance;
    }

    function beforeBalanceChanges(address _who) public {
        if (holders[_who].balanceUpdateTime <= lastDivideRewardTime) {
            holders[_who].balanceUpdateTime = now;
            holders[_who].balance = balanceOf[_who];
        }
    }
}