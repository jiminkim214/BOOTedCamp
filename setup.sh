#!/bin/bash

# BOOTedCamp Frontend & Backend Setup Script

echo "🚀 Setting up BOOTedCamp Frontend & Backend..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 16 or higher."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

# Check if OCaml/opam is installed
if ! command -v opam &> /dev/null; then
    print_error "opam is not installed. Please install opam first."
    echo "Visit: https://opam.ocaml.org/doc/Install.html"
    exit 1
fi

print_status "Node.js version: $(node --version)"
print_status "npm version: $(npm --version)"

# Setup OCaml dependencies for web server
print_status "Installing OCaml dependencies for web server..."
opam install lwt cohttp-lwt-unix yojson --yes

if [ $? -ne 0 ]; then
    print_error "Failed to install OCaml dependencies"
    exit 1
fi

# Build OCaml project
print_status "Building OCaml project..."
dune build

if [ $? -ne 0 ]; then
    print_error "Failed to build OCaml project"
    exit 1
fi

# Build web server
print_status "Building web server..."
dune build web_server/server.exe

if [ $? -ne 0 ]; then
    print_error "Failed to build web server"
    exit 1
fi

# Setup frontend
print_status "Setting up frontend..."
cd frontend

if [ ! -f package.json ]; then
    print_error "package.json not found in frontend directory"
    exit 1
fi

print_status "Installing frontend dependencies..."
npm install

if [ $? -ne 0 ]; then
    print_error "Failed to install frontend dependencies"
    exit 1
fi

cd ..

print_status "✅ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Start the OCaml backend server:"
echo "   dune exec web_server/server.exe 8080"
echo ""
echo "2. In another terminal, start the frontend:"
echo "   cd frontend && npm start"
echo ""
echo "3. Open your browser to:"
echo "   http://localhost:3000"
echo ""
echo "4. Use demo credentials:"
echo "   Username: demo"
echo "   Password: demo"
echo ""
print_warning "Make sure both servers are running for the app to work properly!"

# Create convenience scripts
print_status "Creating convenience scripts..."

# Backend start script
cat > start-backend.sh << 'EOF'
#!/bin/bash
echo "🔧 Starting BOOTedCamp API Server..."
dune exec web_server/server.exe 8080
EOF

# Frontend start script
cat > start-frontend.sh << 'EOF'
#!/bin/bash
echo "🎨 Starting BOOTedCamp Frontend..."
cd frontend && npm start
EOF

# Combined start script
cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting BOOTedCamp Development Environment..."

# Function to cleanup background processes
cleanup() {
    echo "Stopping servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit
}

# Set trap to cleanup on script exit
trap cleanup EXIT

# Start backend in background
echo "Starting backend server..."
dune exec web_server/server.exe 8080 &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Start frontend in background
echo "Starting frontend..."
cd frontend && npm start &
FRONTEND_PID=$!

echo ""
echo "✅ Both servers are starting!"
echo "🔧 Backend: http://localhost:8080"
echo "🎨 Frontend: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for user to stop
wait
EOF

chmod +x start-backend.sh start-frontend.sh start-dev.sh

print_status "Created convenience scripts:"
print_status "  ./start-backend.sh  - Start only the backend"
print_status "  ./start-frontend.sh - Start only the frontend"
print_status "  ./start-dev.sh      - Start both servers"

echo ""
print_status "🎉 BOOTedCamp is ready to go!"
