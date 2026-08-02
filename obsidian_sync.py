#!/usr/bin/env python3
"""
Obsidian ↔ Google Drive Sync Tool
Automatic two-way sync between Obsidian vault and Google Drive.
Runs every 15 minutes or on-demand.

Usage:
    python obsidian_sync.py --setup       # First-time OAuth setup
    python obsidian_sync.py --daemon      # Run continuous daemon (every 15 min)
    python obsidian_sync.py --sync        # One-time sync
    python obsidian_sync.py --status      # Show sync status
"""

import os
import sys
import json
import hashlib
import time
import argparse
import threading
import logging
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import pickle

# Google Drive API
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.api_core.exceptions import GoogleAPIError
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload, MediaIoBaseDownload
from io import BytesIO

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(Path.home() / '.obsidian_sync' / 'sync.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Google Drive API scopes
SCOPES = ['https://www.googleapis.com/auth/drive.file']

# Configuration
CONFIG_DIR = Path.home() / '.obsidian_sync'
CONFIG_FILE = CONFIG_DIR / 'config.json'
TOKEN_FILE = CONFIG_DIR / 'token.pickle'
MANIFEST_FILE = CONFIG_DIR / 'manifest.json'
CREDS_FILE = CONFIG_DIR / 'credentials.json'

SYNC_INTERVAL = 15 * 60  # 15 minutes in seconds
GOOGLE_DRIVE_ROOT_FOLDER = 'Obsidian-Sync'


class ObsidianSyncConfig:
    """Manage sync configuration."""

    def __init__(self):
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        self.config = self._load_config()

    def _load_config(self) -> Dict:
        """Load or create config file."""
        if CONFIG_FILE.exists():
            with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)

        # Default config
        config = {
            'obsidian_vault_path': str(Path.home() / 'Obsidian'),
            'sync_extensions': ['.md', '.canvas'],
            'exclude_patterns': ['.obsidian', '.git', 'node_modules', '.DS_Store'],
            'last_sync': None,
            'google_drive_root': GOOGLE_DRIVE_ROOT_FOLDER
        }

        # Ask user for vault path if it doesn't exist
        obsidian_path = input(
            f"Enter your Obsidian vault path (default: {config['obsidian_vault_path']}): "
        ).strip()
        if obsidian_path:
            config['obsidian_vault_path'] = obsidian_path

        self.save_config(config)
        return config

    def save_config(self, config: Dict) -> None:
        """Save config to file."""
        with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
        self.config = config

    def get(self, key: str, default=None):
        """Get config value."""
        return self.config.get(key, default)

    def update(self, key: str, value) -> None:
        """Update and save config."""
        self.config[key] = value
        self.save_config(self.config)


class FileManifest:
    """Track file hashes and sync status."""

    def __init__(self):
        self.manifest = self._load_manifest()

    def _load_manifest(self) -> Dict:
        """Load or create manifest."""
        if MANIFEST_FILE.exists():
            with open(MANIFEST_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}

    def save(self) -> None:
        """Save manifest to file."""
        with open(MANIFEST_FILE, 'w', encoding='utf-8') as f:
            json.dump(self.manifest, f, indent=2, ensure_ascii=False)

    def get_hash(self, filepath: str) -> Optional[str]:
        """Get stored hash for file."""
        return self.manifest.get(filepath, {}).get('hash')

    def set_hash(self, filepath: str, file_hash: str, location: str = 'both') -> None:
        """Store file hash and metadata."""
        self.manifest[filepath] = {
            'hash': file_hash,
            'last_sync': datetime.now().isoformat(),
            'location': location  # 'local', 'remote', or 'both'
        }
        self.save()

    def remove(self, filepath: str) -> None:
        """Remove file from manifest."""
        self.manifest.pop(filepath, None)
        self.save()


def compute_file_hash(filepath: Path) -> str:
    """Compute SHA256 hash of file."""
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            sha256.update(chunk)
    return sha256.hexdigest()


