import ujson

def save_metrics(metrics, file_name) -> None:
    # metrics = dict(orbi_unreachable_count=0, pfsens_unreachable_count=0, public_ip_unreachable_count=0, loop_count=0)
    with open(file_name, 'w') as f:
        ujson.dump(metrics,f)

def retrieve_metrics(file_name) -> dict:
    with open(file_name, 'r') as f:
        return ujson.load(f)

