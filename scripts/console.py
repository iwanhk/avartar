from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            template = DataTemplate[-1]
            cpm = componentNFT[-1]
            nft = avatarNFT[-1]

        if active_network in TEST_NETWORKS:
            template = DataTemplate[-1]
            cpm = componentNFT[-1]
            nft = avatarNFT[-1]

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
