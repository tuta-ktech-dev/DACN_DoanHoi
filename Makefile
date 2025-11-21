.PHONY: help install run run_release clean build test generate watch

# Mặc định hiển thị help khi chạy make
help:
	@echo "Flutter Project Makefile"
	@echo ""
	@echo "Available commands:"
	@echo "  make install    - Cài đặt dependencies (flutter pub get)"
	@echo "  make run        - Chạy ứng dụng"
	@echo "  make clean      - Dọn dẹp build files"
	@echo "  make build      - Build ứng dụng (APK cho Android)"
	@echo "  make test       - Chạy tests"
	@echo "  make generate   - Generate code với build_runner"
	@echo "  make watch      - Watch và auto-generate code"

# Cài đặt dependencies
install:
	flutter pub get

# Chạy ứng dụng
run:
	flutter run

# Chạy ứng dụng release
run_release:
	flutter run --release

# Dọn dẹp build files
clean:
	flutter clean

# Build APK
build:
	flutter build apk --release

# Chạy tests
test:
	flutter test

# Generate code với build_runner
generate:
	flutter pub run build_runner build --delete-conflicting-outputs

# Watch và auto-generate code
watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

