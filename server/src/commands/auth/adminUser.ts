import bcrypt from 'bcryptjs';
import $db from '../../utils/db.service';

export default async function (): Promise<void> {
  const email = 'admin@example.com';
  const password = 'ChangeMe123!';
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
