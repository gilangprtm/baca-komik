# Go Setup Instructions

## 📋 Task 1.2 Status

### ✅ Completed:
- [x] Project structure created
- [x] Go modules file (go.mod) prepared
- [x] Environment file (.env) created
- [x] Dependencies defined

### 🔄 In Progress:
- [ ] Go installation
- [ ] Dependencies download
- [ ] Database connection test

## 🛠️ Go Installation

### Windows Installation Steps:

1. **Download Go**: Visit https://golang.org/dl/
2. **Download**: `go1.21.x.windows-amd64.msi` (latest stable version)
3. **Install**: Run the MSI installer
4. **Verify**: Open new terminal and run `go version`

### Alternative Installation Methods:

#### Using Chocolatey (if available):
```powershell
choco install golang
```

#### Using Winget (Windows 10/11):
```powershell
winget install GoLang.Go
```

#### Using Scoop:
```powershell
scoop install go
```

## 🔧 After Go Installation

Once Go is installed, run these commands in the `go_app` directory:

```bash
# Initialize and download dependencies
go mod tidy

# Verify dependencies
go mod verify

# Test build
go build -o main.exe .

# Run application
go run main.go
```

## 📋 Required Dependencies

The following dependencies will be downloaded automatically:

### Core Dependencies:
- `github.com/gin-gonic/gin` - HTTP web framework
- `github.com/jackc/pgx/v5` - PostgreSQL driver
- `github.com/golang-jwt/jwt/v5` - JWT authentication
- `github.com/go-playground/validator/v10` - Input validation
- `github.com/spf13/viper` - Configuration management
- `github.com/sirupsen/logrus` - Structured logging
- `github.com/gin-contrib/cors` - CORS middleware
- `github.com/joho/godotenv` - Environment variables

## 🔗 Database Configuration

Before running the application, you need to configure:

1. **Supabase Service Key**: Get from Supabase dashboard
2. **Database Password**: Get from Supabase dashboard
3. **JWT Secret**: Generate a secure secret

### Get Supabase Credentials:

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `baca-komik`
3. Go to Settings > API
4. Copy the `service_role` key
5. Go to Settings > Database
6. Copy the database password

### Update .env file:
```env
SUPABASE_SERVICE_KEY=your_service_role_key_here
DB_PASSWORD=your_database_password_here
JWT_SECRET=your_secure_jwt_secret_here
```

## 🧪 Testing Setup

After installation and configuration:

```bash
# Test health endpoint
curl http://localhost:8080/health

# Test API root
curl http://localhost:8080/api

# Expected response:
# {"message": "BacaKomik API v1.0.0", "status": "running"}
```

## 🚀 Next Steps

After successful setup:

1. **Task 1.3**: Setup Supabase connection with pgx driver
2. **Task 1.4**: Create base models and response structures  
3. **Task 1.5**: Setup middleware (CORS, Auth, Logger)
4. **Task 1.6**: Create health check endpoint

## 🔍 Troubleshooting

### Common Issues:

1. **Go not found**: Restart terminal after installation
2. **Module errors**: Run `go mod tidy` in project directory
3. **Database connection**: Check Supabase credentials
4. **Port conflicts**: Change PORT in .env file

### Verification Commands:

```bash
# Check Go installation
go version

# Check module status
go mod verify

# Check dependencies
go list -m all

# Test compilation
go build .
```

## 📝 Notes

- Go version 1.21+ required
- Windows Defender might flag the executable (normal for Go binaries)
- Make sure to restart terminal after Go installation
- All dependencies will be downloaded automatically on first `go mod tidy`
