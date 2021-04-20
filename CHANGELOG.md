# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- A new model that provides authentication via the cas. 
  Originally this implementation was inside the dogu. 
  However as integral part of the plugin it was moved to here to prevent redundancies.

### Fixed
- a bug that removed the admin privileges from redmine admin users after a request to the redmine_cas api

## [v1.2.15] - 2020-11-16

### Added
- functionality to enable a redirect from login page to cas login when anonymous access is activated
- scripts for easier development in EcoSystem

### Fixed
- redirect loop when logging in with cas when anonymous access is activated
