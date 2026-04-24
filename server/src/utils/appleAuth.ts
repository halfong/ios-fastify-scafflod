import jwt from 'jsonwebtoken';
import { createPublicKey } from 'crypto';

interface ApplePublicKey {
  kty: string;
  kid: string;
  use: string;
  alg: string;
  n: string;
  e: string;
}

interface ApplePublicKeysResponse {
  keys: ApplePublicKey[];
}

let applePublicKeys: ApplePublicKey[] = [];
let lastFetch = 0;
const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

async function getApplePublicKeys(): Promise<ApplePublicKey[]> {
  const now = Date.now();
  if (applePublicKeys.length > 0 && now - lastFetch < CACHE_DURATION) {
    return applePublicKeys;
  }

  const response = await fetch('https://appleid.apple.com/auth/keys');
  const data: ApplePublicKeysResponse = await response.json();
  applePublicKeys = data.keys;
  lastFetch = now;
  return applePublicKeys;
}

function jwkToPem(jwk: ApplePublicKey): string {
  const key = createPublicKey({
    key: {
      kty: jwk.kty,
      n: jwk.n,
      e: jwk.e,
    },
    format: 'jwk',
  });
  return key.export({ type: 'spki', format: 'pem' }).toString();
}

export async function verifyAppleIdentityToken(identityToken: string): Promise<any> {
  const decoded = jwt.decode(identityToken, { complete: true });
  if (!decoded || typeof decoded === 'string') {
    throw new Error('Invalid token format');
  }

  const { kid } = decoded.header;
  const keys = await getApplePublicKeys();
  const key = keys.find((k) => k.kid === kid);
  if (!key) {
    throw new Error('Unable to find matching Apple public key');
  }

  const publicKey = jwkToPem(key);
  const payload = jwt.verify(identityToken, publicKey, {
    algorithms: ['RS256'],
    issuer: 'https://appleid.apple.com',
    audience: process.env.APPLE_CLIENT_ID,
  });

  return payload;
}
