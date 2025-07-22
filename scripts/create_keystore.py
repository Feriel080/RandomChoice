import subprocess
import os

def create_android_keystore():
    """Create a keystore for signing the Android APK"""
    
    print("🔐 Creating Android keystore...")
    
    keystore_path = "android/app/randomchoice-keystore.jks"
    
    # Check if keystore already exists
    if os.path.exists(keystore_path):
        print("✅ Keystore already exists!")
        return True
    
    try:
        # Create keystore using keytool
        subprocess.run([
            'keytool',
            '-genkey',
            '-v',
            '-keystore', keystore_path,
            '-alias', 'randomchoice',
            '-keyalg', 'RSA',
            '-keysize', '2048',
            '-validity', '10000',
            '-storepass', 'randomchoice123',
            '-keypass', 'randomchoice123',
            '-dname', 'CN=Random Choice Game, OU=Game Development, O=Random Choice, L=City, S=State, C=US'
        ], check=True)
        
        print("✅ Keystore created successfully!")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error creating keystore: {e}")
        print("Make sure Java JDK is installed and keytool is in your PATH")
        return False
    except FileNotFoundError:
        print("❌ keytool not found. Please install Java JDK")
        return False

if __name__ == "__main__":
    create_android_keystore()
