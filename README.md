# Trigger Framework Package

This package contains a comprehensive Trigger Actions Framework for Salesforce.

## Package Structure

This project follows the **Salesforce DX source format** with a standard manifest package structure:

```
trigger-framework-package/
├── sfdx-project.json          # SFDX project configuration
├── .forceignore               # Files to ignore during deployment
├── manifest/
│   └── package.xml            # Package manifest
└── force-app/
    └── main/
        └── default/
            ├── classes/       # Apex classes
            ├── triggers/      # Apex triggers
            ├── objects/       # Custom objects and metadata
            └── layouts/       # Page layouts
```

## Components Included

### Core Framework Classes

- `ITriggerHandler` - Interface for trigger handlers
- `TriggerContext` - Context information for triggers
- `TriggerHandler` - Base trigger handler class
- `AsyncTriggerHandler` - Async trigger handler
- `TriggerHandlerUtils` - Utility methods
- `TriggerHandlerConstants` - Framework constants
- `TriggerBypassManager` - Bypass management

### Example Implementation

- `Example_AccountTriggerHandler` - Example handler implementation
- `AccountTrigger` - Example trigger

### Custom Metadata Types

- `Trigger_Handler_Config__mdt` - Handler configuration
- `Trigger_Action__mdt` - Action configuration

### Custom Settings

- `Trigger_Bypass__c` - Bypass settings

## Deployment Options

### Option 1: Deploy using Manifest (package.xml)

```bash
sf project deploy start --manifest manifest/package.xml
```

### Option 2: Deploy entire source

```bash
sf project deploy start --source-dir force-app
```

### Option 3: Deploy to scratch org

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias trigger-framework
sf project deploy start --source-dir force-app
```

## Validation

Validate before deploying:

```bash
sf project deploy validate --manifest manifest/package.xml
```

## Running Tests

Run all tests:

```bash
sf apex test run --test-level RunLocalTests --result-format human
```

## API Version

This package uses API version **65.0**.
