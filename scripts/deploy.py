from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            template = DataTemplate.deploy(addr(admin))
            component = componentNFT.deploy(template, addr(admin))
            nft = avatarNFT.deploy(component, addr(admin))

            loadComponentData("svgs", template, admin)

        if active_network in TEST_NETWORKS:
            #template = DataTemplate.deploy(addr(admin))
            template = DataTemplate[-1]
            component = componentNFT.deploy(template, addr(admin))
            nft = avatarNFT.deploy(component, addr(admin))

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
