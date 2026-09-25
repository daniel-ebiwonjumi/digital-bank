import { Inject, Injectable } from "@nestjs/common";
import { DATABASE, DatabaseModule } from "../db/database.module.js";
import type { Database } from "../db/db.js";
import { users } from "../db/schema/user.schema.js";
import { eq } from "drizzle-orm";



@Injectable()
export class UsersService {
    constructor(@Inject(DATABASE)
        private readonly db: Database,
) { }

async findByMobileNumber(mobileNumber: string){
    const [user] = await this.db.select().from(users).where(eq(users.mobileNumber, mobileNumber));
    return user;   
}
}