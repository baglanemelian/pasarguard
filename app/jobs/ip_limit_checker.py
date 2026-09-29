import asyncio
from datetime import UTC, datetime as dt, timedelta as td

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app import scheduler
from app.db import GetDB
from app.db.models import User, UserStatus
from app.operation import OperatorType
from app.operation.node import NodeOperation
from app.operation.user import UserOperation
from app.node.sync import sync_users
from app.utils.logger import get_logger
from config import runtime_settings

logger = get_logger("ip-limit-checker")
node_operator = NodeOperation(operator_type=OperatorType.SYSTEM)
user_operator = UserOperation(operator_type=OperatorType.SYSTEM)

# Store recent violators to avoid redundant notifications/actions
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

            for user in users_with_limits:
                try:
                    ip_list_all = await node_operator.get_user_ip_list_all_nodes(db=db, user_id=user.id)
                    active_ips: set[str] = set()

                    if ip_list_all and ip_list_all.nodes:
                        for node_id, node_ips in ip_list_all.nodes.items():
                            if node_ips and node_ips.ips:
                                active_ips.update(node_ips.ips.keys())

                    ip_count = len(active_ips)
                    max_allowed = user.uuid_limit

                    if ip_count > max_allowed:
                        logger.warning(
                            f"[IP Limit Exceeded] User '{user.username}' (ID: {user.id}) has {ip_count} "
                            f"active IPs connected (Limit: {max_allowed}). Active IPs: {sorted(list(active_ips))}"
                        )
                        _violations_cache[user.id] = {
                            "username": user.username,
                            "ip_count": ip_count,
                            "limit": max_allowed,
                            "ips": list(active_ips),
                            "timestamp": dt.now(UTC).isoformat(),
                        }
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
