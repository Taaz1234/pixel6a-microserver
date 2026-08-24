#!/bin/bash
curl -sSL https://getamp.sh | bash -s display > /tmp/amp_installer.sh
grep -E "repo|deb|arch|ampinstmgr" /tmp/amp_installer.sh | head -n 30
