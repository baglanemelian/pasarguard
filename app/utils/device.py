import re


def parse_device_info(
    user_agent: str | None = None,
    hwid: str | None = None,
    device_os: str | None = None,
    os_version: str | None = None,
    device_model: str | None = None,
) -> str:
    """
    Dynamically extracts device model, OS, and client application directly from
    the data and headers sent by the client device.
    No hardcoded model lists or manual dictionaries.
    """
    ua = (user_agent or "").strip()
    raw_model = (device_model or "").strip()
    raw_os = (device_os or "").strip()
    raw_os_ver = (os_version or "").strip()

    model = raw_model
    os_info = f"{raw_os} {raw_os_ver}".strip() if raw_os_ver else raw_os
    client_name = ""

    # 1. Dynamically extract client app name from User-Agent
    if ua:
        # Client apps usually put their name at the start of User-Agent (e.g. "v2rayNG/1.8.12", "FoXray/1.4.5", "sing-box/1.8.8")
        first_token = ua.split()[0]
        if "/" in first_token:
            app_part = first_token.split("/")[0].strip()
            # Ignore generic protocol words if an app name follows
            if app_part.lower() not in {"mozilla", "okhttp", "dart", "go-http-client", "curl"}:
                client_name = app_part
        elif not any(char in first_token for char in ";()"):
            client_name = first_token.strip()

        # If client_name wasn't at the start, check inside for known client patterns
        if not client_name:
            m_app = re.search(r"([a-zA-Z0-9_\-]+)\/[\d\.]+", ua)
            if m_app:
                candidate = m_app.group(1).strip()
                if candidate.lower() not in {"mozilla", "applewebkit", "safari", "khtml", "gecko", "version", "scale"}:
                    client_name = candidate

    # 2. Dynamically extract OS and Model from User-Agent if not already provided
    if ua:
        ua_lower = ua.lower()

        # Extract parenthetical info: e.g. "(Linux; Android 14; SM-S928B Build/UP1A.231005.007; wv)"
        inside_parens = ""
        m_parens = re.search(r"\((.*?)\)", ua)
        if m_parens:
            inside_parens = m_parens.group(1).strip()

        # Android device extraction
        if "android" in ua_lower:
            if not os_info:
                m_and = re.search(r"Android\s*([\d\.]+)", ua, re.IGNORECASE)
                if m_and:
                    os_info = f"Android {m_and.group(1)}"
                else:
                    os_info = "Android"

            if not model and inside_parens:
                # In Android UA, model is typically between '; <locale>;' or '; ' and 'Build/' or end of parens
                # Example: "Linux; Android 14; SM-S928B Build/UP1A.231005.007; wv"
                # Example: "Android 13; 2201116TG Build/TKQ1.221114.001"
                parts = [p.strip() for p in inside_parens.split(";") if p.strip()]
                for part in parts:
                    part_clean = re.sub(r"Build\/[a-zA-Z0-9_\.]+", "", part, flags=re.IGNORECASE).strip()
                    part_lower = part_clean.lower()
                    if not part_clean:
                        continue
                    if part_lower in {"linux", "u", "wv", "arm", "arm64", "x86", "x86_64"}:
                        continue
                    if part_lower.startswith("android"):
                        continue
                    if re.match(r"^[a-z]{2}(?:-[a-z]{2})?$", part_lower):  # Locale like en-us
                        continue
                    # Found the device model sent by the device
                    model = part_clean
                    break

        # Apple iOS / iPadOS extraction
        elif "iphone" in ua_lower or "ipad" in ua_lower or "ipod" in ua_lower:
            if not os_info:
                m_ios = re.search(r"(?:iOS|CPU (?:iPhone )?OS)\s*([\d_\.]+)", ua)
                if m_ios:
                    ver = m_ios.group(1).replace("_", ".")
                    os_info = f"iOS {ver}"
                else:
                    os_info = "iOS"

            if not model:
                if inside_parens:
                    parts = [p.strip() for p in inside_parens.split(";") if p.strip()]
                    for p in parts:
                        if "iphone" in p.lower() or "ipad" in p.lower():
                            model = p.split("like")[0].strip()
                            break
                if not model:
                    model = "iPad" if "ipad" in ua_lower else "iPhone"

        # Desktop OS extraction
        elif "windows" in ua_lower:
            if not os_info:
                os_info = "Windows"
            if not model:
                model = "Windows PC"
        elif "macintosh" in ua_lower or "mac os" in ua_lower:
            if not os_info:
                os_info = "macOS"
            if not model:
                model = "Apple Mac"
        elif "linux" in ua_lower:
            if not os_info:
                os_info = "Linux"
            if not model:
                model = "Linux PC"

    # 3. Final formatting
    if not model and not os_info:
        model = "Client Device"

    # Detect icon based on device type
    full_text = f"{model} {os_info}".lower()
    icon = "💻" if any(k in full_text for k in ("pc", "mac", "windows", "linux")) else "📱"

    parts = []
    if model:
        parts.append(model)
    elif os_info:
        parts.append(f"{os_info} Device")

    if os_info and os_info.lower() not in model.lower():
        parts.append(f"({os_info})")

    if client_name and client_name.lower() not in model.lower():
        parts.append(f"• {client_name}")

    return f"{icon} {' '.join(parts)}".strip()
