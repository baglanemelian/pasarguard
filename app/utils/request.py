from fastapi import Request


def get_client_ip(request: Request) -> str:
    """Extract real client public IP address considering CDNs, reverse proxies, and direct connections."""
    if not request:
        return ""

    loopback_or_empty = {"127.0.0.1", "::1", "localhost", "0.0.0.0", "unknown"}

    # 1. Cloudflare connecting IP
    cf_ip = request.headers.get("CF-Connecting-IP")
    if cf_ip and cf_ip.strip() and cf_ip.strip().lower() not in loopback_or_empty:
        return cf_ip.strip()

    # 2. True-Client-IP header
    true_client_ip = request.headers.get("True-Client-IP")
    if true_client_ip and true_client_ip.strip() and true_client_ip.strip().lower() not in loopback_or_empty:
        return true_client_ip.strip()

    # 3. Nginx / Reverse proxy real IP
    x_real_ip = request.headers.get("X-Real-IP")
    if x_real_ip and x_real_ip.strip() and x_real_ip.strip().lower() not in loopback_or_empty:
        return x_real_ip.strip()

    # 4. Standard X-Forwarded-For (client is first non-loopback entry)
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for and forwarded_for.strip():
        ips = [ip.strip() for ip in forwarded_for.split(",") if ip.strip()]
        for ip in ips:
            if ip.lower() not in loopback_or_empty:
                return ip
        if ips:
            return ips[0]

    # 5. X-Client-IP header
    x_client_ip = request.headers.get("X-Client-IP")
    if x_client_ip and x_client_ip.strip() and x_client_ip.strip().lower() not in loopback_or_empty:
        return x_client_ip.strip()

    # 6. Direct client host
    if request.client and request.client.host:
        host = request.client.host.strip()
        if host.lower() not in loopback_or_empty:
            return host

    return ""
