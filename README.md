# Inspection App Backend

A RESTful API backend built with Express.js for the Inspection App.

## Features

- 🚀 Express.js server with modern middleware
- 🔒 Security headers with Helmet
- 🌐 CORS enabled for cross-origin requests
- 📝 Request logging with Morgan
- 🏥 Health check endpoint
- 📊 API routes for inspections and users
- ⚡ Error handling middleware
- 🔧 Environment configuration

## Project Structure

```
Back-End/
├── server.js              # Main server file
├── package.json           # Dependencies and scripts
├── config.env            # Environment configuration
├── routes/
│   ├── inspections.js    # Inspection routes
│   └── users.js         # User routes
└── README.md            # This file
```

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   # Copy config.env to .env and modify as needed
   cp config.env .env
   ```

3. **Start the server:**
   ```bash
   # Development mode (with auto-reload)
   npm run dev

   # Production mode
   npm start
   ```

## API Endpoints

### Base URL: `http://localhost:3000`

#### Health Check
- `GET /health` - Server health status

#### Inspections
- `GET /api/inspections` - Get all inspections
- `GET /api/inspections/:id` - Get inspection by ID
- `POST /api/inspections` - Create new inspection
- `PUT /api/inspections/:id` - Update inspection
- `DELETE /api/inspections/:id` - Delete inspection

#### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

## Development

### Available Scripts

- `npm start` - Start the server in production mode
- `npm run dev` - Start the server in development mode with auto-reload
- `npm test` - Run tests (to be implemented)

### Environment Variables

Create a `.env` file based on `config.env`:

```env
PORT=3000
NODE_ENV=development
```

## Dependencies

### Production
- `express` - Web framework
- `cors` - Cross-origin resource sharing
- `helmet` - Security headers
- `morgan` - HTTP request logger
- `dotenv` - Environment variable loader

### Development
- `nodemon` - Auto-restart server during development

## Next Steps

1. **Database Integration:** Add a database (PostgreSQL, MongoDB, etc.)
2. **Authentication:** Implement JWT authentication
3. **Validation:** Add request validation middleware
4. **Testing:** Set up unit and integration tests
5. **Documentation:** Add API documentation with Swagger
6. **Deployment:** Configure for production deployment

## License

ISC
