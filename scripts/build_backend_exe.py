import os
import subprocess
import sys
import shutil

def create_backend_exe():
    print("🚀 Building backend executable...")
    
    try:
        import PyInstaller
    except ImportError:
        print("Installing PyInstaller...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
    
    spec_content = '''
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['backend.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[
        'uvicorn.lifespan.on',
        'uvicorn.lifespan.off',
        'uvicorn.protocols.websockets.auto',
        'uvicorn.protocols.websockets.websockets_impl',
        'uvicorn.protocols.http.auto',
        'uvicorn.protocols.http.h11_impl',
        'uvicorn.protocols.http.httptools_impl',
        'uvicorn.loops.auto',
        'uvicorn.loops.asyncio',
        'uvicorn.loops.uvloop',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='RandomChoiceGameServer',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    cofile=None,
    icon=None,
)
'''
    
    # Write spec file
    with open('backend.spec', 'w') as f:
        f.write(spec_content)
    
    # Build the executable
    try:
        subprocess.check_call([
            'pyinstaller', 
            '--clean',
            '--onefile',
            '--console',
            '--name=RandomChoiceGameServer',
            'backend.py'
        ])
        
        print("✅ Backend executable created successfully!")
        print("📁 Location: dist/RandomChoiceGameServer.exe")
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error building executable: {e}")
        return False
    
    return True

def create_installer_script():
    """Create a batch script to run the server"""
    
    installer_content = '''@echo off
title Random Choice Game Server
echo.
echo ========================================
echo    Random Choice Game Server
echo ========================================
echo.
echo Starting server on http://localhost:8000
echo.
echo Keep this window open while using the app!
echo Press Ctrl+C to stop the server.
echo.

RandomChoiceGameServer.exe

pause
'''
    
    with open('dist/start_server.bat', 'w') as f:
        f.write(installer_content)
    
    print("✅ Server startup script created: dist/start_server.bat")

if __name__ == "__main__":
    if create_backend_exe():
        create_installer_script()
        print("\n🎉 Backend build complete!")
        print("📦 Files created:")
        print("   - dist/RandomChoiceGameServer.exe")
        print("   - dist/start_server.bat")
