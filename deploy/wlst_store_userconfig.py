# Run this on the WebLogic server using WLST.
# Example:
#   $DOMAIN_HOME/oracle_common/common/bin/wlst.sh deploy/wlst_store_userconfig.py
#
# The script asks for WebLogic admin username/password interactively.

admin_url = "t3://10.20.210.239:7001"
config_file = "/home/weblogic/.wls/userConfig.secure"
key_file = "/home/weblogic/.wls/userKey.secure"

print("Connecting to AdminServer: " + admin_url)
connect()  # interactive prompt
storeUserConfig(config_file, key_file, "true")
disconnect()
exit()
