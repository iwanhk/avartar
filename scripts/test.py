from scripts.functions import *

def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            data= DataTemplate.deploy(addr(admin))

            with open('s1.svg', 'r') as f:
                buffer= f.read()
                compress_data= deflate(str.encode(buffer))
                print(f"string({len(buffer)}) compressed to {len(compress_data)}")
                data.input(compress_data, len(buffer))

            print(f"{len(data.get(0))}")

        if active_network in TEST_NETWORKS:
            pass

    except Exception:
        console.print_exception()


if __name__ == "__main__":
    main()
