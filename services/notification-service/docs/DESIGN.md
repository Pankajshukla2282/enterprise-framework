# Notification Service Design
Owns notification requests, templates, provider adapters, delivery attempts and status.

API concepts: create notification, preview template, list deliveries, retry delivery.
Events: notification.requested, notification.sent, notification.failed.
Security: tenant-scoped templates and recipient authorization; redact sensitive payloads.
