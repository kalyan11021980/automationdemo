import { readFileSync, existsSync } from 'fs';
import { join } from 'path';
import { z } from 'zod';

// User account data schema
export const UserAccountSchema = z.object({
  userId: z.string(),
  profile: z.object({
    firstName: z.string(),
    lastName: z.string(),
    fullName: z.string(),
    email: z.string().email(),
    phone: z.string(),
    dateOfBirth: z.string(),
  }),
  address: z.object({
    street: z.string(),
    city: z.string(),
    state: z.string(),
    zipCode: z.string(),
    country: z.string(),
  }),
  preferences: z.object({
    preferredLanguage: z.string(),
    communicationMethod: z.string(),
    timeZone: z.string(),
  }),
  medicalInfo: z.object({
    primaryPhysician: z.string(),
    allergies: z.array(z.string()),
    conditions: z.array(z.string()),
    emergencyContact: z.object({
      name: z.string(),
      relationship: z.string(),
      phone: z.string(),
    }),
  }),
  insurance: z.object({
    provider: z.string(),
    policyNumber: z.string(),
    groupNumber: z.string(),
  }),
  lastUpdated: z.string(),
});

export type UserAccount = z.infer<typeof UserAccountSchema>;

// Flattened user data for appointment booking
export const AppointmentUserDataSchema = z.object({
  // Basic profile info
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  fullName: z.string().optional(),
  email: z.string().email().optional(),
  phone: z.string().optional(),
  dateOfBirth: z.string().optional(),
  dob: z.string().optional(), // alias for dateOfBirth
  
  // Address info
  address: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  zipCode: z.string().optional(),
  
  // Medical info
  primaryPhysician: z.string().optional(),
  allergies: z.string().optional(), // comma-separated string
  conditions: z.string().optional(), // comma-separated string
  emergencyContactName: z.string().optional(),
  emergencyContactPhone: z.string().optional(),
  emergencyContact: z.string().optional(), // formatted string
  
  // Insurance info
  insuranceProvider: z.string().optional(),
  insuranceId: z.string().optional(), // alias for policyNumber
  policyNumber: z.string().optional(),
  groupNumber: z.string().optional(),
  
  // Appointment specific (will be missing and need to be asked)
  reasonForVisit: z.string().optional(),
  preferredDate: z.string().optional(),
  preferredTime: z.string().optional(),
  appointmentType: z.string().optional(),
});

export type AppointmentUserData = z.infer<typeof AppointmentUserDataSchema>;

export class AccountService {
  private userAccount: UserAccount | null = null;

  /**
   * Find the correct path to the user account data file
   */
  private findUserAccountPath(): string {
    const possiblePaths = [
      // For Mastra playground - check .mastra/output directory first
      join(process.cwd(), '.mastra', 'output', 'src', 'data', 'user-account.json'),
      // For direct execution from project root
      join(process.cwd(), 'src', 'data', 'user-account.json'),
      // For execution from src directory
      join(process.cwd(), 'data', 'user-account.json'),
      // Additional relative paths to try
      join(process.cwd(), '..', 'src', 'data', 'user-account.json'),
      join(process.cwd(), '..', '..', 'src', 'data', 'user-account.json'),
    ];

    for (const path of possiblePaths) {
      if (existsSync(path)) {
        console.log(`📁 Found user account data at: ${path}`);
        return path;
      }
    }

    // If none exist, return the primary path for better error messages
    return join(process.cwd(), 'src', 'data', 'user-account.json');
  }

  /**
   * Load user account data from JSON file (simulates account service API call)
   */
  async loadUserAccount(userId: string): Promise<UserAccount> {
    try {
      console.log(`🔍 Debug: Current working directory: ${process.cwd()}`);
      
      // In real implementation, this would be an API call
      let dataPath = this.findUserAccountPath();
      
      if (!existsSync(dataPath)) {
        console.log(`📂 File not found, attempting to create at playground location...`);
        // Try to create the file in the expected Mastra playground location
        await this.createUserAccountFileForPlayground();
        // Re-attempt to find the path
        dataPath = this.findUserAccountPath();
        if (!existsSync(dataPath)) {
          // Final fallback - use inline data
          console.log(`⚠️ File still not found, using inline account data`);
          return this.getInlineUserAccount(userId);
        }
      }
      
      const rawData = readFileSync(dataPath, 'utf-8');
      const userData = JSON.parse(rawData);
      
      // Validate the data
      const validatedData = UserAccountSchema.parse(userData);
      this.userAccount = validatedData;
      
      console.log(`✅ Loaded user account data for user: ${validatedData.userId}`);
      return validatedData;
    } catch (error) {
      console.error('❌ Failed to load user account data:', error);
      // Final fallback - use inline data
      console.log(`🔄 Falling back to inline account data`);
      try {
        return this.getInlineUserAccount(userId);
      } catch (fallbackError) {
        throw new Error(`Failed to load user account: ${error}`);
      }
    }
  }

