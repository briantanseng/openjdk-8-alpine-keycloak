#!/bin/bash

##################
# Add admin user #
##################

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    /keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi

###################
# Operating Modes #
##################

# Lower case OPERATING_MODE
OPERATING_MODE=`echo $OPERATING_MODE | tr A-Z a-z`

# Default to standalone if OPERATING_MODE not detected
if [ "$OPERATING_MODE" == "" ]; then
    OPERATING_MODE="standalone"
fi

STANDALONE_BOOT_SCRIPT='standalone.sh'
DOMAIN_BOOT_SCRIPT='domain.sh'

case "$OPERATING_MODE" in
    standalone)
        BOOT_SCRIPT="$STANDALONE_BOOT_SCRIPT"
        if [ "$BOOT_PARAMETERS" == "" ]; then
            export BOOT_PARAMETERS="-b 0.0.0.0"
        fi
	;;
    standalone_clustered)
	BOOT_SCRIPT="$STANDALONE_BOOT_SCRIPT";;
    domain_master)
	BOOT_SCRIPT="$DOMAIN_BOOT_SCRIPT";;
    domain_slave)
	BOOT_SCRIPT="$DOMAIN_BOOT_SCRIPT";;
    *)
	echo "Unknown operating mode $OPERATING_MODE"
	exit 1
esac

##################
# Start Keycloak #
##################
echo "Operating mode $OPERATING_MODE"
echo "Booting up Keycloak with the following parameters $BOOT_PARAMETERS"
exec /keycloak/bin/$BOOT_SCRIPT $BOOT_PARAMETERS
exit $?
