import React, { useMemo, useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useUserOnlineIpListAllNodes } from '@/service/api'

interface UserLiveOnlineCountProps {
  userId?: number
  uuidLimit?: number | null
  lastOnline?: string | null
}

export const UserLiveOnlineCount: React.FC<UserLiveOnlineCountProps> = ({ userId, uuidLimit, lastOnline }) => {
  const { t } = useTranslation()
  if (!userId) return null

  const { data } = useUserOnlineIpListAllNodes(userId, {
    query: {
      refetchInterval: 800, // Sub-second 800ms for instantaneous updates
      staleTime: 0,
      gcTime: 0,
      refetchIntervalInBackground: true,
      refetchOnWindowFocus: 'always',
      enabled: !!userId,
    },
  })

  // Count active IPs from node real-time responses
  const detectedCount = useMemo(() => {
    if (!data?.nodes || typeof data.nodes !== 'object') return 0
    const ips = new Set<string>()
    Object.values(data.nodes).forEach((node: any) => {
      if (node?.ips && typeof node.ips === 'object') {
        Object.keys(node.ips).forEach(ip => {
          if (ip && !['127.0.0.1', '::1', 'localhost'].includes(ip.toLowerCase())) {
            ips.add(ip)
          }
        })
      }
    })
    return ips.size
  }, [data])

  // Pure real-time online count: when VPN closes, it immediately becomes 0
  const onlineCount = useMemo(() => {
    return detectedCount
  }, [detectedCount])

  const [justChanged, setJustChanged] = useState(false)
  const prevCountRef = useRef(onlineCount)

  useEffect(() => {
    if (prevCountRef.current !== onlineCount) {
      setJustChanged(true)
      const timer = setTimeout(() => setJustChanged(false), 1200)
      prevCountRef.current = onlineCount
      return () => clearTimeout(timer)
    }
  }, [onlineCount])

  const isOnline = onlineCount > 0
  const isOverLimit = !!(uuidLimit && uuidLimit > 0 && onlineCount > uuidLimit)

  const tooltipTitle = useMemo(() => {
    if (isOverLimit) {
      return t('userOnline.limitExceeded', {
        defaultValue: 'LIMIT EXCEEDED: {{count}} active devices connected (Limit: {{limit}})',
        count: onlineCount,
        limit: uuidLimit,
      })
    }
    if (isOnline) {
      return t('userOnline.onlineWithCount', {
        defaultValue: 'Online: {{count}} active device(s) connected{{limit}}',
        count: onlineCount,
        limit: uuidLimit ? ` / Limit: ${uuidLimit}` : '',
      })
    }
    return t('userOnline.offlineNoDevices', {
      defaultValue: 'Offline (No connected devices){{limit}}',
      limit: uuidLimit ? ` / Limit: ${uuidLimit}` : '',
    })
  }, [isOverLimit, isOnline, onlineCount, uuidLimit, t])

  return (
    <span
      className={
        isOverLimit
          ? `inline-flex items-center gap-1 rounded-full bg-red-500/15 border border-red-500/40 px-1.5 py-0.5 text-[10px] font-mono font-medium text-red-600 dark:text-red-400 select-none shrink-0 transition-all duration-150 ${
              justChanged ? 'scale-115 ring-2 ring-red-500/60' : 'scale-100'
            }`
          : isOnline
          ? `inline-flex items-center gap-1 rounded-full bg-emerald-500/15 border border-emerald-500/30 px-1.5 py-0.5 text-[10px] font-mono font-medium text-emerald-600 dark:text-emerald-400 select-none shrink-0 transition-all duration-150 ${
              justChanged ? 'scale-115 ring-2 ring-emerald-500/60' : 'scale-100'
            }`
          : `inline-flex items-center gap-1 rounded-full bg-muted/60 border border-border/40 px-1.5 py-0.5 text-[10px] font-mono font-medium text-muted-foreground/70 select-none shrink-0 transition-all duration-150 ${
              justChanged ? 'scale-115' : 'scale-100'
            }`
      }
      title={tooltipTitle}
    >
      <span className="relative flex h-2 w-2">
        {isOverLimit ? (
          <>
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75" />
            <span className="relative inline-flex rounded-full h-2 w-2 bg-red-500" />
          </>
        ) : isOnline ? (
          <>
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
            <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500" />
          </>
        ) : (
          <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-muted-foreground/40" />
        )}
      </span>
      <span className="leading-none font-bold">
        {onlineCount}
        {uuidLimit ? <span className="opacity-60 text-[9px] font-normal">/{uuidLimit}</span> : null}
      </span>
    </span>
  )
}

export default UserLiveOnlineCount
