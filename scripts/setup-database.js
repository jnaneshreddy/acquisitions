import { sql } from '#config/database.js';

async function setupDatabase() {
  try {
    console.log('🚀 Setting up database...');
    
    // Test basic connection
    console.log('📡 Testing database connection...');
    const connectionTest = await sql`SELECT 1 as test`;
    console.log('✅ Database connection successful');
    
    // Create users table
    console.log('📋 Creating users table...');
    await sql`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'user',
        created_at TIMESTAMP DEFAULT NOW() NOT NULL,
        updated_at TIMESTAMP DEFAULT NOW() NOT NULL
      )
    `;
    
    console.log('✅ Users table created successfully!');
    
    // Test the table
    const result = await sql`SELECT COUNT(*) FROM users`;
    console.log(`✅ Table test successful. Current user count: ${result[0].count}`);
    
    // Show table structure
    const tableInfo = await sql`
      SELECT column_name, data_type, is_nullable, column_default 
      FROM information_schema.columns 
      WHERE table_name = 'users'
      ORDER BY ordinal_position
    `;
    
    console.log('📊 Users table structure:');
    tableInfo.forEach(col => {
      console.log(`  - ${col.column_name}: ${col.data_type} ${col.is_nullable === 'NO' ? '(NOT NULL)' : '(NULL)'}`);
    });
    
    console.log('🎉 Database setup completed successfully!');
    
  } catch (error) {
    console.error('❌ Error setting up database:', error.message);
    console.error('Full error:', error);
  } finally {
    process.exit(0);
  }
}

setupDatabase();