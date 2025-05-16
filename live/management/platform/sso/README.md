# `management / platform / sso`
This module collects all SSO-related resources, utilities, and per tenants config.

* `/cloud_city` SSO resources for Cloud City groups, authorizing the humans that operate the platform.
* `/utilities` common config and utilities for all SSO resources
* `/shared` is a special module of sso resources that are re-used for multiple tenants. Not like the `/cloud_city` module, which is for operators of the Cloud City platform itself and does not authorize any tenants.