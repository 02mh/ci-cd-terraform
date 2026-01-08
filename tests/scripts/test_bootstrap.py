import pytest
import subprocess
import sys
import os
from unittest.mock import MagicMock, patch, mock_open
from scripts.bootstrap import check_authentication, check_terraform, run_bootstrap

def test_check_authentication_success(mocker):
    mock_run = mocker.patch("subprocess.run")
    mock_run.return_value = MagicMock(returncode=0)
    
    # Should not raise or exit
    check_authentication()
    mock_run.assert_called_once()

def test_check_authentication_failure(mocker):
    mock_run = mocker.patch("subprocess.run")
    mock_run.return_value = MagicMock(returncode=1)
    mock_exit = mocker.patch("sys.exit")
    
    check_authentication()
    mock_exit.assert_called_once_with(1)

def test_check_authentication_not_found(mocker):
    mock_run = mocker.patch("subprocess.run", side_effect=FileNotFoundError)
    mock_exit = mocker.patch("sys.exit")
    
    check_authentication()
    mock_exit.assert_called_once_with(1)

def test_check_terraform_success(mocker):
    mock_run = mocker.patch("subprocess.run")
    mock_run.return_value = MagicMock(stdout="Terraform v1.5.0")
    
    check_terraform()
    mock_run.assert_called_once()

def test_check_terraform_not_found(mocker):
    mock_run = mocker.patch("subprocess.run", side_effect=FileNotFoundError)
    mock_exit = mocker.patch("sys.exit")
    
    check_terraform()
    mock_exit.assert_called_once_with(1)

@patch("builtins.input")
@patch("scripts.bootstrap.check_terraform")
@patch("scripts.bootstrap.check_authentication")
@patch("os.chdir")
@patch("subprocess.run")
def test_run_bootstrap(mock_run, mock_chdir, mock_auth, mock_tf, mock_input, mocker):
    # Mock inputs
    mock_input.side_effect = [
        "org", "token", "github_token", "dev-id", "qa-id", "stage-id", "prod-id", 
        "org/repo", "main", "qa", "stage", "prod", "infra-project", "region", "zone", "org-id"
    ]
    
    # Mock file writing
    m_open = mock_open()
    with patch("builtins.open", m_open):
        run_bootstrap()
    
    # Verify expectations
    assert mock_input.call_count == 15
    assert mock_run.call_count == 3 # 2 in cicd module, 1 in main infra
    assert mock_chdir.call_count == 4 # 2 to enter, 2 to return (actually 3 returns in code)
    # Looking at the code:
    # 1. os.chdir(cicd_dir)
    # 2. os.chdir(original_dir)
    # 3. os.chdir(infra_dir)
    # 4. os.chdir(original_dir)
    
    # Verify tfvars creation
    # Two files should be opened for writing
    # 1. infra/modules/cicd/terraform.tfvars
    # 2. infra/terraform.tfvars
    assert m_open.call_count == 2

    # Verify environment variables
    for call in mock_run.call_args_list:
        env = call.kwargs.get("env")
        assert env is not None
        assert env["TF_TOKEN_app_terraform_io"] == "token"
