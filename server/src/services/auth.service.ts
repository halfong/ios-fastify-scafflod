import bcrypt from 'bcryptjs'
import $db from '../utils/db.service'
import { verifyAppleIdentityToken } from '../utils/appleAuth'

export type AuthUser = {
  id: string
  email: string
  role: string
  name?: string | null
}

export const $authService = {
  /**
   * Verify email + password credentials against the database.
   * Returns the user if valid and active, null otherwise.
   */
  async verifyEmailPassword(email: string, password: string): Promise<AuthUser | null> {
    const user = await $db.user.findUnique({ where: { email } })
    if (!user || !user.active) return null
    const ok = await bcrypt.compare(password, user.passwordHash)
    if (!ok) return null
    return { id: user.id, email: user.email, role: user.role, name: user.name }
  },

  /**
   * Find or create an OAuth-linked user by provider + providerId.
   * Creates a new user record if no matching account exists.
   */
  async findOrCreateOAuthUser(
    provider: string,
    providerId: string,
    email?: string,
    name?: string,
  ): Promise<AuthUser> {
    let account = await $db.oAuthAccount.findUnique({
      where: { provider_providerId: { provider, providerId } },
      include: { user: true },
    })
    if (!account) {
      let user = email ? await $db.user.findUnique({ where: { email } }) : null
      if (!user) {
        user = await $db.user.create({
          data: {
            email: email || `${provider}-${providerId}@example.com`,
            name: name || 'User',
            passwordHash: await bcrypt.hash(Math.random().toString(36), 10),
            role: 'user',
            active: true,
          },
        })
      }
      account = await $db.oAuthAccount.create({
        data: { provider, providerId, userId: user.id },
        include: { user: true },
      })
    }
    const user = account.user
    return { id: user.id, email: user.email, role: user.role, name: user.name }
  },

  /**
   * Verify an Apple identity token (Sign in with Apple).
   * Returns the decoded JWT payload including `sub` and optionally `email`.
   */
  async verifyAppleToken(identityToken: string): Promise<{ sub: string; email?: string }> {
    return verifyAppleIdentityToken(identityToken) as Promise<{ sub: string; email?: string }>
  },

  /**
   * Full Apple native Sign In flow: verify token, find or create user, handle re-signup.
   * Use this in the POST /auth/apple/token route handler.
   */
  async signInWithApple(params: {
    identityToken: string
    email?: string
    name?: string
  }): Promise<AuthUser> {
    const payload = await verifyAppleIdentityToken(params.identityToken) as any
    const providerId: string = payload.sub
    const email = payload.email || params.email

    let account = await $db.oAuthAccount.findUnique({
      where: { provider_providerId: { provider: 'apple', providerId } },
      include: { user: true },
    })

    if (!account) {
      let user = email ? await $db.user.findUnique({ where: { email } }) : null
      if (!user) {
        user = await $db.user.create({
          data: {
            email: email || `apple-${providerId}@example.com`,
            name: params.name || 'Apple User',
            passwordHash: await bcrypt.hash(Math.random().toString(36), 10),
            role: 'user',
            active: true,
          },
        })
      }
      account = await $db.oAuthAccount.create({
        data: { provider: 'apple', providerId, userId: user.id },
        include: { user: true },
      })
    }

    // If the linked account was soft-deleted, treat this login as a fresh signup
    if (!account.user.active) {
      const prefix = Math.random().toString(36).slice(2, 8)
      await $db.user.update({
        where: { id: account.user.id },
        data: { email: `deleted_${prefix}_${account.user.email}` },
      })
      const newUser = await $db.user.create({
        data: {
          email: email || `apple-${providerId}@example.com`,
          name: params.name || 'Apple User',
          passwordHash: await bcrypt.hash(Math.random().toString(36), 10),
          role: 'user',
          active: true,
        },
      })
      account = await $db.oAuthAccount.update({
        where: { provider_providerId: { provider: 'apple', providerId } },
        data: { userId: newUser.id },
        include: { user: true },
      })
    }

    const user = account.user
    return { id: user.id, email: user.email, role: user.role, name: user.name }
  },

  /**
   * Create a new local user with a hashed password.
   */
  async createUser(email: string, password: string, name?: string, role: string = 'user'): Promise<AuthUser> {
    const passwordHash = await bcrypt.hash(password, 10)
    const user = await $db.user.create({
      data: { email, name: name || 'User', passwordHash, role, active: true },
    })
    return { id: user.id, email: user.email, role: user.role, name: user.name }
  },
}

export default $authService
