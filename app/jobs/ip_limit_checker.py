import asyncio
from datetime import UTC, datetime as dt, timedelta as td

from sqlalchemy import select

from app import scheduler
from app.db import GetDB
from app.db.models import User, UserStatus
from app.node.sync import sever_user_connections
from app.operation import OperatorType
from app.operation.node import NodeOperation
from app.utils.logger import get_logger
from config import runtime_settings

logger = get_logger("ip-limit-checker")
node_operator = NodeOperation(operator_type=OperatorType.SYSTEM)

# Store recent violators to track streaks and avoid thrashing
_violations_cache: dict[int, dict] = {}


async def check_user_ip_limits_job():
    """Periodically check concurrent online IP counts against uuid_limit for all active users."""
    try:
        async with GetDB() as db:
            stmt = select(User).where(
                User.status == UserStatus.active,
                User.uuid_limit.isnot(None),
                User.uuid_limit > 0,
            )
            result = await db.execute(stmt)
            users_with_limits = list(result.scalars().all())

            if not users_with_limits:
                return

            loopback_ips = {"127.0.0.1", "::1", "localhost"}

            for user in users_with_limits:
                try:
                    ip_list_all = await node_operator.get_user_ip_list_all_nodes(db=db, user_id=user.id)
                    active_ips: set[str] = set()

                    if ip_list_all and ip_list_all.nodes:
                        for node_id, node_ips in ip_list_all.nodes.items():
                            if node_ips and node_ips.ips:
                                for ip in node_ips.ips.keys():
                                    ip_clean = str(ip).strip().lower()
                                    if ip_clean and ip_clean not in loopback_ips:
                                        active_ips.add(str(ip).strip())

                    ip_count = len(active_ips)
                    max_allowed = user.uuid_limit

                    if ip_count > max_allowed:
                        prev = _violations_cache.get(user.id, {})
                        streak = prev.get("streak", 0) + 1

                        _violations_cache[user.id] = {
                            "user_id": user.id,
                            "username": user.username,
                            "ip_count": ip_count,
                            "limit": max_allowed,
                            "ips": sorted(list(active_ips)),
                            "streak": streak,
                            "timestamp": dt.now(UTC).isoformat(),
                        }

                        logger.warning(
                            f"[IP Limit Exceeded] User '{user.username}' (ID: {user.id}) has {ip_count} "
                            f"active IPs connected (Limit: {max_allowed}, Streak: {streak}). Active IPs: {sorted(list(active_ips))}"
                        )

                        # Enforce limit: on persistent violation (streak >= 2 checks, ~30s), sever connections
                        if streak >= 2:
                            logger.info(
                                f"Enforcing IP limit on user '{user.username}' (streak={streak}). Severing excess connections..."
                            )
                            asyncio.create_task(sever_user_connections(user))
                            # Reset streak to 1 to prevent continuous thrashing
                            _violations_cache[user.id]["streak"] = 1
                    else:
                        # Clear violation if back within limit
                        if user.id in _violations_cache:
                            del _violations_cache[user.id]

                except Exception as user_err:
                    logger.debug(f"Error checking IP limit for user {user.id}: {user_err}")

    except Exception as exc:
        logger.error(f"Error running IP limit checker job: {exc}")


def get_current_ip_violations() -> dict[int, dict]:
    """Returns current active IP limit violators."""
    return _violations_cache


if runtime_settings.role.runs_scheduler:
    now = dt.now(UTC)
    scheduler.add_job(
        check_user_ip_limits_job,
        "interval",
        seconds=15,
        coalesce=True,
        max_instances=1,
        start_date=now + td(seconds=10),
        id="check_user_ip_limits",
        replace_existing=True,
    )
