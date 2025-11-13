# VSCode Configuration for Untwist

This directory contains VSCode workspace settings for iOS development with SweetPad.

## Files

### `settings.json`
Project-specific settings for:
- SweetPad iOS development
- Swift language configuration
- File associations and exclusions
- Editor formatting rules
- Git and terminal settings

### `tasks.json`
Predefined tasks for common operations:
- **Build Untwist** (Cmd+R) - Build the app
- **Clean Build Folder** (Cmd+Shift+K) - Clean build artifacts
- **Test Untwist** (Cmd+U) - Run tests
- **Archive Untwist** - Create archive for distribution
- **Terraform Plan** - Preview infrastructure changes
- **Terraform Apply** - Apply infrastructure changes
- **Start Admin Dashboard** - Launch feedback dashboard

Run tasks via:
- Command Palette: `Tasks: Run Task`
- Keyboard shortcuts (see keybindings.json)
- SweetPad sidebar buttons

### `launch.json`
Debug configurations for:
- **Debug Untwist on Simulator** - Launch with debugger attached
- **Attach to Untwist Process** - Attach debugger to running app

Requires CodeLLDB extension.

### `keybindings.json`
Custom keyboard shortcuts:
- `Cmd+R` - Build Untwist
- `Cmd+Shift+R` - Build & Run (SweetPad)
- `Cmd+B` - Build Only (SweetPad)
- `Cmd+Shift+K` - Clean Build
- `Cmd+U` - Run Tests
- `Cmd+J` - Toggle Terminal
- `Cmd+T` - Quick Open
- `Cmd+Shift+G` - Open Source Control

### `extensions.json`
Recommended extensions for this project:
- **SweetPad** - iOS development in VSCode
- **CodeLLDB** - Debugging
- **Swift Format** - Code formatting
- **Swift Language** - Syntax support
- **GitLens** - Enhanced git features
- **Terraform** - Infrastructure as code
- **Error Lens** - Inline error messages

VSCode will prompt to install these when you open the project.

## Getting Started

1. **Install SweetPad**:
   ```bash
   code --install-extension sweetpad.sweetpad
   ```

2. **Open Project**:
   - Open this folder in VSCode
   - Accept extension recommendations
   - SweetPad will detect the project configuration

3. **Using Tuist for Automatic File Management**:
   - The project now uses Tuist (defined in `Project.swift`)
   - SweetPad has built-in Tuist integration
   - New Swift files are automatically detected - no manual Xcode project updates!

   **Tuist Commands** (via Command Palette):
   - `SweetPad: Edit Tuist` - Edit Project.swift configuration
   - `SweetPad: Clean Tuist Project` - Clean generated files
   - SweetPad automatically regenerates `.xcodeproj` when needed

4. **Build & Run**:
   - Press `Cmd+Shift+R` or
   - Click play button in SweetPad sidebar or
   - Run task: `Build Untwist`

5. **Select Simulator**:
   - Use SweetPad's Destination panel
   - Choose iPhone 17 (or any available simulator)

## Benefits

✅ **No Xcode switching** - Everything in VSCode
✅ **Automatic file detection** - Tuist finds new Swift files automatically
✅ **Better git** - Inline diffs, blame, history
✅ **Faster** - Lighter than Xcode
✅ **AI integration** - Claude Code in same window
✅ **Terminal access** - Build, test, terraform all together
✅ **Custom shortcuts** - Keyboard-driven workflow
✅ **No manual project updates** - Create files, they're automatically included

## Troubleshooting

**Build fails**: Ensure Xcode CLI tools installed:
```bash
xcode-select --install
```

**SweetPad not detecting project**:
- Check `sweetpad.workspacePath` in settings.json
- Reload VSCode window

**CodeLLDB debugging issues**:
- Install CodeLLDB extension
- Ensure build succeeds first
- Check launch.json paths

**Tuist/File detection issues**:
- SweetPad handles Tuist automatically
- If new files aren't detected, use Command Palette: `SweetPad: Clean Tuist Project`
- Project.swift defines which directories are scanned (currently `Untwist/**/*.swift`)
- Check that new files match the glob patterns in Project.swift

## Notes

- Settings are project-specific and committed to git
- Keybindings use Xcode-style shortcuts where possible
- Tasks can be customized in tasks.json
- File exclusions keep sidebar clean (DerivedData, xcuserdata, etc.)
- **Tuist**: Project.swift is the source of truth; .xcodeproj is auto-generated
- After Tuist is confirmed working, .xcodeproj and .xcworkspace can be gitignored
