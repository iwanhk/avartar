from scripts.functions import *
import random


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

            ids = []
            files = os.listdir("svgs")
            total_components = random.randint(1, 3)
            for file in files:  # 遍历文件夹
                # 判断是否是文件夹，不是文件夹才打开
                if not os.path.isdir(file) and file[-4:] == '.svg':
                    if total_components == 0:
                        break
                    file = file[:file.index('-svgrepo-com.svg')]
                    total_components -= 1
                    id = component.totalSupply()
                    ids.append(id)
                    component.mint(makeInt(random.randint(
                        0, 400), random.randint(0, 400)), file, addr(creator))
                    component.approve(nft, id, addr(creator))

            nft.mint(makeInt(0, 0, 1024, 1024), ids, addr(creator))
            print(
                f"Total {len(ids)} component(s) minted for [{nft.totalSupply()-1}]")

        if active_network in TEST_NETWORKS:
            loadComponentData("svgs", DataTemplate[-1], admin)

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
