#!/bin/bash

# Upload Script for Brev
# Makes it easy to transfer files to your Brev instance

echo "======================================"
echo "Upload to Brev Instance"
echo "======================================"
echo ""

# Check if files exist
if [ ! -f "setup_g1_cloud.sh" ]; then
    echo "Error: Run this script from the /home/bhavesh/rented directory"
    exit 1
fi

# Get Brev instance address
echo "Enter your Brev instance address"
echo "(Example: user@xyz123.brev.dev)"
read -p "Brev address: " BREV_ADDRESS

if [ -z "$BREV_ADDRESS" ]; then
    echo "Error: No address provided"
    exit 1
fi

echo ""
echo "Uploading files to $BREV_ADDRESS..."
echo ""

# Create directory on Brev
echo "Creating g1-setup directory on Brev..."
ssh "$BREV_ADDRESS" "mkdir -p ~/g1-setup"

# Upload all necessary files
echo "Uploading scripts..."
scp *.sh "$BREV_ADDRESS:~/g1-setup/"

echo "Uploading Python files..."
scp *.py "$BREV_ADDRESS:~/g1-setup/"

echo "Uploading JavaScript files..."
scp *.js "$BREV_ADDRESS:~/g1-setup/"

echo "Uploading HTML files..."
scp *.html "$BREV_ADDRESS:~/g1-setup/"

echo "Uploading config files..."
scp *.json *.env "$BREV_ADDRESS:~/g1-setup/" 2>/dev/null

echo "Uploading documentation..."
scp *.md "$BREV_ADDRESS:~/g1-setup/"

echo ""
echo "Making scripts executable..."
ssh "$BREV_ADDRESS" "cd ~/g1-setup && chmod +x *.sh"

echo ""
echo "======================================"
echo "✓ Upload Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. SSH to your Brev instance:"
echo "   ssh -L 8080:localhost:8080 $BREV_ADDRESS"
echo ""
echo "2. Navigate to the directory:"
echo "   cd ~/g1-setup"
echo ""
echo "3. Check your system:"
echo "   ./check_system.sh"
echo ""
echo "4. Run setup:"
echo "   ./setup_g1_cloud.sh"
echo ""
