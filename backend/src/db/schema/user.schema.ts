import { pgTable, varchar, uuid } from 'drizzle-orm/pg-core';

export const users = pgTable('usera', {
id: uuid('id'). defaultRandom(). primaryKey(),
mobileNumber: varchar('mobile_number', {length: 10}).notNull().unique(),
passwordHash: varchar('password_hash', {length: 250}).notNull(),
email: varchar('email', {length: 250}).
unique()
});
