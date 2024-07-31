// Hash output length in bytes.
`define SPX_N  32
// Height of the hypertree.
`define SPX_FULL_HEIGHT 64
// Number of subtree layer.
`define SPX_D 8
// FORS tree dimensions.
`define SPX_FORS_HEIGHT  4'd14
`define SPX_FORS_TREES   22
// Winternitz parameter
`define SPX_WOTS_W  16

// For clarity
`define SPX_ADDR_BYTES  32

// WOTS parameters.
//if SPX_WOTS_W == 256:
//    SPX_WOTS_LOGW = 8
//elif SPX_WOTS_W == 16:
`define SPX_WOTS_LOGW  4
//else:
//    print("error SPX_WOTS_W assumed 16 or 256")

`define SPX_WOTS_LEN1   (8 * `SPX_N) / `SPX_WOTS_LOGW

// SPX_WOTS_LEN2 is floor(log(len_1 * (w - 1)) / log(w)) + 1; we precompute */
//if SPX_WOTS_W == 256:
//    if SPX_N <= 1:
//        SPX_WOTS_LEN2 = 1
//    elif SPX_N <= 256:
//        SPX_WOTS_LEN2 = 2
//    else:
//        print("error Did not precompute SPX_WOTS_LEN2 for n outside {2, .., 256}")
//elif SPX_WOTS_W == 16:
//    if SPX_N <= 8:
//        SPX_WOTS_LEN2 = 2
//    elif SPX_N <= 136:
`define   SPX_WOTS_LEN2   3
//    elif SPX_N <= 256:
//        SPX_WOTS_LEN2 = 4
//    else:
//        print("error Did not precompute SPX_WOTS_LEN2 for n outside {2, .., 256}")

`define SPX_WOTS_LEN        (`SPX_WOTS_LEN1 + `SPX_WOTS_LEN2)
`define SPX_WOTS_BYTES      (`SPX_WOTS_LEN * `SPX_N)
`define SPX_WOTS_PK_BYTES    `SPX_WOTS_BYTES

// Subtree size.
`define SPX_TREE_HEIGHT     (`SPX_FULL_HEIGHT / `SPX_D)

//if (SPX_TREE_HEIGHT * SPX_D != SPX_FULL_HEIGHT):
//    print("error SPX_D should always divide SPX_FULL_HEIGHT")

// FORS parameters.
`define SPX_FORS_MSG_BYTES   ((`SPX_FORS_HEIGHT * `SPX_FORS_TREES + 7) / 8)
`define SPX_FORS_BYTES       ((`SPX_FORS_HEIGHT + 1) * `SPX_FORS_TREES * `SPX_N)
`define SPX_FORS_PK_BYTES    `SPX_N

// Resulting SPX sizes.
`define SPX_BYTES      (`SPX_N + `SPX_FORS_BYTES + `SPX_D * `SPX_WOTS_BYTES + `SPX_FULL_HEIGHT * `SPX_N)
`define SPX_PK_BYTES   (2 * `SPX_N)
`define SPX_SK_BYTES   (2 * `SPX_N + `SPX_PK_BYTES)

`define SPX_OPTRAND_BYTES  32

//  Offsets of various fields in the address structure when we use SHA256 as the Sphincs+ hash function
`define SPX_OFFSET_LAYER        0   // The byte used to specify the Merkle tree layer
`define SPX_OFFSET_TREE         1   // The start of the 8 byte field used to specify the tree
`define SPX_OFFSET_TYPE         9   // The byte used to specify the hash type (reason)
`define SPX_OFFSET_KP_ADDR2     12  // The high byte used to specify the key pair (which one-time signature)
`define SPX_OFFSET_KP_ADDR1     13  // The low byte used to specify the key pair
`define SPX_OFFSET_CHAIN_ADDR   17  // The byte used to specify the chain address (which Winternitz chain)
`define SPX_OFFSET_HASH_ADDR    21  // The byte used to specify the hash address (where in the Winternitz chain)
`define SPX_OFFSET_TREE_HGT     17  // The byte used to specify the height of this node in the FORS or Merkle tree
`define SPX_OFFSET_TREE_INDEX   18  // The start of the 4 byte field used to specify the node in the FORS or Merkle tree

//CRYPTO_ALGNAME = "SPHINCS+"

`define CRYPTO_SECRETKEYBYTES   `SPX_SK_BYTES
`define CRYPTO_PUBLICKEYBYTES   `SPX_PK_BYTES
`define CRYPTO_BYTES            `SPX_BYTES
`define CRYPTO_SEEDBYTES        3*`SPX_N


// The hash types that are passed to set_type
`define SPX_ADDR_TYPE_WOTS       0
`define SPX_ADDR_TYPE_WOTSPK     1
`define SPX_ADDR_TYPE_HASHTREE   2
`define SPX_ADDR_TYPE_FORSTREE   3
`define SPX_ADDR_TYPE_FORSPK     4
//SPX_ADDR_TYPE_WOTSPRF  = 5
//SPX_ADDR_TYPE_FORSPRF  = 6

`define SPX_SHA256_BLOCK_BYTES    64
`define SPX_SHA256_OUTPUT_BYTES   32  // This does not necessarily equal SPX_N

//if SPX_SHA256_OUTPUT_BYTES < SPX_N:
//    print("error Linking against SHA-256 with N larger than 32 bytes is not supported")

`define SPX_SHA256_ADDR_BYTES  = 22

//SHAKE128_RATE = 168
//SHAKE256_RATE = 136
//SHA3_256_RATE = 136
//SHA3_512_RATE = 72


`define MLEN_WIDTH  12
`define MEM_DEPTH   2**`MLEN_WIDTH  / 32
`define MEM_ADDR_WIDTH  `MLEN_WIDTH - 5
