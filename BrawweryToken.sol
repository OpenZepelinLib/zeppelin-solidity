pragma solidity ^0.4.11;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract Ownable {
    address public owner;
    address preIco;
    address ico;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == preIco || msg.sender == ico);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setPreIco(address _preIco) onlyOwner public {
        require(_preIco != address(0));
        preIco = _preIco;
    }

    function setICO(address _ico) onlyOwner public {
        require(_ico != address(0));
        ico = _ico;
    }

}


// TODO: СЌС‚Рѕ РјРѕРЅРµС‚Р°
contract MintableToken is StandardToken, Ownable {

    uint256 limit;
    uint256 limitPreico;

    string public constant name = "Satoshi Brewery Limited";
    string public constant symbol = "SBL";
    uint8 public constant decimals = 1;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    function MintableToken() {
        limit = 100000000;
        limitPreico = 2700000;
    }

    function mintPreico(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        require(totalSupply.add(_amount) <= limitPreico);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        require(totalSupply.add(_amount) <= limit);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

// TODO: Р­РўРћ PREICO
contract PreIco is Ownable, usingOraclize {
    using SafeMath for uint256;

    uint256 public dollarCost;
    MintableToken public token;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public dollarMultiplier = 1000000 * 1000 szabo;

    uint256 decimals = 1;

    // how many token units a buyer gets per wei
    uint256 public rate;
    uint256 public minimumCost = 12 finney;

    // amount of raised money in wei
    uint256 public weiRaised;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event updatedEtherPrice(string price);
    event updatingViaOracle(string description);

    function PreIco(MintableToken _token) {
        token = _token;
        //        TODO: PRODUCTION
        startTime = 1508500800;
        endTime = 1511308799;
    }

    function setDollar(uint256 _dollarCost) onlyOwner {
        require(_dollarCost > 0);
        dollarCost = _dollarCost;
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        updatedEtherPrice(result);
        dollarCost = dollarMultiplier.div(parseInt(result, 3));
    }

    function updatePrice() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            updatingViaOracle("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            updatingViaOracle("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.[0]");
        }
    }

    function getRate() internal constant returns (uint256) {
        return dollarCost.mul(67).div(100);
    }

    // fallback function can be used to buy tokens
    function () payable {
        require(!hasEnded());
        require(msg.value >= minimumCost);
        require(validPurchase(msg.value));

        uint256 weiAmount = msg.value;
        rate = getRate();

        // calculate token amount to be created
        uint256 tokens = weiAmount.div(rate);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mintPreico(msg.sender, tokens.mul(10 ** decimals));
        TokenPurchase(msg.sender, msg.sender, weiAmount, tokens);

        forwardFunds(msg.value);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds(uint256 value) internal {
        owner.transfer(value);
    }

    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }

    function validPurchase(uint256 value) internal constant returns (bool) {
        bool nonZeroPurchase = value != 0;
        return nonZeroPurchase;
    }
}

// TODO: Р­РўРћ ICO
contract ICO is Ownable, usingOraclize {
    using SafeMath for uint256;

    address[] investorsArray;
    uint256 public dollarCost;

    PreIco public preICO;
    MintableToken public token;

    struct Investor {
    uint256 amount;
    bool isBack;
    }

    mapping (address => Investor) public investors;

    uint256 public startTime;
    uint256 public endTime;

    // TODO: time variables
    uint256 public secondTime;
    uint256 public thirdTime;
    uint256 public fourthTime;
    uint256 public fifthTime;
    uint256 public sixthTime;
    uint256 public seventhTime;
    uint256 public eighthTime;
    uint256 public ninthTime;
    uint256 public tenthTime;
    uint256 public eleventhTime;

    uint256 decimals = 1;
    uint256 public dollarMultiplier = 1000000 * 1000 szabo;

    // how many token units a buyer gets per wei
    uint256 public rate;
    uint256 public goal;
    uint256 public minimumCost = 100 finney;

    // amount of raised money in wei
    uint256 public weiRaised;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event updatedEtherPrice(string price);
    event updatingViaOracle(string description);

    function ICO(MintableToken _token, PreIco _preIco) {
        require(_preIco != address(0));
        require(_token != address(0));

        token = _token;
        preICO = _preIco;
        goal = 7200000;
        //        TODO: PRODUCTION
        startTime = 1508500800;
        secondTime = 1511222399;
        thirdTime = 1511740800;
        fourthTime = 1512086399;
        fifthTime = 1512086400;
        sixthTime = 1512518399;
        seventhTime = 1512518400;
        eighthTime = 1512950399;
        ninthTime = 1512950400;
        tenthTime = 1513382399;
        eleventhTime = 1513382400;
        endTime = 1514419199;
    }

    function setDollar(uint256 _dollarCost) onlyOwner {
        require(_dollarCost > 0);
        dollarCost = _dollarCost;
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        updatedEtherPrice(result);
        dollarCost = dollarMultiplier.div(parseInt(result, 3));
    }

    function updatePrice() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            updatingViaOracle("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            updatingViaOracle("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.[0]");
        }
    }

    function getRate() internal constant returns (uint256) {
        if (startTime < now && now <= secondTime) {
            return dollarCost.mul(67).div(100);
        }
        if (thirdTime < now && now <= fourthTime) {
            return dollarCost.mul(98).div(100);
        }
        if (fifthTime < now && now <= sixthTime) {
            return dollarCost.mul(102).div(100);
        }
        if (seventhTime < now && now <= eighthTime) {
            return dollarCost.mul(105).div(100);
        }
        if (ninthTime < now && now <= tenthTime) {
            return dollarCost.mul(109).div(100);
        }
        if (eleventhTime < now && now <= endTime) {
            return dollarCost.mul(120).div(100);
        }
    }

    function getMoneyBack() public onlyOwner  {
        require(!goalReached());
        require(!hasFunded());

        for (uint256 i = 0; i < investorsArray.length; i++) {
            if (!investors[investorsArray[i]].isBack && investors[investorsArray[i]].amount > 0) {
                investorsArray[i].transfer(investors[investorsArray[i]].amount);
                investors[investorsArray[i]].amount = 0;
                investors[investorsArray[i]].isBack = true;
            }
        }
    }

    function oneGetMoneyBack() {
        require(!goalReached());
        require(!hasFunded());
        require(investors[msg.sender].amount > 0);
        require(!investors[msg.sender].isBack);

        msg.sender.transfer(investors[msg.sender].amount);
        investors[msg.sender].amount = 0;
        investors[msg.sender].isBack = true;
    }

    function () payable {
        require(!hasEnded());
        require(!hasFunded());
        require(now > thirdTime);
        require(msg.value >= minimumCost);
        require(validPurchase(msg.value));

        uint256 weiAmount = msg.value;
        rate = getRate();

        // calculate token amount to be created
        uint256 tokens = weiAmount.div(rate);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(msg.sender, tokens.mul(10 ** decimals));

        investors[msg.sender].amount += msg.value;
        investorsArray.push(msg.sender);

        TokenPurchase(msg.sender, msg.sender, weiAmount, tokens);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds(uint256 amount) onlyOwner {
        require(amount > 0);
        require(hasEnded());
        require(hasFunded());
        require(this.balance - amount >= 0);

        owner.transfer(amount);
    }

    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }

    function hasFunded() public constant returns (bool) {
        return weiRaised >= dollarCost.mul(goal).sub(preICO.weiRaised());
    }

    function validPurchase(uint256 value) internal constant returns (bool) {
        bool nonZeroPurchase = value != 0;
        return nonZeroPurchase;
    }

    function goalReached() public constant returns (bool) {
        return weiRaised >= dollarCost.mul(goal).mul(75).div(100);
    }
}