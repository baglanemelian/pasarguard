import React, { useMemo, useEffect, useRef, useState } from 'react'
import { useUserOnlineIpListAllNodes } from '@/service/api'

interface UserLiveOnlineCountProps {
  userId?: number
  uuidLimit?: number | null
}

export const UserLiveOnlineCount: React.FC<UserLiveOnlineCountProps> = ({ userId, uuidLimit }) => {
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

  const onlineCount = useMemo(() => {
    if (!data?.nodes || typeof data.nodes !== 'object') return 0
    const ips = new Set<string>()
    Object.values(data.nodes).forEach((node: any) => {
      if (node?.ips && typeof node.ips === 'object') {
        Object.keys(node.ips).forEach(ip => ips.add(ip))
      }
    })
    return ips.size
  }, [data])

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

  return (
    <span
      className={
        isOnline
          ? `inline-flex items-center gap-1 rounded-full bg-emerald-500/15 border border-emerald-500/30 px-1.5 py-0.5 text-[10px] font-mono font-medium text-emerald-600 dark:text-emerald-400 select-none shrink-0 transition-all duration-150 ${
              justChanged ? 'scale-115 ring-2 ring-emerald-500/60' : 'scale-100'
            }`
          : `inline-flex items-center gap-1 rounded-full bg-muted/60 border border-border/40 px-1.5 py-0.5 text-[10px] font-mono font-medium text-muted-foreground/70 select-none shrink-0 transition-all duration-150 ${
              justChanged ? 'scale-115' : 'scale-100'
            }`
      }
      title={
        isOnline
          ? `ANLIK CANLI: ${onlineCount} aktif cihaz bağlı${uuidLimit ? ` / Limit: ${uuidLimit}` : ''}`
          : `ANLIK CANLI: 0 aktif cihaz bağlı${uuidLimit ? ` / Limit: ${uuidLimit}` : ''}`
      }
    >
      <span className="relative flex h-2 w-2">
        {isOnline && (
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
        )}
        <span
          className={
            isOnline
              ? 'relative inline-flex rounded-full h-2 w-2 bg-emerald-500'
              : 'relative inline-flex rounded-full h-1.5 w-1.5 bg-muted-foreground/40'
          }
        />
      </span>
      <span className="leading-none font-bold">
        {onlineCount}
        {uuidLimit ? <span className="opacity-60 text-[9px] font-normal">/{uuidLimit}</span> : null}
      </span>
    </span>
  )
}

export default UserLiveOnlineCount
