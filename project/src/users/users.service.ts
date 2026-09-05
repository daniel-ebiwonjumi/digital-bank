import { Injectable } from '@nestjs/common';

export interface User{
  id: string;
  mobileNumber: string;
  password: string;
}

@Injectable()
export class UsersService {
  private readonly users: User[] = [
    {
      id: '1',
      mobileNumber: '8066556888',
      password: 'changeme',
    },
    {
      id: '2',
      mobileNumber: '8023556888',
      password: 'guess',
    },
  ];


  async findMobileNumber(mobileNumber: string): Promise<User | undefined> {

    return this.users.find((user) => user.mobileNumber === mobileNumber);
  }
}
