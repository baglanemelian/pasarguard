from fastapi import Request


def get_client_ip(request: Request) -> str:
    """Extract real client public IP address considering CDNs, reverse proxies, and direct connections."""
    if not request:
        return "Unknown"

    # 1. Cloudflare connecting IP
    cf_ip = request.headers.get("CF-Connecting-IP")
    if cf_ip and cf_ip.strip():
        return cf_ip.strip()

    # 2. True-Client-IP header
    true_client_ip = request.headers.get("True-Client-IP")
    if true_client_ip and true_client_ip.strip():
        return true_client_ip.strip()

    # 3. Nginx / Reverse proxy real IP
    x_real_ip = request.headers.get("X-Real-IP")
    if x_real_ip and x_real_ip.strip():
        return x_real_ip.strip()

    # 4. Standard X-Forwarded-For (client is first non-private entry)
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for and forwarded_for.strip():
        ips = [ip.strip() for ip in forwarded_for.split(",") if ip.strip()]
        for ip in ips:
            if ip.lower() not in {"127.0.0.1", "::1", "localhost"}:
                return ip
        if ips:
            return ips[0]

    # 5. Direct client host
    if request.client and request.client.host:
        return request.client.host

    return "Unknown"
