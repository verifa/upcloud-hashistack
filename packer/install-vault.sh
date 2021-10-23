#!/bin/bash

set -e

readonly VAULT_URL="https://releases.hashicorp.com/vault"

readonly DOWNLOAD_PACKAGE_PATH="/tmp/vault.zip"
readonly SYSTEM_BIN_DIR="/usr/local/bin"

readonly SCRIPT_NAME="$(basename "$0")"

function log {
    local -r level="$1"
    local -r message="$2"
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo >&2 -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
    local -r message="$1"
    log "INFO" "$message"
}

function log_warn {
    local -r message="$1"
    log "WARN" "$message"
}

function log_error {
    local -r message="$1"
    log "ERROR" "$message"
}

function install_deps {
    log_info "Installing dependencies"

    apt-get install -y -qq \
        unzip
}

function download_install {
    log_info "Downloading and installing vault"

    wget "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" -O ${DOWNLOAD_PACKAGE_PATH}
    unzip -d /tmp "${DOWNLOAD_PACKAGE_PATH}"

    log_info "Moving Vault binary to $vault_dest_path"
    chown root:root /tmp/vault
    mv /tmp/vault /usr/local/bin/.

    vault --version

    # Give Vault the ability to use the mlock syscall without running the process as root.
    # The mlock syscall prevents memory from being swapped to disk.
    setcap cap_ipc_lock=+ep /usr/local/bin/vault

    # Create a unique, non-privileged system user to run Vault
    useradd --system --home /etc/vault.d --shell /bin/false vault
}

function configure_systemd {
    log_info "Configuring systemd service"

    local service_file="/tmp/vault.service"
    if [ ! -f "$service_file" ]; then
        log_error "$service_file does not exist"
        exit 1
    fi
    mv "$service_file" /etc/systemd/system/.

    # Enable the service
    systemctl enable vault
}

function configure_vault_config {
    log_info "Create configuration directory /etc/vault.d"
    mkdir --parents /etc/vault.d
    chown --recursive vault:vault /etc/vault.d
}

function install {
    # Check the vault version is set
    if [[ -z "${VAULT_VERSION}" ]]; then
        log_error "Must set VAULT_VERSION environment variable"
        exit 1
    fi

    log_info "Starting vault install"
    install_deps
    download_install
    configure_systemd
    configure_vault_config
}

install
