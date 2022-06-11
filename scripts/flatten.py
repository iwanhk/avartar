from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        template = DataTemplate.deploy(addr(admin))
        component = componentNFT.deploy(template, addr(admin))
        nft = avatarNFT.deploy(component, addr(admin))

        flat_contract('DataTemplate', DataTemplate.get_verification_info())
        flat_contract('componentNFT', componentNFT.get_verification_info())
        flat_contract('avatarNFT', avatarNFT.get_verification_info())

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
