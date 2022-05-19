from scripts.functions import *
from brownie import T20, T721


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            data = DataTemplate.deploy(addr(admin))
            nft = avatarNFT.deploy(data, addr(admin))

            nft.mint()
            nft.mint()
            nft.mint()

            with open('s1.svg', 'r') as f:
                buffer = f.read()
                compress_data = deflate(str.encode(buffer))
                print(
                    f"string({len(buffer)}) compressed to {len(compress_data)}")
                data.upload(compress_data, len(buffer))

            print(f"{len(data.get(0))}")

            t20 = T20.deploy(addr(creator))
            t721 = T721.deploy(addr(creator))

            t20.approve(nft, 10, addr(creator))
            t721.approve(nft, 0, addr(creator))
            t721.approve(nft, 1, addr(creator))
            t721.approve(nft, 2, addr(creator))

            nft.dockERC721(0, t721, 0, addr(creator))
            nft.dockERC721(0, t721, 1, addr(creator))
            nft.dockERC721(0, t721, 2, addr(creator))

            nft.transferFrom(admin, consumer, 0, addr(admin))

            nft.tokenURI(0)
            nft.undockERC721(0, t721, 2, consumer, addr(consumer))
            nft.tokenURI(0)

        if active_network in TEST_NETWORKS:
            pass

    except Exception:
        console.print_exception()


if __name__ == "__main__":
    main()
