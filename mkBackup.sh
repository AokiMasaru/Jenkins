#!/bin/bash
podman run --rm     -v jenkins_jenkins_home:/source:ro     -v $(pwd):/backup     alpine tar -cvzf /backup/jenkins_backup_$(date +%Y%m%d).tar.gz     --exclude='plugins'     --exclude='workspace'     --exclude='war'     --exclude='caches'     -C /source .
