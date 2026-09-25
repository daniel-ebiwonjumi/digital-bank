import { Inject, Injectable } from "@nestjs/common";
import { DATABASE } from "../db/database.module.js";
import type { Database } from "../db/db.js";
import { usersTable } from "../db/schema/user.schema.js";
import { eq } from "drizzle-orm";



@Injectable()
export class UsersService {
    constructor( @Inject(DATABASE)
        private readonly db: Database,
) { }

async findByMobileNumber(mobileNumber: string){
    const [user] = await this.db.select().from(usersTable).where(eq(usersTable.mobileNumber, mobileNumber));
    return user;   
    }
    
    async create(mobileNumber: string, passwordHash: string) {
        const [createdUser] = await this.db.insert(usersTable)
            .values({ mobileNumber, passwordHash }).returning();
        return createdUser;
    }
}