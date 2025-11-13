# Monitor Project Makefile
# Common development tasks

.PHONY: help admin-dash admin-dash-open clean-admin-key terraform-output-keys

# Default target
help:
	@echo "Monitor Development Commands"
	@echo "============================"
	@echo ""
	@echo "Admin Dashboard:"
	@echo "  make admin-dash          Start admin dashboard server on http://localhost:8080"
	@echo "  make admin-dash-open     Start server and open in browser"
	@echo "  make clean-admin-key     Clear stored admin API key from localStorage"
	@echo ""
	@echo "Terraform:"
	@echo "  make terraform-output-keys   Show API keys from Terraform"
	@echo ""

# Start admin dashboard server
admin-dash:
	@echo "Starting admin dashboard on http://localhost:8080"
	@echo "Press Ctrl+C to stop"
	@echo ""
	@echo "To get your admin API key, run:"
	@echo "  cd terraform && terraform output -raw admin_api_key"
	@echo ""
	@cd . && python3 -m http.server 8080

# Start server and open in browser
admin-dash-open:
	@echo "Starting admin dashboard and opening in browser..."
	@open http://localhost:8080/admin-dashboard.html &
	@sleep 1
	@$(MAKE) admin-dash

# Clear admin API key from localStorage (macOS Safari/Chrome)
clean-admin-key:
	@echo "To clear the stored admin API key:"
	@echo "1. Open the admin dashboard in your browser"
	@echo "2. Open Developer Tools (Cmd+Option+I)"
	@echo "3. Go to Console tab"
	@echo "4. Run: localStorage.removeItem('Monitor_admin_api_key')"
	@echo "5. Refresh the page"

# Show API keys from Terraform
terraform-output-keys:
	@echo "Feedback API Key (iOS app):"
	@cd terraform && terraform output -raw api_key
	@echo ""
	@echo ""
	@echo "Admin API Key (dashboard):"
	@cd terraform && terraform output -raw admin_api_key
	@echo ""