  /**
   * Fallback method that provides inline user account data
   */
  private getInlineUserAccount(userId: string): UserAccount {
    const inlineData = {
      userId: userId,
      profile: {
        firstName: "John",
        lastName: "Smith",
        fullName: "John Smith",
        email: "john.smith@email.com",
        phone: "+1-555-0123",
        dateOfBirth: "1985-03-15"
      },
      address: {
        street: "123 Main Street",
        city: "Boston",
        state: "MA",
        zipCode: "02101",
        country: "USA"
      },
      preferences: {
        preferredLanguage: "English",
        communicationMethod: "email",
        timeZone: "America/New_York"
      },
      medicalInfo: {
        primaryPhysician: "Dr. Sarah Johnson",
        allergies: ["Penicillin"],
        conditions: ["Hypertension"],
        emergencyContact: {
          name: "Jane Smith",
          relationship: "Spouse",
          phone: "+1-555-0124"
        }
      },
      insurance: {
        provider: "BlueCross BlueShield",
        policyNumber: "BC123456789",
        groupNumber: "GRP456"
      },
      lastUpdated: "2024-01-15T10:30:00Z"
    };

    const validatedData = UserAccountSchema.parse(inlineData);
    this.userAccount = validatedData;
    
    console.log(`✅ Loaded inline user account data for user: ${validatedData.userId}`);
    return validatedData;
  }

  /**
   * Create user account file for Mastra playground if it doesn't exist
   */
  private async createUserAccountFileForPlayground(): Promise<void> {
    try {
      const { writeFileSync, mkdirSync } = await import('fs');
      const { dirname } = await import('path');
      
      const playgroundPath = join(process.cwd(), '.mastra', 'output', 'src', 'data', 'user-account.json');
      const playgroundDir = dirname(playgroundPath);
      
      // Create directory if it doesn't exist
      mkdirSync(playgroundDir, { recursive: true });
      
      // Sample user account data
      const sampleData = {
        "userId": "user_12345",
        "profile": {
          "firstName": "John",
          "lastName": "Smith", 
          "fullName": "John Smith",
          "email": "john.smith@email.com",
          "phone": "+1-555-0123",
          "dateOfBirth": "1985-03-15"
        },
        "address": {
          "street": "123 Main Street",
          "city": "Boston",
          "state": "MA",
          "zipCode": "02101",
          "country": "USA"
        },
        "preferences": {
          "preferredLanguage": "English",
          "communicationMethod": "email",
          "timeZone": "America/New_York"
        },
        "medicalInfo": {
          "primaryPhysician": "Dr. Sarah Johnson",
          "allergies": ["Penicillin"],
          "conditions": ["Hypertension"],
          "emergencyContact": {
            "name": "Jane Smith",
            "relationship": "Spouse", 
            "phone": "+1-555-0124"
          }
        },
        "insurance": {
          "provider": "BlueCross BlueShield",
          "policyNumber": "BC123456789",
          "groupNumber": "GRP456"
        },
        "lastUpdated": "2024-01-15T10:30:00Z"
      };
      
      writeFileSync(playgroundPath, JSON.stringify(sampleData, null, 2), 'utf-8');
      console.log(`📝 Created user account data file for playground at: ${playgroundPath}`);
    } catch (error) {
      console.warn('⚠️ Could not create user account file for playground:', error);
    }
  }

  /**
   * Get flattened user data suitable for appointment booking
   */
  getAppointmentUserData(): AppointmentUserData {
    if (!this.userAccount) {
      throw new Error('User account not loaded. Call loadUserAccount() first.');
    }

    const account = this.userAccount;
    
    // Flatten the nested structure for appointment booking
    return {
      // Basic profile
      firstName: account.profile.firstName,
      lastName: account.profile.lastName,
      fullName: account.profile.fullName,
      email: account.profile.email,
      phone: account.profile.phone,
      dateOfBirth: account.profile.dateOfBirth,
      dob: account.profile.dateOfBirth, // alias
      
      // Address
      address: `${account.address.street}, ${account.address.city}, ${account.address.state} ${account.address.zipCode}`,
      city: account.address.city,
      state: account.address.state,
      zipCode: account.address.zipCode,
      
      // Medical info
      primaryPhysician: account.medicalInfo.primaryPhysician,
      allergies: account.medicalInfo.allergies.join(', '),
      conditions: account.medicalInfo.conditions.join(', '),
      emergencyContactName: account.medicalInfo.emergencyContact.name,
      emergencyContactPhone: account.medicalInfo.emergencyContact.phone,
      emergencyContact: `${account.medicalInfo.emergencyContact.name} (${account.medicalInfo.emergencyContact.relationship}) - ${account.medicalInfo.emergencyContact.phone}`,
      
      // Insurance
      insuranceProvider: account.insurance.provider,
      insuranceId: account.insurance.policyNumber, // alias
      policyNumber: account.insurance.policyNumber,
      groupNumber: account.insurance.groupNumber,
      
      // Appointment specific fields are intentionally undefined
      // These will need to be collected through questioning
      reasonForVisit: undefined,
      preferredDate: undefined,
      preferredTime: undefined,
      appointmentType: undefined,
    };
  }

  /**
   * Get available data fields (non-undefined values)
   */
  getAvailableFields(): string[] {
    const userData = this.getAppointmentUserData();
    return Object.entries(userData)
      .filter(([_, value]) => value !== undefined && value !== null && value !== '')
      .map(([key, _]) => key);
  }

  /**
   * Update user data with collected information
   */
  updateUserData(updates: Partial<AppointmentUserData>): AppointmentUserData {
    if (!this.userAccount) {
      throw new Error('User account not loaded. Call loadUserAccount() first.');
    }

    const currentData = this.getAppointmentUserData();
    return { ...currentData, ...updates };
  }

  /**
   * Get user account summary for logging/debugging
   */
  getUserSummary(): string {
    if (!this.userAccount) {
      return 'No user account loaded';
    }

    const account = this.userAccount;
    return `User: ${account.profile.fullName} (${account.profile.email}) - Insurance: ${account.insurance.provider}`;
  }
}

// Singleton instance for the application
export const accountService = new AccountService(); 
