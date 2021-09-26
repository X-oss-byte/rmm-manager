// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.6;

/// @notice Small library to compute address of engines
/// @author Primitive
library EngineAddress {
    // bytes32 internal constant ENGINE_INIT_CODE_HASH = 0x8225a637619e373ee53c6e0a24f8681cdca3558c44010a60631b320229711097;
    bytes32 internal constant ENGINE_INIT_CODE_HASH = 0x3911449a235ae0a649ca39ab2708fffe22b041fd3a6de3b5f4463182a5176821;

    /// @notice Computes the address of an engine
    /// @param factory The address of the factory
    /// @param risky The address of the risky token
    /// @param stable The address of the stable token
    /// @return engine The computed address of the engine
    function computeAddress(
        address factory,
        address risky,
        address stable
    ) internal pure returns (address engine) {
        engine = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            factory,
                            keccak256(abi.encode(risky, stable)),
                            ENGINE_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}
