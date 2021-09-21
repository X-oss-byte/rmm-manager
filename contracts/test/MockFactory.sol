// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.6;

import "@primitivefinance/v2-core/contracts/interfaces/IPrimitiveFactory.sol";
import "./MockEngine.sol";

contract MockFactory is IPrimitiveFactory {
    /// @notice Thrown when the risky and stable tokens are the same
    error SameTokenError();

    /// @notice Thrown when the risky or the stable token is 0x0...
    error ZeroAddressError();

    /// @notice Thrown on attempting to deploy an already deployed Engine
    error DeployedError();

    /// @notice Engine will use these variables for its immutable variables
    struct Args {
        address factory;
        address risky;
        address stable;
        uint256 scaleFactorRisky;
        uint256 scaleFactorStable;
        uint256 minLiquidity;
    }

    /// @inheritdoc IPrimitiveFactory
    uint256 public constant override MIN_LIQUIDITY_FACTOR = 6;
    /// @inheritdoc IPrimitiveFactory
    address public override owner;
    /// @inheritdoc IPrimitiveFactory
    mapping(address => mapping(address => address)) public override getEngine;
    /// @inheritdoc IPrimitiveFactory
    Args public override args; // Used instead of an initializer in Engine contract

    constructor() {
        owner = msg.sender;
    }

    /// @inheritdoc IPrimitiveFactory
    function deploy(address risky, address stable) external override returns (address engine) {
        if (risky == stable) revert SameTokenError();
        if (risky == address(0) || stable == address(0)) revert ZeroAddressError();
        if (getEngine[risky][stable] != address(0)) revert DeployedError();

        engine = deploy(address(this), risky, stable);
        getEngine[risky][stable] = engine;
        emit Deployed(msg.sender, risky, stable, engine);
    }

    /// @notice         Deploys an engine contract with a `salt`.
    /// @dev            Engine contract should have no constructor args, because this affects the deployed address
    ///                 From solidity docs:
    ///                 "It will compute the address from the address of the creating contract,
    ///                 the given salt value, the (creation) bytecode of the created contract,
    ///                 and the constructor arguments."
    ///                 While the address is still deterministic by appending constructor args to a contract's bytecode,
    ///                 it's not efficient to do so on chain.
    /// @param  factory Address of the deploying smart contract
    /// @param  risky   Risky token address, underlying token
    /// @param  stable  Stable token address, quote token
    /// @return engine  Engine contract address which was deployed
    function deploy(
        address factory,
        address risky,
        address stable
    ) internal returns (address engine) {
        (uint256 riskyDecimals, uint256 stableDecimals) = (IERC20(risky).decimals(), IERC20(stable).decimals());
        uint256 scaleFactorRisky = 10**(18 - riskyDecimals);
        uint256 scaleFactorStable = 10**(18 - stableDecimals);
        uint256 lowestDecimals = (riskyDecimals > stableDecimals ? stableDecimals : riskyDecimals);
        uint256 minLiquidity = 10**(lowestDecimals / MIN_LIQUIDITY_FACTOR);
        args = Args({
            factory: factory,
            risky: risky,
            stable: stable,
            scaleFactorRisky: scaleFactorRisky,
            scaleFactorStable: scaleFactorStable,
            minLiquidity: minLiquidity
        }); // Engines call this to get constructor args
        engine = address(new MockEngine{salt: keccak256(abi.encode(risky, stable))}());
        delete args;
    }
}
