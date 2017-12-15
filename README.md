OpenZeppelin is a library for writing secure Smart Contracts on Ethereum.

With OpenZeppelin, you can build distributed applications, protocols and organizations:

using common contract security patterns (See Onward with Ethereum Smart Contract Security)
in the Solidity language.
NOTE: New to smart contract development? Check our introductory guide.
Getting Started

OpenZeppelin integrates with Truffle, an Ethereum development environment. Please install Truffle and initialize your project with truffle init.

npm install -g truffle
mkdir myproject && cd myproject
truffle init
To install the OpenZeppelin library, run:

npm init
npm install zeppelin-solidity
After that, you'll get all the library's contracts in the node_modules/zeppelin-solidity/contracts folder. You can use the contracts in the library like so:

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract MyContract is Ownable {
  ...
}
Security

OpenZeppelin is meant to provide secure, tested and community-audited code, but please use common sense when doing anything that deals with real money! We take no responsibility for your implementation decisions and any security problem you might experience.

If you find a security issue, please email security@openzeppelin.org.

Developer Resources

Building a distributed application, protocol or organization with OpenZeppelin?

Read documentation: http://zeppelin-solidity.readthedocs.io/en/latest/

Ask for help and follow progress at: https://slack.openzeppelin.org/

Interested in contributing to OpenZeppelin?

Framework proposal and roadmap: https://medium.com/zeppelin-blog/zeppelin-framework-proposal-and-development-roadmap-fdfa9a3a32ab#.iain47pak
Issue tracker: https://github.com/OpenZeppelin/zeppelin-solidity/issues
Contribution guidelines: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/CONTRIBUTING.md
Collaborating organizations and audits by OpenZeppelin

Golem
Mediachain
Truffle
Firstblood
Rootstock
Consensys
DigixGlobal
Coinfund
DemocracyEarth
Signatura
Ether.camp
Aragon
Wings
among others...

License

Code released under the MIT License.
