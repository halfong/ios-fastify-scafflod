import bcrypt from 'bcryptjs';
import $db from '../../utils/db.service';

export default async function (): Promise<void> {
  const email = process.env.ADMIN_EMAIL ?? 'admin@example.com';
  const password = process.env.ADMIN_PASSWORD ?? 'ChangeMe123!';
  if (password === 'ChangeMe123!') {
    console.warn('[adminUser] ⚠️  Using default password – set ADMIN_PASSWORD env var before running in production!');
  }
  const name = 'Admin';

  const existing = await $db.user.findUnique({ where: { email } });
  if (existing) {
    console.log('Admin user already exists:', existing.email);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await $db.user.create({
    data: { email, name, passwordHash, role: 'admin', active: true }
  });
  console.log('Admin user created:', user.email);
}
