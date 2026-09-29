import { useAdmin } from '@/hooks/use-admin'
import { canAccessRoute, firstAllowedRoute } from '@/utils/rbac'
import { getAuthToken } from '@/utils/authStorage'
import { useEffect, useRef } from 'react'
import { useLocation, useNavigate } from 'react-router'

export default function RouteGuard({ children }: { children: React.ReactNode }) {
  const { admin } = useAdmin()
  const location = useLocation()
  const navigate = useNavigate()
  const hasNavigatedRef = useRef(false)

  useEffect(() => {
    if (!getAuthToken()) {
      hasNavigatedRef.current = false
      navigate('/login', { replace: true })
      return
    }

    if (!admin) {
      hasNavigatedRef.current = false
      return // Wait for admin data to load
    }

    if (canAccessRoute(admin, location.pathname)) {
      hasNavigatedRef.current = false
      return
    }

    if (hasNavigatedRef.current) {
      return
    }

    hasNavigatedRef.current = true
    navigate(firstAllowedRoute(admin), { replace: true })
  }, [admin, location.pathname, navigate])

  // Reset navigation flag when pathname changes (after navigation completes)
  useEffect(() => {
    hasNavigatedRef.current = false
  }, [location.pathname])

  return <>{children}</>
}