class GoogleDriveManager:
    """Handle Google Drive operations."""

    def __init__(self):
        self.service = None
        self.root_folder_id = None
        self._authenticate()
        self._ensure_root_folder()

    def _authenticate(self) -> None:
        """Authenticate with Google Drive API."""
        creds = None

        # Load existing token
        if TOKEN_FILE.exists():
            with open(TOKEN_FILE, 'rb') as f:
                creds = pickle.load(f)

        # If token expired, refresh
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        elif not creds or not creds.valid:
            # New authentication
            if not CREDS_FILE.exists():
                logger.error(
                    f"Credentials file not found: {CREDS_FILE}\n"
                    "Download from https://console.cloud.google.com/apis/credentials\n"
                    "Create OAuth 2.0 Client ID (Desktop application)"
                )
                sys.exit(1)

            flow = InstalledAppFlow.from_client_secrets_file(
                CREDS_FILE, SCOPES
            )
            creds = flow.run_local_server(port=0)

        # Save token
        with open(TOKEN_FILE, 'wb') as f:
            pickle.dump(creds, f)

        self.service = build('drive', 'v3', credentials=creds)
        logger.info("✓ Google Drive authenticated")

    def _ensure_root_folder(self) -> None:
        """Ensure root Obsidian-Sync folder exists on Google Drive."""
        try:
            results = self.service.files().list(
                q=f"name='{GOOGLE_DRIVE_ROOT_FOLDER}' and mimeType='application/vnd.google-apps.folder' and trashed=false",
                spaces='drive',
                fields='files(id, name)',
                pageSize=1
            ).execute()

            files = results.get('files', [])
            if files:
                self.root_folder_id = files[0]['id']
                logger.info(f"✓ Found root folder: {GOOGLE_DRIVE_ROOT_FOLDER}")
            else:
                # Create root folder
                file_metadata = {
                    'name': GOOGLE_DRIVE_ROOT_FOLDER,
                    'mimeType': 'application/vnd.google-apps.folder'
                }
                folder = self.service.files().create(
                    body=file_metadata,
                    fields='id'
                ).execute()
                self.root_folder_id = folder.get('id')
                logger.info(f"✓ Created root folder: {GOOGLE_DRIVE_ROOT_FOLDER}")
        except GoogleAPIError as e:
            logger.error(f"Failed to ensure root folder: {e}")
            raise

    def _get_or_create_folder(self, folder_path: str, parent_id: Optional[str] = None) -> str:
        """Get folder ID or create if doesn't exist."""
        if parent_id is None:
            parent_id = self.root_folder_id

        # Normalize path
        folder_path = folder_path.strip('/')
        if not folder_path:
            return parent_id

        parts = folder_path.split('/')
        current_parent = parent_id

        for part in parts:
            try:
                results = self.service.files().list(
                    q=f"name='{part}' and mimeType='application/vnd.google-apps.folder' and '{current_parent}' in parents and trashed=false",
                    spaces='drive',
                    fields='files(id)',
                    pageSize=1
                ).execute()

                files = results.get('files', [])
                if files:
                    current_parent = files[0]['id']
                else:
                    # Create folder
                    file_metadata = {
                        'name': part,
                        'mimeType': 'application/vnd.google-apps.folder',
                        'parents': [current_parent]
                    }
                    folder = self.service.files().create(
                        body=file_metadata,
                        fields='id'
                    ).execute()
                    current_parent = folder.get('id')
            except GoogleAPIError as e:
                logger.error(f"Failed to get/create folder {part}: {e}")
                raise

        return current_parent

    def upload_file(self, local_path: Path, relative_path: str) -> bool:
        """Upload file to Google Drive."""
        try:
            folder_path = str(relative_path.parent).replace('\\', '/')
            if folder_path == '.':
                folder_path = ''

            parent_id = self._get_or_create_folder(folder_path)

            file_metadata = {
                'name': local_path.name,
                'parents': [parent_id]
            }

            media = MediaFileUpload(str(local_path), resumable=True)

            # Check if file exists
            results = self.service.files().list(
                q=f"name='{local_path.name}' and '{parent_id}' in parents and trashed=false",
                spaces='drive',
                fields='files(id)',
                pageSize=1
            ).execute()

            files = results.get('files', [])
            if files:
                # Update existing
                file_id = files[0]['id']
                self.service.files().update(
                    fileId=file_id,
                    media_body=media
                ).execute()
                logger.info(f"↑ Updated: {relative_path}")
            else:
                # Create new
                self.service.files().create(
                    body=file_metadata,
                    media_body=media,
                    fields='id'
                ).execute()
                logger.info(f"↑ Uploaded: {relative_path}")

            return True
        except GoogleAPIError as e:
            logger.error(f"Failed to upload {relative_path}: {e}")
            return False

    def download_file(self, remote_path: str, local_path: Path) -> bool:
        """Download file from Google Drive."""
        try:
            # Find file on Google Drive
            folder_path = str(Path(remote_path).parent).replace('\\', '/')
            filename = Path(remote_path).name

            if folder_path == '.':
                parent_id = self.root_folder_id
            else:
                parent_id = self._get_or_create_folder(folder_path)

            results = self.service.files().list(
                q=f"name='{filename}' and '{parent_id}' in parents and trashed=false",
                spaces='drive',
                fields='files(id)',
                pageSize=1
            ).execute()

            files = results.get('files', [])
            if not files:
                logger.warning(f"File not found on Google Drive: {remote_path}")
                return False

            file_id = files[0]['id']

            # Download
            request = self.service.files().get_media(fileId=file_id)
            fh = BytesIO()
            downloader = MediaIoBaseDownload(fh, request)

            done = False
            while not done:
                _, done = downloader.next_chunk()

            # Write to local
            local_path.parent.mkdir(parents=True, exist_ok=True)
            with open(local_path, 'wb') as f:
                f.write(fh.getvalue())

            logger.info(f"↓ Downloaded: {remote_path}")
            return True
        except GoogleAPIError as e:
            logger.error(f"Failed to download {remote_path}: {e}")
            return False

    def list_remote_files(self, folder_path: str = '') -> List[Tuple[str, str]]:
        """List all files on Google Drive (relative paths and IDs)."""
        files = []

        try:
            if folder_path:
                parent_id = self._get_or_create_folder(folder_path)
            else:
                parent_id = self.root_folder_id

            self._list_files_recursive(parent_id, folder_path, files)
        except GoogleAPIError as e:
            logger.error(f"Failed to list remote files: {e}")

        return files

    def _list_files_recursive(self, parent_id: str, parent_path: str, files: List) -> None:
        """Recursively list files in a folder."""
        try:
            results = self.service.files().list(
                q=f"'{parent_id}' in parents and trashed=false",
                spaces='drive',
                fields='files(id, name, mimeType)',
                pageSize=100
            ).execute()

            items = results.get('files', [])
            for item in items:
                current_path = f"{parent_path}/{item['name']}" if parent_path else item['name']

                if item['mimeType'] == 'application/vnd.google-apps.folder':
                    # Recurse into folder
                    self._list_files_recursive(item['id'], current_path, files)
                else:
                    files.append((current_path, item['id']))
        except GoogleAPIError as e:
            logger.error(f"Failed to list files in {parent_id}: {e}")

    def delete_file(self, remote_path: str) -> bool:
        """Delete file from Google Drive."""
        try:
            folder_path = str(Path(remote_path).parent).replace('\\', '/')
            filename = Path(remote_path).name

            if folder_path == '.':
                parent_id = self.root_folder_id
            else:
                parent_id = self._get_or_create_folder(folder_path)

            results = self.service.files().list(
                q=f"name='{filename}' and '{parent_id}' in parents and trashed=false",
                spaces='drive',
                fields='files(id)',
                pageSize=1
            ).execute()

            files = results.get('files', [])
            if files:
                self.service.files().delete(fileId=files[0]['id']).execute()
                logger.info(f"🗑 Deleted: {remote_path}")
                return True
            return False
        except GoogleAPIError as e:
            logger.error(f"Failed to delete {remote_path}: {e}")
            return False


