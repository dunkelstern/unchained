#if os(Linux)
    import UnchainedGlibc
#else
    import Darwin
#endif

import Unchained

let server = UnchainedServer(config: FileExchangeConfig())
server.start()

while true {
    sleep(42)
}
