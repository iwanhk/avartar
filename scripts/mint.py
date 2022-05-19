from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            template = DataTemplate.deploy(addr(admin))
            nft = avatarNFT.deploy(template, addr(admin))

            nft.mint()
            nft.mint()
            nft.mint()

        if active_network in TEST_NETWORKS:
            template = DataTemplate.deploy(addr(admin))
            nft = avatarNFT.deploy(template, addr(admin))

            nft.mint(0)

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