class ObsidianSync:
    """Main sync orchestrator."""

    def __init__(self):
        self.config = ObsidianSyncConfig()
        self.manifest = FileManifest()
        self.drive = GoogleDriveManager()

        self.vault_path = Path(self.config.get('obsidian_vault_path'))
        self.sync_extensions = self.config.get('sync_extensions', ['.md', '.canvas'])
        self.exclude_patterns = self.config.get('exclude_patterns', [])

        if not self.vault_path.exists():
            logger.error(f"Obsidian vault not found: {self.vault_path}")
            sys.exit(1)

        logger.info(f"✓ Initialized Obsidian vault: {self.vault_path}")

    def should_exclude(self, filepath: Path) -> bool:
        """Check if file should be excluded from sync."""
        for pattern in self.exclude_patterns:
            if pattern in str(filepath):
                return True
        return False

    def get_local_files(self) -> Dict[str, Path]:
        """Get all syncable files in local vault."""
        files = {}
        for ext in self.sync_extensions:
            for filepath in self.vault_path.rglob(f'*{ext}'):
                if not self.should_exclude(filepath):
                    relative = filepath.relative_to(self.vault_path)
                    files[str(relative).replace('\\', '/')] = filepath
        return files

    def sync_local_to_remote(self) -> int:
        """Upload changed local files to Google Drive."""
        count = 0
        local_files = self.get_local_files()

        for rel_path, local_path in local_files.items():
            try:
                current_hash = compute_file_hash(local_path)
                stored_hash = self.manifest.get_hash(rel_path)

                if current_hash != stored_hash:
                    if self.drive.upload_file(local_path, rel_path):
                        self.manifest.set_hash(rel_path, current_hash, 'both')
                        count += 1
            except Exception as e:
                logger.error(f"Error syncing {rel_path}: {e}")

        return count

    def sync_remote_to_local(self) -> int:
        """Download new/changed files from Google Drive."""
        count = 0
        remote_files = self.drive.list_remote_files()

        for rel_path, file_id in remote_files:
            try:
                local_path = self.vault_path / rel_path

                # Skip non-syncable extensions
                if not any(rel_path.endswith(ext) for ext in self.sync_extensions):
                    continue

                # Check if file exists locally
                if local_path.exists():
                    current_hash = compute_file_hash(local_path)
                else:
                    current_hash = None

                # Download if missing or different
                stored_hash = self.manifest.get_hash(rel_path)
                if current_hash != stored_hash:
                    if self.drive.download_file(rel_path, local_path):
                        new_hash = compute_file_hash(local_path)
                        self.manifest.set_hash(rel_path, new_hash, 'both')
                        count += 1
            except Exception as e:
                logger.error(f"Error downloading {rel_path}: {e}")

        return count

    def sync_deletions(self) -> int:
        """Handle file deletions (local or remote)."""
        count = 0
        # For now, we only sync up changes, not deletions
        # To enable deletion sync, you can add the logic here
        return count

    def perform_sync(self) -> Dict:
        """Perform full two-way sync."""
        logger.info("=" * 50)
        logger.info("Starting sync...")

        start_time = time.time()

        uploaded = self.sync_local_to_remote()
        downloaded = self.sync_remote_to_local()
        deleted = self.sync_deletions()

        elapsed = time.time() - start_time

        self.config.update('last_sync', datetime.now().isoformat())

        result = {
            'uploaded': uploaded,
            'downloaded': downloaded,
            'deleted': deleted,
            'elapsed': f"{elapsed:.2f}s",
            'timestamp': datetime.now().isoformat()
        }

        logger.info(f"✓ Sync complete: ↑{uploaded} ↓{downloaded} 🗑{deleted} ({elapsed:.2f}s)")
        logger.info("=" * 50)

        return result

    def run_daemon(self) -> None:
        """Run continuous sync daemon."""
        logger.info(f"Starting daemon (interval: {SYNC_INTERVAL}s)")

        try:
            while True:
                try:
                    self.perform_sync()
                except Exception as e:
                    logger.error(f"Sync error: {e}", exc_info=True)

                logger.info(f"Next sync in {SYNC_INTERVAL}s...")
                time.sleep(SYNC_INTERVAL)
        except KeyboardInterrupt:
            logger.info("Daemon stopped by user")
            sys.exit(0)

    def show_status(self) -> None:
        """Show sync status."""
        last_sync = self.config.get('last_sync')
        vault_path = self.config.get('obsidian_vault_path')

        local_files = self.get_local_files()
        remote_files = self.drive.list_remote_files()

        print("\n" + "=" * 50)
        print("Obsidian Sync Status")
        print("=" * 50)
        print(f"Vault: {vault_path}")
        print(f"Local files: {len(local_files)}")
        print(f"Remote files: {len(remote_files)}")
        print(f"Last sync: {last_sync or 'Never'}")
        print("=" * 50 + "\n")


