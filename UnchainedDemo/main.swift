import Darwin
import Unchained

let server = UnchainedServer(config: FileExchangeConfig())
server.start()

while true {
    sleep(42)
}