def setup_credentials() -> None:
    """Setup Google Drive credentials."""
    print("\nGoogle Drive OAuth Setup")
    print("=" * 50)
    print("1. Go to: https://console.cloud.google.com/apis/credentials")
    print("2. Create OAuth 2.0 Client ID (Desktop application)")
    print("3. Download JSON credentials file")
    print(f"4. Save as: {CREDS_FILE}")
    print("=" * 50 + "\n")

    if not CREDS_FILE.exists():
        raise FileNotFoundError(f"Credentials file not found: {CREDS_FILE}")


def main():
    parser = argparse.ArgumentParser(
        description='Obsidian ↔ Google Drive Sync',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )

    parser.add_argument('--setup', action='store_true', help='Setup Google Drive OAuth')
    parser.add_argument('--daemon', action='store_true', help='Run continuous daemon')
    parser.add_argument('--sync', action='store_true', help='One-time sync')
    parser.add_argument('--status', action='store_true', help='Show sync status')

    args = parser.parse_args()

    try:
        if args.setup:
            setup_credentials()
            sync = ObsidianSync()
            logger.info("✓ Setup complete! Run --daemon to start syncing")

        elif args.daemon:
            sync = ObsidianSync()
            sync.run_daemon()

        elif args.status:
            sync = ObsidianSync()
            sync.show_status()

        else:
            # Default: one-time sync
            sync = ObsidianSync()
            sync.perform_sync()

    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
